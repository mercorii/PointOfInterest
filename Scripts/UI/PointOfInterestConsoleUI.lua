--- @author Mercor

include("Scripts/Core/Common.lua")

if PointOfInterestConsoleUI == nil then
--	PointOfInterestConsoleUI = EternusEngine.ModScriptClass.Subclass("PointOfInterestConsoleUI")
	PointOfInterestConsoleUI = EternusEngine.Class.Subclass("PointOfInterestConsoleUI")
end

-------------------------------------------------------------------------------
function PointOfInterestConsoleUI:Constructor(  )
	self:Debug("\n\nPointOfInterestConsoleUI:Constructor called\n\n")
end


-------------------------------------------------------------------------------
--- Initialize UI.
-- Called once from C++ at engine initialization time
function PointOfInterestConsoleUI:Initialize()
	self:Debug("\n\nPointOfInterestConsoleUI:Initialize called\n\n")

end

function PointOfInterestConsoleUI:Enter()
	self:Debug("\n\nPointOfInterestConsoleUI:Enter called\n\n")
end

function PointOfInterestConsoleUI:Leave()
	self:Debug("\n\nPointOfInterestConsoleUI:Leave called\n\n")
  -- do something
end

-- not sure what this function does.. in survival.lua it's used to register slash commands among other things..
function PointOfInterestConsoleUI:SetupInputSystem()
	self:Debug("\n\nPointOfInterestConsoleUI:SetupInputSystem called\n\n")

--	Eternus.World:NKGetKeybinds():NKRegisterNamedCommand("Create PoI", self, "CreatePointOfInterestBtn", KEY_ONCE)
--	Eternus.World:NKGetKeybinds():NKRegisterNamedCommand("Next PoI", self, "NextPointOfInterestBtn", KEY_ONCE)

--	Eternus.World:NKGetKeybinds():NKRegisterDirectCommand("O", self, "CreatePointOfInterestBtn", KEY_ONCE)

	self:RegisterSlashCommands()
end

function PointOfInterestConsoleUI:RegisterSlashCommands()

	self:Debug("\n\nPointOfInterestConsoleUI:RegisterSlashCommands called\n\n")

  -- if we haven't added the functions yet, add them now
--  if not Eternus.GameState.ListPointsOfInterest then

  -- Register /commands
    Eternus.GameState:RegisterSlashCommand("CreatePointOfInterest", self, "CreatePointOfInterest")
    Eternus.GameState:RegisterSlashCommand("ListPointsOfInterest", self, "ListPointsOfInterest")
    Eternus.GameState:RegisterSlashCommand("RemovePointOfInterest", self, "RemovePointOfInterest")
    Eternus.GameState:RegisterSlashCommand("DistanceToPointOfInterest", self, "DistanceToPointOfInterest")
    Eternus.GameState:RegisterSlashCommand("DirectionToPointOfInterest", self, "DirectionToPointOfInterest")

end

--- Helper function to write messages into the chat window.
-- @param message Message to write to chat. Can be either a string or a table containing strings.
function PointOfInterestConsoleUI:WriteMessageToChat(message)

  --	local uiContainer = self.state:NKGetUIContainer()
	local uiContainer = NKGetDeprecatedUIContainer()
	local miscUI = uiContainer:NKGetMiscellaneousUI()

  -- if message is actually table, expect its items to be strings and print them one at a time
  if type(message) == "table" then
		self:Debug("\nPointOfInterestConsoleUI:WriteMessageToChat(message) called, was a table:")
    for i, msg in ipairs(message) do
			self:Debug("\n" .. msg)
      miscUI:NKChatWindow_AddText(msg)
    end
		self:Debug("\n")
  else -- otherwise expect it to be string
		self:Debug("\nPointOfInterestConsoleUI:WriteMessageToChat(message) called with message: \n" .. message)
    miscUI:NKChatWindow_AddText(message)
  end
end

function PointOfInterestConsoleUI:CreatePointOfInterestBtn(down)
	if down then
		return
	end
	self:Debug("\nPointOfInterestConsoleUI:CreatePointOfInterestBtn(down) called.\n")
	self:WriteMessageToChat("PointOfInterestConsoleUI:CreatePointOfInterestBtn(down) called.")
end

function PointOfInterestConsoleUI:NextPointOfInterestBtn(down)
	if down then
		return
	end
	self:Debug("\nPointOfInterestConsoleUI:NextPointOfInterestBtn(down) called.\n")
	self:WriteMessageToChat("PointOfInterestConsoleUI:NextPointOfInterestBtn(down) called.")
end

--- Creates a new PoI.
-- @param args Table containing options for the new PoI.
function PointOfInterestConsoleUI:CreatePointOfInterest(args)

	self:Debug("\nPointOfInterestConsoleUI:CreatePointOfInterest(args) called\n")

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
	self:Debug("\nPointOfInterestConsoleUI:RemovePointOfInterest(args) called\n")

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
	self:Debug("\nPointOfInterestConsoleUI:ListPointsOfInterest(args) called\n")

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
		self:Debug("\n PointOfInterestConsoleUI:DistanceToPointOfInterest - no value given\n")
    return false
  end

  local poi = EternusEngine.mods.PointOfInterest.Main:GetPointOfInterest(poiID)
  if poi then
    local distance = poi:DistanceTo(Eternus.GameState:GetLocalPlayer():NKGetPosition())
--    self:WriteMessageToChat('Distance: ' .. string.format("%.2g", distance)) -- converts 0 to ~0.55
    self:WriteMessageToChat('Distance: ' .. distance)
  else
		self:Debug("\n PointOfInterestConsoleUI:DistanceToPointOfInterest - Couldn't find PoI with id: " .. poiID .. "\n")
  end
end

--- Writes direction of given PoI from the position of players forward vector to console.
-- @param poiID ID of the PoI which direction from the player the method is about to print.
function PointOfInterestConsoleUI:DirectionToPointOfInterest(poiID)
    if poiID == nil then
			self:Debug("\n PointOfInterestConsoleUI:DirectionToPointOfInterest - no value given\n")
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
    self:Debug("\n PointOfInterestConsoleUI:DirectionToPointOfInterest - Couldn't find PoI with id: " .. poiID .. "\n")
  end
end

function PointOfInterestConsoleUI:Debug(msg)
	if EternusEngine.mods.PointOfInterest.Mod.options.useDebug then
		NKPrint(msg)
	end
end
