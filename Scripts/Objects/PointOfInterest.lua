--- @author Mercor

include("Scripts/Core/Common.lua")

-------------------------------------------------------------------------------
if PointOfInterest == nil then
	PointOfInterest = EternusEngine.GameObjectClass.Subclass("PointOfInterest")
end

-------------------------------------------------------------------------------
function PointOfInterest:Constructor(args)
	self:Debug("\n\nPointOfInterest:Constructor\n\n")
end

-------------------------------------------------------------------------------
function PointOfInterest:PostLoad()
end

-------------------------------------------------------------------------------
function PointOfInterest:Spawn()
	self:Debug("PointOfInterest:Spawn() called")
end

-------------------------------------------------------------------------------
function PointOfInterest:Despawn()
	self:Debug("PointOfInterest:Despawn() called")
end

-------------------------------------------------------------------------------
function PointOfInterest:Update(dt)
end

-------------------------------------------------------------------------------
--- Event that is called when system is trying to calculate wich of the PoIs are inside n units perimeter from the player.
-- When the method is called, PoI will report itself to the main class by calling its InRangePoIAcking method.
function PointOfInterest:Event_CallingAllPoI()
    EternusEngine.mods.PointOfInterest.Main:InRangePoIAcking(self)
end

-------------------------------------------------------------------------------
--- Distance between pos and PointOfInterest.
function PointOfInterest:DistanceTo(pos)
  return EternusEngine.mods.PointOfInterest.Main:calculateDistance(pos, self:NKGetPosition())
end

-------------------------------------------------------------------------------
--- Where pos is from the direction of PointOfInterest.
function PointOfInterest:DirectionTo(pos)
  return EternusEngine.mods.PointOfInterest.Main:calculateDirection(pos, self:NKGetPosition())
end

-------------------------------------------------------------------------------
--- Where PointOfInterest is from the direction of pos.
function PointOfInterest:DirectionFrom(pos)
  return EternusEngine.mods.PointOfInterest.Main:calculateDirection(self:NKGetPosition(), pos)
end

-------------------------------------------------------------------------------
--- Where pos is from the direction of PointOfInterest.
function PointOfInterest:DirectionToInDegrees(pos)
  return EternusEngine.mods.PointOfInterest.Main:calculateDirectionInDegrees(pos, self:NKGetPosition())
end

-------------------------------------------------------------------------------
--- Where PointOfInterest is from the direction of pos.
function PointOfInterest:DirectionFromInDegrees(pos)
  return EternusEngine.mods.PointOfInterest.Main:calculateDirectionInDegrees(self:NKGetPosition(), pos)
end

-------------------------------------------------------------------------------
-- Save function for GameObject
function PointOfInterest:Save(outData)
	self:Debug("PointOfInterest:Save() called")
	PointOfInterest.__super.Save(self, outData) -- only Object classes need to implement this (do not add this to mixins!)

	outData.id = self.id
	outData.title = self.title
	outData.type = self.type
	outData.description = self.description
	outData.discovered = self.discovered
end

-------------------------------------------------------------------------------
-- Load data function for GameObject
function PointOfInterest:Restore(inData, version)
	self:Debug("PointOfInterest:Restore() called")
	PointOfInterest.__super.Restore(self, inData) -- only Object classes need to implement this (do not add this to mixins!)

	self.id = inData.id
	self.title = inData.title
  self.type = inData.type
  self.description = inData.description
  self.discovered = inData.discovered
	self.m_restored = true -- set the m_restored to true (used internally)

	-- TODO: call PointOfInterestMain and tell about the existence of this PoI
	if EternusEngine.mods and EternusEngine.mods.PointOfInterest and EternusEngine.mods.PointOfInterest.Main then
		EternusEngine.mods.PointOfInterest.Main:RestorePointOfInterest(self)
	end
end

-------------------------------------------------------------------------------
function PointOfInterest:ToString()
	self:Debug("PointOfInterest:ToString() called")
  local pos = self:NKGetPosition()
  return '{ title: ' .. self.title .. ', id: ' .. self.id .. ', pos: (' .. tostring(pos:x()) .. ', ' .. tostring(pos:y()) .. ', ' .. tostring(pos:z()) .. '), type: ' .. self.type ..', description: ' .. self.description .. ', discovered: ' .. tostring(self.discovered) .. " }"
end

-------------------------------------------------------------------------------
function PointOfInterest:ToStringWithDirDist()
	self:Debug("PointOfInterest:ToStringWithDirDist() called")
  local pos = self:NKGetPosition()
  local playerPos = Eternus.GameState:GetLocalPlayer():NKGetPosition()
  local direction = self:DistanceTo(playerPos)
  local distance = self:DirectionFrom(playerPos)
  return '{ title: ' .. self.title .. ', id: ' .. self.id .. ', pos: (' .. tostring(pos:x()) .. ', ' .. tostring(pos:y()) .. ', ' .. tostring(pos:z()) .. '), direction: ' .. direction .. ' distance: ' .. distance .. ' type: ' .. self.type ..', description: ' .. self.description .. ', discovered: ' .. tostring(self.discovered) .. " }"
end

function PointOfInterest:Debug(msg)
	if EternusEngine.mods and EternusEngine.mods.PointOfInterest and EternusEngine.mods.PointOfInterest.Mod and EternusEngine.mods.PointOfInterest.Mod.options and EternusEngine.mods.PointOfInterest.Mod.options.useDebug then
		NKPrint(msg)
	end
end

-------------------------------------------------------------------------------
EntityFramework:RegisterGameObject(PointOfInterest)
