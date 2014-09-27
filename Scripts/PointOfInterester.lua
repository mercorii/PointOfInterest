--- @author Mercor 

include("Scripts/Core/Common.lua")

-- The main file for the Point Of Interest mod. Does most of the work.

if PointOfInterester == nil then
	PointOfInterester = EternusEngine.Class.Subclass("PointOfInterester")
end

PointOfInterester.MAX_VISIBLE_DISTANCE = 1000 -- TODO: this should be some better number

-- allowed PoI types -- TODO: this should probably come from a config file or something, probably not from gameobjects data file.
PointOfInterester.poiTypes = {
                    {name = "normal", description = ""},
                    {name = "danger"},
                    {name = "building"},
                    {name = "altar"},
                    {name = "resource"}
}

PointOfInterester.defaultType = PointOfInterester.poiTypes[1].name -- PoI always has type, users can add new types (acts like category)
PointOfInterester.defaultTitle = "Point of Interest" -- PoI always has title, even if only default one
PointOfInterester.defaultDescription = "" -- PoI can contain description, that UI can show if it likes to do so
PointOfInterester.defaultDiscovered = true -- if PoI has been discovered or not (like skyrim full vs bordered location icon)

PointOfInterester.nextID = 1 -- id for the next PoI
PointOfInterester.pointsOfInterest = {} -- where we hold all PoIs

--- Returns PoI with id poiID.
-- @param poiID Id of PoI to return.
function PointOfInterester:GetPointOfInterest(poiID)
  for i, poi in ipairs(self.pointsOfInterest) do
    NKPrint("\n PointOfInterester:GetPointOfInterest - id: " .. poi.id .. ", poiID: " .. tostring(poiID) .. "\n")
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
function PointOfInterester:CreatePointOfInterest(pos, radius, title, description, poiType, discovered)
  NKPrint("\nPointOfInterester:CreatePointOfInterest()\n")
  
  local poi = self:SpawnPointOfInterest(pos)

  if poi then
    NKPrint("\nPointOfInterester:CreatePointOfInterest(): new PoI created\n")

    poi.radius = (radius and radius or 1)

    poi.title = (title and title or self.defaultTitle)
    poi.description = (description and description or self.defaultDescription)
  
    poi.type = (self:PoITypeAllowed(poiType) and poiType or self.defaultType)
  
    poi.discovered = (discovered and discovered or self.defaultDiscovered)

    poi.id = self.nextID
    self.nextID = self.nextID + 1
  
    self.pointsOfInterest[#self.pointsOfInterest+1] = poi    
  end
  
  return poi
end

--- Remove the item from the list and delete the related gameobject.
-- Returns true if it succeeded in removing the item, false otherwise.
-- @param id The PoI to remove.
function PointOfInterester:RemovePointOfInterest(id)
  NKPrint("\nPointOfInterestUI:RemovePointOfInterest(id) called\n")
  
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
function PointOfInterester:GetPointsOfInterest()
  NKPrint("\nPointOfInterestUI:GetPointsOfInterest() called\n")
  
  local pois = self.pointsOfInterest
  
  -- each PoI's location is converted to a current distance.. or that probably needs to be done every tick, so it should probably happen somewhere else
  
  --local inPos = self.currentState.m_activeCamera:NKGetLocation() + (self.currentState.m_activeCamera:ForwardVector() * vec3.new(playerHeight))
  
  return pois
end

--- Check if certain PoI type is in the list of allowed types.
-- @param poiTypeToCheck PoI type to check.
function PointOfInterester:PoITypeAllowed(poiTypeToCheck)
  NKPrint("\nPointOfInterestUI:PoITypeAllowed(poiTypeToCheck) called\n")
  
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
function PointOfInterester:SpawnPointOfInterest( position, rotation )
  NKPrint("\nPointOfInterester:SpawnPointOfInterest( position, rotation ) called\n")
	local obj = Eternus.GameObjectSystem:cCreateGameObject("PointOfInterest", true)
  
  if obj then
    NKPrint("\nPointOfInterester:SpawnPointOfInterest - succeeded in creating PointOfInterest \n")
    
    obj:NKSetShouldRender(false, false)
    obj:NKSetPosition(position, false)
--	poi:NKSetRotation(rotation)  -- it doesn't move so rotation shouldn't matter, there's probably default value
    obj:NKPlaceInWorld(false, false, false)
  
--    poi:Init(self)

    return obj:NKGetInstance() -- you need to do this for now. Will be no more required after 0.6.6 or 0.6.7, hopefully
  else
    NKPrint("\nPointOfInterester:SpawnPointOfInterest - failed creating PointOfInterest \n")
    return nil
  end
end

--- Method called by PoI when it's near player.
-- @param poi The acking PoI itself
function PointOfInterester:InRangePoIAcking( poi )
  NKPrint("\nPointOfInterestUI:InRangePoIAcking( poi ) called\n")
end

--- Calculate a direction (in radians) from first position to a second position.
-- To be implemented.
-- @param posFrom First position - a place from where to calculate the direction.
-- @param posTo Second position - a place of which direction is to be calculated in relation to the first position.
function PointOfInterester:calculateDirection(posFrom, posTo)
  local fwd = Eternus.GameState.m_activeCamera:ForwardVector()
  return math.atan2(posFrom:z() - posTo:z() , posFrom:x() - posTo:x()) - math.atan2(fwd:z(), fwd:x())
end

--- Calculate a direction (in degrees) from first position to a second position.
-- To be implemented.
-- @param posFrom First position - a place from where to calculate the direction.
-- @param posTo Second position - a place of which direction is to be calculated in relation to the first position.
-- @return number.
function PointOfInterester:calculateDirectionInDegrees(posFrom, posTo)
  local fwd = Eternus.GameState.m_activeCamera:ForwardVector()
  return math.deg(math.atan2(posFrom:z() - posTo:z() , posFrom:x() - posTo:x()) - math.atan2(fwd:z(), fwd:x()))
end

--- Calculate a distance between two positions.
-- @param posFrom First position.
-- @param posTo Second position.
-- @return number.
function PointOfInterester:calculateDistance(posFrom, posTo)
  return math.abs((posFrom - posTo):NKLength())
end

--- Calculate direction and distance from pos to PoI position.
-- @param pos Position in relation to which we are calculating PoI's direction and distance.
-- @param poi PoI of which direction and distance from pos we are calculating.
-- @return table.
function PointOfInterester:calculatePoIDirectionDistance(pos, poi)
  NKPrint("\nPointOfInterester:calculatePoIDirectionDistance(pos, poi) called\n")
  
  local dirDis = {}
  
  local poiPos = poi:NKGetPosition() -- PoI position
  
  -- calculate distance between player and PoI
  dirDis.distance = self:calculateDistance(poiPos, pos)
    
--  if dirDis.distance > PointOfInterester.MAX_VISIBLE_DISTANCE + 100 then
--      return false -- means it should be deleted from the list as it's too far to be worth following for now
--  end

  -- calculate direction from player to PoI
  dirDis.direction = self:calculateDirection(pos, poiPos)
  return dirDis
  
end

--- Calculate direction and distance from pos to PoI positions.
-- @param pos Position in relation to which we are calculating PoIs' directions and distances.
-- @return table.
function PointOfInterester:calculateAllPoIDirectionDistance(pos)
  NKPrint("\nPointOfInterester:calculateAllPoIDirectionDistance(pos) called\n")
  
  local pois = {}
  
  for i, poi in ipairs(self.pointsOfInterest) do
    local dirDis = self:calculatePoIDirectinDistance(pos, poi)
    if dirDis then
      table.insert(pois, { obj = poi, 
                  direction = dirDis.direction, 
                  distance = dirDis.distance
                })
    end
  end
  
end


--- Load data from a file.
-- Not yet implemented.
function PointOfInterester:LoadData()
  NKPrint("\nPointOfInterester:LoadData()\n")
end

--- Save data to a file.
-- Not yet implemented.
function PointOfInterester:SaveData()
  NKPrint("\nPointOfInterester:SaveData()\n")
end

EternusEngine.PointOfInterester = PointOfInterester.new()