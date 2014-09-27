--- @author Mercor 

include("Scripts/Core/Common.lua")
include("Scripts/PointOfInterester.lua")

if PointOfInterestUI == nil then
	PointOfInterestUI = EternusEngine.Class.Subclass("PointOfInterestUI")
end

--- Initialize UI.
function PointOfInterestUI:Init()
  
  -- Register /commands
--  Eternus.GameStatePlaying:RegisterSlashCommand("CreatePointOfInterest", "CreatePointOfInterest")
--  Eternus.GameStatePlaying:RegisterSlashCommand("ListPointsOfInterest", "ListPointsOfInterest")
--  Eternus.GameStatePlaying:RegisterSlashCommand("RemovePointOfInterest", "RemovePointOfInterest")
--  Eternus.GameStatePlaying:RegisterSlashCommand("DistanceToPointOfInterest", "DistanceToPointOfInterest")
--  Eternus.GameStatePlaying:RegisterSlashCommand("DirectionToPointOfInterest", "DirectionToPointOfInterest")

  -- Create methods for /commands
--  function Eternus.GameState:CreatePointOfInterest(args)
--    NKPrint("\nCreatePointOfInterest custom slash command was called\n")
--    if EternusEngine.PointOfInterestUI then
--      EternusEngine.PointOfInterestUI:CreatePointOfInterest(args)
--    end
--  end

--  function Eternus.GameState:ListPointsOfInterest(args)
--    NKPrint("\nListPointsOfInterest custom slash command was called\n")
--    if EternusEngine.PointOfInterestUI then
--      EternusEngine.PointOfInterestUI:ListPointsOfInterest(args)
--    end
--  end

--  function Eternus.GameState:RemovePointOfInterest(args)
--    NKPrint("\nRemovePointOfInterest custom slash command was called\n")
--    if EternusEngine.PointOfInterestUI then
--      EternusEngine.PointOfInterestUI:RemovePointOfInterest(args)
--    end
--  end

--  function Eternus.GameState:DirectionToPointOfInterest(args)
--    NKPrint("\nDirectionToPointOfInterest custom slash command was called\n")
--    if EternusEngine.PointOfInterestUI then
--      EternusEngine.PointOfInterestUI:DirectionToPointOfInterest(args[1])
--    end
--  end

--  function Eternus.GameState:DistanceToPointOfInterest(args)
--    NKPrint("\nDistanceToPointOfInterest custom slash command was called\n")
--    if EternusEngine.PointOfInterestUI then
--      EternusEngine.PointOfInterestUI:DistanceToPointOfInterest(args[1])
--    end
--  end
end

--- Helper function to write messages into the chat window.
-- @param message Message to write to chat. Can be either a string or a table containing strings.
function PointOfInterestUI:WriteMessageToChat(message)

  --	local uiContainer = self.state:NKGetUIContainer()
	local uiContainer = Eternus.GameStatePlaying:NKGetUIContainer()
	local miscUI = uiContainer:NKGetMiscellaneousUI()
  
  -- if message is actually table, expect its items to be strings and print them one at a time
  if type(message) == "table" then
    NKPrint("\nPointOfInterestUI:WriteMessageToChat(message) called, was a table:")
    for i, msg in ipairs(message) do
      NKPrint("\n" .. msg)
      miscUI:NKChatWindow_AddText(msg)
    end
    NKPrint("\n")
  else -- otherwise expect it to be string
    NKPrint("\nPointOfInterestUI:WriteMessageToChat(message) called with message: \n" .. message)
    miscUI:NKChatWindow_AddText(message)
  end
end

--- Creates a new PoI.
-- @param args Table containing options for the new PoI.
function PointOfInterestUI:CreatePointOfInterest(args)
  
  NKPrint("\nPointOfInterestUI:CreatePointOfInterest(args) called\n")
  
  local title = nil
  local description = nil
  local poiType = nil
  
  -- get title, description and type from args
  if args then  
    for i, value in ipairs(args) do
      if i == 1 then
        title = value
      elseif i == 2 then
        description = value
      elseif i == 3 then
        poiType = value
      end
    end
  end
  
  local radius = 1.0
  
  local player = Eternus.GameState:GetLocalPlayer()
  local pos = player:NKGetPosition() -- player position
  
  local poi = EternusEngine.PointOfInterester:CreatePointOfInterest(pos, radius, title, description, poiType)
 
  if poi then
    self:WriteMessageToChat("PoI created: " .. poi:ToString())
  else
    self:WriteMessageToChat("PoI creation failed.")
  end
end

--- Removes point of interest.
-- @param args Table that is supposed to contain the id of the PoI to be removed as its first item.
function PointOfInterestUI:RemovePointOfInterest(args)
  NKPrint("\nPointOfInterestUI:RemovePointOfInterest(args) called\n")
  
  if #args >= 1 then
    if EternusEngine.PointOfInterester:RemovePointOfInterest(args[1]) then
      self:WriteMessageToChat("PoI " .. args[1] .. " succeeded\n")
    else
      self:WriteMessageToChat("PoI " .. args[1] .. " removal failed\n")
    end
  else
      self:WriteMessageToChat("PoI removal failed. Give PoI id as parameter. \n")
  end
end

--- List all PoIs.
function PointOfInterestUI:ListPointsOfInterest(args)
  NKPrint("\nPointOfInterestUI:ListPointsOfInterest(args) called\n")
  
  local pois = {}
  table.insert(pois, "PointsOfInterest: ")
  
  for i, poi in ipairs(EternusEngine.PointOfInterester:GetPointsOfInterest()) do
    table.insert(pois, " [" .. poi.id .. "] " .. poi.title)
  end

  self:WriteMessageToChat(pois)
end

--- Writes distance of given PoI from the player to console.
-- @param poiID ID of the PoI which distance from the player the method is about to print.
function PointOfInterestUI:DistanceToPointOfInterest(poiID)
  if poiID == nil then
    NKPrint("\n PointOfInterestUI:DistanceToPointOfInterest - no value given\n")
    return false
  end
  
  local poi = EternusEngine.PointOfInterester:GetPointOfInterest(poiID)
  if poi then
    local distance = poi:DistanceTo(Eternus.GameState:GetLocalPlayer():NKGetPosition())
--    self:WriteMessageToChat('Distance: ' .. string.format("%.2g", distance)) -- converts 0 to ~0.55
    self:WriteMessageToChat('Distance: ' .. distance)
  else 
    NKPrint("\n PointOfInterestUI:DistanceToPointOfInterest - Couldn't find PoI with id: " .. poiID .. "\n")
  end
end

--- Writes direction of given PoI from the position of players forward vector to console.
-- @param poiID ID of the PoI which direction from the player the method is about to print.
function PointOfInterestUI:DirectionToPointOfInterest(poiID)
    if poiID == nil then
    NKPrint("\n PointOfInterestUI:DirectionToPointOfInterest - no value given\n")
    return false
  end
  
  local poi = EternusEngine.PointOfInterester:GetPointOfInterest(poiID)
  if poi then
    local direction = poi:DirectionFromInDegrees(Eternus.GameState:GetLocalPlayer():NKGetPosition())
    local string = ""
    if direction > 0 then
      string = "Direction: " .. math.abs(direction) .. " degrees to right."
    elseif direction < 0 then
      string = "Direction: " .. math.abs(direction) .. " degrees to left."
    else
      string = "Direction: straight."
    end
    self:WriteMessageToChat(string)
  else 
    NKPrint("\n PointOfInterestUI:DirectionToPointOfInterest - Couldn't find PoI with id: " .. poiID .. "\n")
  end
end

EternusEngine.PointOfInterestUI = PointOfInterestUI.new()

EternusEngine.PointOfInterestUI:Init()