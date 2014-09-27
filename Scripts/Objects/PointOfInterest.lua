--- @author Mercor 

include("Scripts/Core/Common.lua")

-------------------------------------------------------------------------------
if PointOfInterest == nil then
	PointOfInterest = EternusEngine.GameObjectClass.Subclass("PointOfInterest")
end

-------------------------------------------------------------------------------
function PointOfInterest:Constructor(args)
  NKPrint("\n\nPointOfInterest:Constructor\n\n")
--  include("Scripts/Mods/PointOfInterester.lua")
--  include("Scripts/Mods/PointOfInterestUI.lua")
end

-------------------------------------------------------------------------------
function PointOfInterest:PostLoad()
end

-------------------------------------------------------------------------------
function PointOfInterest:Spawn()
  NKPrint("PointOfInterest:Spawn() called")
end
 
-------------------------------------------------------------------------------
function PointOfInterest:Despawn()
end

-------------------------------------------------------------------------------
function PointOfInterest:Update(dt)
end

-------------------------------------------------------------------------------
--- Event that is called when system is trying to calculate wich of the PoIs are inside n units perimeter from the player.
-- When the method is called, PoI will report itself to the main class by calling its InRangePoIAcking method.
function PointOfInterest:Event_CallingAllPoI()
    EternusEngine.PointOfInterester:InRangePoIAcking(self)
end

-------------------------------------------------------------------------------
--- Distance between pos and PointOfInterest.
function PointOfInterest:DistanceTo(pos)
  return EternusEngine.PointOfInterester:calculateDistance(pos, self:NKGetPosition())
end

-------------------------------------------------------------------------------
--- Where pos is from the direction of PointOfInterest.
function PointOfInterest:DirectionTo(pos)
  return EternusEngine.PointOfInterester:calculateDirection(pos, self:NKGetPosition())
end

-------------------------------------------------------------------------------
--- Where PointOfInterest is from the direction of pos.
function PointOfInterest:DirectionFrom(pos)
  return EternusEngine.PointOfInterester:calculateDirection(self:NKGetPosition(), pos)
end

-------------------------------------------------------------------------------
--- Where pos is from the direction of PointOfInterest.
function PointOfInterest:DirectionToInDegrees(pos)
  return EternusEngine.PointOfInterester:calculateDirectionInDegrees(pos, self:NKGetPosition())
end

-------------------------------------------------------------------------------
--- Where PointOfInterest is from the direction of pos.
function PointOfInterest:DirectionFromInDegrees(pos)
  return EternusEngine.PointOfInterester:calculateDirectionInDegrees(self:NKGetPosition(), pos)
end

-------------------------------------------------------------------------------
function PointOfInterest:ToString()
  NKPrint("PointOfInterest:ToString() called")
  local pos = self:NKGetPosition()
  return '{ title: ' .. self.title .. ', id: ' .. self.id .. ', pos: (' .. tostring(pos:x()) .. ', ' .. tostring(pos:y()) .. ', ' .. tostring(pos:z()) .. '), type: ' .. self.type ..', description: ' .. self.description .. ', discovered: ' .. tostring(self.discovered) .. " }"
end

-------------------------------------------------------------------------------
function PointOfInterest:ToStringWithDirDist()
  NKPrint("PointOfInterest:ToStringWithDirDist() called")
  local pos = self:NKGetPosition()
  local playerPos = Eternus.GameState:GetLocalPlayer():NKGetPosition()
  local direction = self:DistanceTo(playerPos)
  local distance = self:DirectionFrom(playerPos)
  return '{ title: ' .. self.title .. ', id: ' .. self.id .. ', pos: (' .. tostring(pos:x()) .. ', ' .. tostring(pos:y()) .. ', ' .. tostring(pos:z()) .. '), direction: ' .. direction .. ' distance: ' .. distance .. ' type: ' .. self.type ..', description: ' .. self.description .. ', discovered: ' .. tostring(self.discovered) .. " }"
end

-------------------------------------------------------------------------------
EntityFramework:RegisterGameObject(PointOfInterest)
