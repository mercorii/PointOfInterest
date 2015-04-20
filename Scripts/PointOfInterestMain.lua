--- @author Mercor

include("Scripts/Core/Common.lua")

-- The main file for the Point Of Interest mod. Does most of the work.

if PointOfInterestMain == nil then
	PointOfInterestMain = EternusEngine.Class.Subclass("PointOfInterestMain")
end

-------------------------------------------------------------------------------
function PointOfInterestMain:Constructor(  )
	self.pointsOfInterest = {}
end


-------------------------------------------------------------------------------
-- Called once from C++ at engine initialization time
function PointOfInterestMain:Initialize()

  PointOfInterestMain.MAX_VISIBLE_DISTANCE = 1000 -- TODO: this should be some better number

  -- allowed PoI types -- TODO: this should probably come from a config file or something, probably not from gameobjects data file.
  PointOfInterestMain.poiTypes = {
                      {name = "forest", 		title = "Landmark", description = "Landmark"},
                      {name = "panda", 			title = "Danger", 	description = "Danger"},
                      {name = "lighthouse", title = "Building", description = "Building"},
                      {name = "triforce", 	title = "Altar", 		description = "Altar"},
                      {name = "sheep", 			title = "Resource", description = "Resource"}
  }

  PointOfInterestMain.defaultType = PointOfInterestMain.poiTypes[1].name -- PoI always has type, users can add new types (acts like category)
  PointOfInterestMain.defaultTitle = "Point of Interest" -- PoI always has title, even if only default one
  PointOfInterestMain.defaultDescription = "" -- PoI can contain description, that UI can show if it likes to do so
  PointOfInterestMain.defaultDiscovered = true -- if PoI has been discovered or not (like skyrim full vs bordered location icon)

	PointOfInterestMain.defaultRadius = 1 -- default radius

	PointOfInterestMain.previousPos = nil -- used to refresh poi distances after traveling n units
end

-------------------------------------------------------------------------------
-- Called from C++ when the current game enters
function PointOfInterestMain:Enter()

-- Call load data only if no data is available (mainly, call load data only when gameplay starts first time, not when returning from paused state)
  if not PointOfInterestMain.nextID then
		PointOfInterestMain:InitData()
	end

	local currentPos = Eternus.GameState:GetLocalPlayer():NKGetPosition()
	if PointOfInterestMain.previousPos == nil then
		PointOfInterestMain.previousPos = currentPos
	end
end

-------------------------------------------------------------------------------
-- Called from C++ when the game leaves it current mode
function PointOfInterestMain:Leave()

end

-------------------------------------------------------------------------------
-- Called from C++ every update tick
function PointOfInterestMain:Process(dt)
  -- TODO: calculate distance to previous calculation point, if distance is more than n units, recalculate distance to all PoIs
	local currentPos = Eternus.GameState:GetLocalPlayer():NKGetPosition()
	local recalcDistance	= 10

	if PointOfInterestMain:calculateDistance(PointOfInterestMain.previousPos, currentPos) > recalcDistance then
		PointOfInterestMain.previousPos = currentPos
		PointOfInterestMain:calculateAllPoIDistance(currentPos)
	end

end

--- Returns PoI with id poiID.
-- @param poiID Id of PoI to return.
function PointOfInterestMain:GetPointOfInterest(poiID)
  for i, poi in ipairs(self.pointsOfInterest) do
		self:Debug("PointOfInterestMain:GetPointOfInterest - id: " .. poi.id .. ", poiID: " .. tostring(poiID))
    if tostring(poi.id) == poiID then
      return poi
    end
  end
  return false
end

--- Create a new PoI list item and gameobject.
-- Creates a new PoI, initializes it and spawns it in the given position with the given information.
-- @param pos NKPos object for PoI.
-- @param radius Distance from the center of Poi.
-- @param title Short string to describe PoI.
-- @param description Longer description for PoI.
-- @param poiType Type of PoI. Can be used to differentiate between different types of PoIs.
-- @param discovered Whether or not PoI is discovered and visible, or still to be found and hidden.
function PointOfInterestMain:CreatePointOfInterest(pos, radius, title, description, poiType, discovered)
	self:Debug("PointOfInterestMain:CreatePointOfInterest()")

  local poi = self:SpawnPointOfInterest(pos)

  if poi then
		self:Debug("PointOfInterestMain:CreatePointOfInterest(): new PoI created")

    poi.radius = (radius and radius or self.defaultRadius)

    poi.title = (title and title or self.defaultTitle)
    poi.description = (description and description or self.defaultDescription)

    poi.type = self:getPoIType(poiType) -- (self:PoITypeAllowed(poiType) and poiType or self.defaultType)

    poi.discovered = (discovered and discovered or self.defaultDiscovered)

    poi.id = self.nextID
    self.nextID = self.nextID + 1

    self.pointsOfInterest[#self.pointsOfInterest+1] = poi

		-- let listeners know:
		-- fire item added event
		-- for now, just tell poiCompass
		if EternusEngine.mods.PointOfInterest.CompassUI then
			EternusEngine.mods.PointOfInterest.CompassUI:Event_PoIAdded(poi)
		end
  end

  return poi
end

--- Remove the item from the list and delete the related gameobject.
-- Returns true if it succeeded in removing the item, false otherwise.
-- @param id The PoI to remove.
function PointOfInterestMain:RemovePointOfInterest(id)
	self:Debug("PointOfInterestUI:RemovePointOfInterest(id) called")

  for i, poi in ipairs(self.pointsOfInterest) do
    if poi.id == id then
       -- remove it from the list
      table.remove(self.pointsOfInterest, i)
       -- delete the gameobject
      poi:NKDeleteMe()
      return true
    end
  end
  return false
end

--- Return list of PoIs to the caller.
function PointOfInterestMain:GetPointsOfInterest()
	self:Debug("PointOfInterestUI:GetPointsOfInterest() called")

  local pois = self.pointsOfInterest

  -- each PoI's location is converted to a current distance.. or that probably needs to be done every tick, so it should probably happen somewhere else

  --local inPos = self.currentState.m_activeCamera:NKGetLocation() + (self.currentState.m_activeCamera:ForwardVector() * vec3.new(playerHeight))

  return pois
end


-- PoI gameobjects call this on restore, in order to make their existence known.
function PointOfInterestMain:RestorePointOfInterest(poi)

	-- test that PoI is not already registered
	if self:GetPointOfInterest(self.pointsOfInterest, poi.id) ~= true then
	  self.pointsOfInterest[#self.pointsOfInterest+1] = poi

		-- let listeners know:
		-- fire item added event
		-- for now, just tell poiCompass
		if EternusEngine.mods.PointOfInterest.CompassUI then
			EternusEngine.mods.PointOfInterest.CompassUI:Event_PoIAdded(poi)
		end
  end
end

--- Check if certain PoI type is in the list of allowed types.
-- @param poiTypeToCheck PoI type to check.
-- @return table if allowed type, otherwise return nil
function PointOfInterestMain:PoITypeAllowed(poiTypeToCheck)
	self:Debug("PointOfInterestUI:PoITypeAllowed(poiTypeToCheck) called")

  for i, poiType in ipairs(self.poiTypes) do
    if poiType.name == poiTypeToCheck then
			local type = {}
			type.name = poiType.name
			type.title = poiType.title
			type.description = poiType.description
      return type
    end
  end

  return nil
end

--- Get poi type based on the type name given as parameter.
-- @param typeName Type name to match the allowed type
-- @return table type matching type name given as parameter, or default type if not allowed
function PointOfInterestMain:getPoIType(typeName)
	local type = self:PoITypeAllowed(typeName)

	if type == nil then
		type = {}
		type.name = PointOfInterestMain.poiTypes[1].name -- (self:PoITypeAllowed(poiType) and poiType or self.defaultType)
		type.title = PointOfInterestMain.poiTypes[1].title
		type.description = PointOfInterestMain.poiTypes[1].description
	end

	return type
end

--- Helper function to quickly spawn a GameObject by name with a given position and rotation.
-- Copied from Modes/TUGGameMode.lua.
-- @param position Position of the gameobject.
-- @param rotation Roration of the gameobject. Not used for now.
function PointOfInterestMain:SpawnPointOfInterest( position, rotation )
	self:Debug("\nPointOfInterestMain:SpawnPointOfInterest( position, rotation ) called")
	local obj = Eternus.GameObjectSystem:NKCreateGameObject("PointOfInterest", true)

  if obj then
		self:Debug("PointOfInterestMain:SpawnPointOfInterest - succeeded in creating PointOfInterest")

  	obj:NKSetShouldRender(false, false)
    obj:NKSetPosition(position, false)
--	poi:NKSetRotation(rotation)  -- it doesn't move so rotation shouldn't matter, there's probably default value
-- 		obj:NKPlaceInWorld(true, false) -- true required for saving, but if placed in world, will despawn when leaving zone and result into errors..
		obj:NKPlaceInWorld(false, false)

--    poi:Init(self)

    return obj:NKGetInstance() -- you need to do this for now. Will be no more required after 0.6.6 or 0.6.7, hopefully
  else
		self:Debug("PointOfInterestMain:SpawnPointOfInterest - failed creating PointOfInterest")
    return nil
  end
end

--- Method called by PoI when it's near player.
-- @param poi The acking PoI itself
function PointOfInterestMain:InRangePoIAcking( poi )
	self:Debug("PointOfInterestUI:InRangePoIAcking( poi ) called")
end

--- Calculate a direction (in radians) from first position to a second position, in relation to the current forward vector.
-- @param posFrom First position - a place from where to calculate the direction.
-- @param posTo Second position - a place of which direction is to be calculated in relation to the first position.
function PointOfInterestMain:calculateDirection(posFrom, posTo)
  local fwd = Eternus.GameState.m_activeCamera:ForwardVector()

	-- calculate direction in degrees
  local direction = math.atan2(posFrom:z() - posTo:z() , posFrom:x() - posTo:x()) - math.atan2(fwd:z(), fwd:x())

	-- normalize the direction to be in range [-math.pi, math.pi) ... or is it (-math.pi, math.pi]?
	direction = (direction + math.pi*3) % (math.pi*2) - math.pi
	return direction
end

--- Calculate a direction (in degrees) from first position to a second position.
-- @param posFrom First position - a place from where to calculate the direction.
-- @param posTo Second position - a place of which direction is to be calculated in relation to the first position.
-- @return number.
function PointOfInterestMain:calculateDirectionInDegrees(posFrom, posTo)
	return math.deg(self:calculateDirection(posFrom, posTo))
end

--- Calculate a distance between two positions.
-- @param posFrom First position.
-- @param posTo Second position.
-- @return number.
function PointOfInterestMain:calculateDistance(posFrom, posTo)
  return math.abs((posFrom - posTo):NKLength())
end

--- Calculate direction and distance from pos to PoI position.
-- @param pos Position in relation to which we are calculating PoI's direction and distance.
-- @param poi PoI of which direction and distance from pos we are calculating.
-- @return table.
function PointOfInterestMain:calculatePoIDirectionDistance(pos, poi)
--  self:Debug("\nPointOfInterestMain:calculatePoIDirectionDistance(pos, poi) called\n")

  local dirDis = {}

  local poiPos = poi:NKGetPosition() -- PoI position

  -- calculate distance between player and PoI
  dirDis.distance = self:calculateDistance(poiPos, pos)

--  if dirDis.distance > PointOfInterestMain.MAX_VISIBLE_DISTANCE + 100 then
--      return false -- means it should be deleted from the list as it's too far to be worth following for now
--  end

  -- calculate direction from player to PoI
  dirDis.direction = self:calculateDirection(poiPos, pos)
  return dirDis

end

--- Calculate direction and distance from pos to PoI positions.
-- @param pos Position in relation to which we are calculating PoIs' directions and distances.
-- @return table.
function PointOfInterestMain:calculateAllPoIDirectionDistance(pos)
--  self:Debug("\nPointOfInterestMain:calculateAllPoIDirectionDistance(pos) called\n")

  local pois = {}

  for i, poi in ipairs(self.pointsOfInterest) do
    local dirDis = self:calculatePoIDirectionDistance(pos, poi)
    if dirDis then
      table.insert(pois, { obj = poi,
                  direction = dirDis.direction,
                  distance = dirDis.distance
                })
    end
  end
	return pois
end

--- Calculate distance from pos to all PoI positions.
-- @param pos Position in relation to which we are calculating PoIs' directions and distances.
-- @return table.
function PointOfInterestMain:calculateAllPoIDistance(pos)
--	self:Debug("\nPointOfInterestMain:calculateAllPoIDistance(pos) called\n")

	local pois = {}
	local dis = nil

	for i, poi in ipairs(self.pointsOfInterest) do
		dis = self:calculateDistance(pos, poi:NKGetPosition())
		if dis then
			table.insert(pois, { obj = poi,
									distance = dis
								})
		end
	end
	--TODO: sort table according to distance from player
	return pois
end

--- Save data to a file.
-- @param outData Table that is used to store the data.
function PointOfInterestMain:SaveData(outData)
  self:Debug("PointOfInterestMain:SaveData()")

	-- TODO: save also typedata definitions, or should they always come from a file?

	outData.pois = {}

	for i, poi in ipairs(self.pointsOfInterest) do
		local poiData = {}
		poi:Save(poiData)
		outData.pois[#outData.pois+1] = poiData
	end

	self:Debug("PoIMain: Saving " .. #outData.pois .. " pois")
--	outData.pois = pois
end

--- Load data from a file.
-- @param inData Table containing data to be loaded.
function PointOfInterestMain:RestoreData(inData, version)
	self:Debug("PointOfInterestMain:RestoreData()")
	self:Debug("PoIMain: Restoring pois: " .. (inData.pois and #inData.pois or "no") .. " pois restored")
	self:Debug("PoIMain: Restoring word foo3: " .. inData.testFoo)

	if inData then
		for i, poi in ipairs(inData.pois) do
			local poiType = poi.type and poi.type.name or nil
			self:CreatePointOfInterest(poi.pos, poi.radius, poi.title, poi.description, poiType, poi.discovered)
		end
	end
end

-- formerly known as LoadData, this could probably just be done on initialize
function PointOfInterestMain:InitData()
	self:Debug("PointOfInterestMain:InitData()")
	PointOfInterestMain.nextID = 1
	PointOfInterestMain.pointsOfInterest = {}
end

function PointOfInterestMain:Debug(msg)
	if EternusEngine.mods.PointOfInterest.Mod.options.useDebug then
		NKPrint(msg .. "\n")
	end
end
