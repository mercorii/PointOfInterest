--- @author Mercor

include("Scripts/Core/Common.lua")

-- The main file for the Point Of Interest mod. Does most of the work.

if PointOfInterestMain == nil then
	PointOfInterestMain = EternusEngine.Class.Subclass("PointOfInterestMain")
end

-------------------------------------------------------------------------------
function PointOfInterestMain:Constructor(  )

end


-------------------------------------------------------------------------------
-- Called once from C++ at engine initialization time
function PointOfInterestMain:Initialize()

  PointOfInterestMain.MAX_VISIBLE_DISTANCE = 1000 -- TODO: this should be some better number

  -- allowed PoI types -- TODO: this should probably come from a config file or something, probably not from gameobjects data file.
  PointOfInterestMain.poiTypes = {
                      {name = "normal", description = ""},
                      {name = "danger"},
                      {name = "building"},
                      {name = "altar"},
                      {name = "resource"}
  }

  PointOfInterestMain.defaultType = PointOfInterestMain.poiTypes[1].name -- PoI always has type, users can add new types (acts like category)
  PointOfInterestMain.defaultTitle = "Point of Interest" -- PoI always has title, even if only default one
  PointOfInterestMain.defaultDescription = "" -- PoI can contain description, that UI can show if it likes to do so
  PointOfInterestMain.defaultDiscovered = true -- if PoI has been discovered or not (like skyrim full vs bordered location icon)

	PointOfInterestMain.previousPos = nil -- used to refresh poi distances after traveling n units
end

-------------------------------------------------------------------------------
-- Called from C++ when the current game enters
function PointOfInterestMain:Enter()

-- Call load data only if no data is available (mainly, call load data only when gameplay starts first time, not when returning from paused state)
  if not PointOfInterestMain.nextID then
    PointOfInterestMain:LoadData()
  end

	local currentPos = Eternus.GameState:GetLocalPlayer():NKGetPosition()
	if PointOfInterestMain.previousPos == nil then
		PointOfInterestMain.previousPos = currentPos
	end
end

-------------------------------------------------------------------------------
-- Called from C++ when the game leaves it current mode
function PointOfInterestMain:Leave()
    PointOfInterestMain:SaveData()
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
		self:Debug("\n PointOfInterestMain:GetPointOfInterest - id: " .. poi.id .. ", poiID: " .. tostring(poiID) .. "\n")
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
	self:Debug("\nPointOfInterestMain:CreatePointOfInterest()\n")

  local poi = self:SpawnPointOfInterest(pos)

  if poi then
		self:Debug("\nPointOfInterestMain:CreatePointOfInterest(): new PoI created\n")

    poi.radius = (radius and radius or 1)

    poi.title = (title and title or self.defaultTitle)
    poi.description = (description and description or self.defaultDescription)

    poi.type = (self:PoITypeAllowed(poiType) and poiType or self.defaultType)

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
	self:Debug("\nPointOfInterestUI:RemovePointOfInterest(id) called\n")

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
	self:Debug("\nPointOfInterestUI:GetPointsOfInterest() called\n")

  local pois = self.pointsOfInterest

  -- each PoI's location is converted to a current distance.. or that probably needs to be done every tick, so it should probably happen somewhere else

  --local inPos = self.currentState.m_activeCamera:NKGetLocation() + (self.currentState.m_activeCamera:ForwardVector() * vec3.new(playerHeight))

  return pois
end


-- PoI gameobjects call this on restore, in order to make their existence known.
function PointOfInterestMain:RestorePointOfInterest(poi)
	if self:GetPointOfInterest(self.pointsOfInterest, poi.id) ~= true then
	  self.pointsOfInterest[#self.pointsOfInterest+1] = poi
  end
end

--- Check if certain PoI type is in the list of allowed types.
-- @param poiTypeToCheck PoI type to check.
function PointOfInterestMain:PoITypeAllowed(poiTypeToCheck)
	self:Debug("\nPointOfInterestUI:PoITypeAllowed(poiTypeToCheck) called\n")

  for i, poiType in ipairs(self.poiTypes) do
    if poiType.name == poiTypeToCheck then
      return true
    end
  end
  return false
end

--- Helper function to quickly spawn a GameObject by name with a given position and rotation.
-- Copied from Modes/TUGGameMode.lua.
-- @param position Position of the gameobject.
-- @param rotation Roration of the gameobject. Not used for now.
function PointOfInterestMain:SpawnPointOfInterest( position, rotation )
	self:Debug("\nPointOfInterestMain:SpawnPointOfInterest( position, rotation ) called\n")
	local obj = Eternus.GameObjectSystem:NKCreateGameObject("PointOfInterest", true)

  if obj then
		self:Debug("\nPointOfInterestMain:SpawnPointOfInterest - succeeded in creating PointOfInterest \n")

    obj:NKSetShouldRender(true, false)
    obj:NKSetPosition(position, false)
--	poi:NKSetRotation(rotation)  -- it doesn't move so rotation shouldn't matter, there's probably default value
    obj:NKPlaceInWorld(true, false)

--    poi:Init(self)

    return obj:NKGetInstance() -- you need to do this for now. Will be no more required after 0.6.6 or 0.6.7, hopefully
  else
		self:Debug("\nPointOfInterestMain:SpawnPointOfInterest - failed creating PointOfInterest \n")
    return nil
  end
end

--- Method called by PoI when it's near player.
-- @param poi The acking PoI itself
function PointOfInterestMain:InRangePoIAcking( poi )
	self:Debug("\nPointOfInterestUI:InRangePoIAcking( poi ) called\n")
end

--- Calculate a direction (in radians) from first position to a second position.
-- To be implemented.
-- @param posFrom First position - a place from where to calculate the direction.
-- @param posTo Second position - a place of which direction is to be calculated in relation to the first position.
function PointOfInterestMain:calculateDirection(posFrom, posTo)
  local fwd = Eternus.GameState.m_activeCamera:ForwardVector()

	-- calculate direction in degrees
  local direction = math.atan2(posFrom:z() - posTo:z() , posFrom:x() - posTo:x()) - math.atan2(fwd:z(), fwd:x())

	-- normalize the direction to be between [-math.pi, math.pi) ... or is it (-math.pi, math.pi]?
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

--- Load data from a file.
-- Not yet implemented.
function PointOfInterestMain:LoadData()
	self:Debug("\nPointOfInterestMain:LoadData()\n")
  PointOfInterestMain.nextID = 1
  PointOfInterestMain.pointsOfInterest = {}
end

--- Save data to a file.
-- Not yet implemented.
function PointOfInterestMain:SaveData()
  self:Debug("\nPointOfInterestMain:SaveData()\n")
end

function PointOfInterestMain:Debug(msg)
	if EternusEngine.mods.PointOfInterest.Mod.options.useDebug then
		NKPrint(msg)
	end
end
