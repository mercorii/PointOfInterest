--- @author Mercor 

include("Scripts/Core/Common.lua")

if PointOfInterestConsoleUI == nil then
--	PointOfInterestConsoleUI = EternusEngine.ModScriptClass.Subclass("PointOfInterestConsoleUI")
	PointOfInterestConsoleUI = EternusEngine.Class.Subclass("PointOfInterestConsoleUI")
end

-------------------------------------------------------------------------------
function PointOfInterestConsoleUI:Constructor(  )
  NKPrint("\n\nPointOfInterestConsoleUI:Constructor called\n\n")
end


-------------------------------------------------------------------------------
--- Initialize UI.
-- Called once from C++ at engine initialization time
function PointOfInterestConsoleUI:Initialize()
  NKPrint("\n\nPointOfInterestConsoleUI:Initialize called\n\n")
  
end

function PointOfInterestConsoleUI:Enter()
  NKPrint("\n\nPointOfInterestConsoleUI:Enter called\n\n")
  
  PointOfInterestConsoleUI:RegisterSlashCommands()
end

function PointOfInterestConsoleUI:Leave()
  NKPrint("\n\nPointOfInterestConsoleUI:Leave called\n\n")
  -- do something
end

function PointOfInterestConsoleUI:RegisterSlashCommands()

  -- if we haven't added the functions yet, add them now
  if not Eternus.GameState.ListPointsOfInterest then

  -- Register /commands
    Eternus.GameState:RegisterSlashCommand("CreatePointOfInterest", "CreatePointOfInterest")
    Eternus.GameState:RegisterSlashCommand("ListPointsOfInterest", "ListPointsOfInterest")
    Eternus.GameState:RegisterSlashCommand("RemovePointOfInterest", "RemovePointOfInterest")
    Eternus.GameState:RegisterSlashCommand("DistanceToPointOfInterest", "DistanceToPointOfInterest")
    Eternus.GameState:RegisterSlashCommand("DirectionToPointOfInterest", "DirectionToPointOfInterest")

    -- Create methods for /commands
    function Eternus.GameState:CreatePointOfInterest(args)
      NKPrint("\nCreatePointOfInterest custom slash command was called\n")
      if EternusEngine.mods.PointOfInterest.ConsoleUI then
        EternusEngine.mods.PointOfInterest.ConsoleUI:CreatePointOfInterest(args)
      end
    end

    function Eternus.GameState:ListPointsOfInterest(args)
      NKPrint("\nListPointsOfInterest custom slash command was called\n")
      if EternusEngine.mods.PointOfInterest.ConsoleUI then
        EternusEngine.mods.PointOfInterest.ConsoleUI:ListPointsOfInterest(args)
      end
    end

    function Eternus.GameState:RemovePointOfInterest(args)
      NKPrint("\nRemovePointOfInterest custom slash command was called\n")
      if EternusEngine.mods.PointOfInterest.ConsoleUI then
        EternusEngine.mods.PointOfInterest.ConsoleUI:RemovePointOfInterest(args)
      end
    end

    function Eternus.GameState:DirectionToPointOfInterest(args)
      NKPrint("\nDirectionToPointOfInterest custom slash command was called\n")
      if EternusEngine.mods.PointOfInterest.ConsoleUI then
        EternusEngine.mods.PointOfInterest.ConsoleUI:DirectionToPointOfInterest(args[1])
      end
    end

    function Eternus.GameState:DistanceToPointOfInterest(args)
      NKPrint("\nDistanceToPointOfInterest custom slash command was called\n")
      if EternusEngine.mods.PointOfInterest.ConsoleUI then
        EternusEngine.mods.PointOfInterest.ConsoleUI:DistanceToPointOfInterest(args[1])
      end
    end
  end
end

--- Helper function to write messages into the chat window.
-- @param message Message to write to chat. Can be either a string or a table containing strings.
function PointOfInterestConsoleUI:WriteMessageToChat(message)

  --	local uiContainer = self.state:NKGetUIContainer()
	local uiContainer = Eternus.GameStatePlaying:NKGetUIContainer()
	local miscUI = uiContainer:NKGetMiscellaneousUI()
  
  -- if message is actually table, expect its items to be strings and print them one at a time
  if type(message) == "table" then
    NKPrint("\nPointOfInterestConsoleUI:WriteMessageToChat(message) called, was a table:")
    for i, msg in ipairs(message) do
      NKPrint("\n" .. msg)
      miscUI:NKChatWindow_AddText(msg)
    end
    NKPrint("\n")
  else -- otherwise expect it to be string
    NKPrint("\nPointOfInterestConsoleUI:WriteMessageToChat(message) called with message: \n" .. message)
    miscUI:NKChatWindow_AddText(message)
  end
end

--- Creates a new PoI.
-- @param args Table containing options for the new PoI.
function PointOfInterestConsoleUI:CreatePointOfInterest(args)
  
  NKPrint("\nPointOfInterestConsoleUI:CreatePointOfInterest(args) called\n")
  
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
  
  local poi = EternusEngine.mods.PointOfInterest.Main:CreatePointOfInterest(pos, radius, title, description, poiType)
 
  if poi then
    self:WriteMessageToChat("PoI created: " .. poi:ToString())
  else
    self:WriteMessageToChat("PoI creation failed.")
  end
end

--- Removes point of interest.
-- @param args Table that is supposed to contain the id of the PoI to be removed as its first item.
function PointOfInterestConsoleUI:RemovePointOfInterest(args)
  NKPrint("\nPointOfInterestConsoleUI:RemovePointOfInterest(args) called\n")
  
  if #args >= 1 then
    if EternusEngine.mods.PointOfInterest.Main:RemovePointOfInterest(args[1]) then
      self:WriteMessageToChat("PoI " .. args[1] .. " succeeded\n")
    else
      self:WriteMessageToChat("PoI " .. args[1] .. " removal failed\n")
    end
  else
      self:WriteMessageToChat("PoI removal failed. Give PoI id as parameter. \n")
  end
end

--- List all PoIs.
function PointOfInterestConsoleUI:ListPointsOfInterest(args)
  NKPrint("\nPointOfInterestConsoleUI:ListPointsOfInterest(args) called\n")
  
  local pois = {}
  table.insert(pois, "PointsOfInterest: ")
  
  for i, poi in ipairs(EternusEngine.mods.PointOfInterest.Main:GetPointsOfInterest()) do
    table.insert(pois, " [" .. poi.id .. "] " .. poi.title)
  end

  self:WriteMessageToChat(pois)
end

--- Writes distance of given PoI from the player to console.
-- @param poiID ID of the PoI which distance from the player the method is about to print.
function PointOfInterestConsoleUI:DistanceToPointOfInterest(poiID)
  if poiID == nil then
    NKPrint("\n PointOfInterestConsoleUI:DistanceToPointOfInterest - no value given\n")
    return false
  end
  
  local poi = EternusEngine.mods.PointOfInterest.Main:GetPointOfInterest(poiID)
  if poi then
    local distance = poi:DistanceTo(Eternus.GameState:GetLocalPlayer():NKGetPosition())
--    self:WriteMessageToChat('Distance: ' .. string.format("%.2g", distance)) -- converts 0 to ~0.55
    self:WriteMessageToChat('Distance: ' .. distance)
  else 
    NKPrint("\n PointOfInterestConsoleUI:DistanceToPointOfInterest - Couldn't find PoI with id: " .. poiID .. "\n")
  end
end

--- Writes direction of given PoI from the position of players forward vector to console.
-- @param poiID ID of the PoI which direction from the player the method is about to print.
function PointOfInterestConsoleUI:DirectionToPointOfInterest(poiID)
    if poiID == nil then
    NKPrint("\n PointOfInterestConsoleUI:DirectionToPointOfInterest - no value given\n")
    return false
  end
  
  local poi = EternusEngine.mods.PointOfInterest.Main:GetPointOfInterest(poiID)
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
    NKPrint("\n PointOfInterestConsoleUI:DirectionToPointOfInterest - Couldn't find PoI with id: " .. poiID .. "\n")
  end
end

if EternusEngine.mods.PointOfInterest.ConsoleUI == nil then
  EternusEngine.mods.PointOfInterest.ConsoleUI = PointOfInterestConsoleUI.new()
end