--- @author Mercor

include("Scripts/Core/Common.lua")

-------------------------------------------------------------------------------
if PointOfInterestMod == nil then
	PointOfInterestMod = EternusEngine.ModScriptClass.Subclass("PointOfInterestMod")
end

-------------------------------------------------------------------------------
-- Create namespace for the mod
if EternusEngine.mods == nil then
  EternusEngine.mods = {}
end

if EternusEngine.mods.PointOfInterest == nil then
  EternusEngine.mods.PointOfInterest = {}
end

-------------------------------------------------------------------------------
-- Include mod files
include("Scripts/PointOfInterestMain.lua")
include("Scripts/UI/PointOfInterestConsoleUI.lua")

-------------------------------------------------------------------------------
-- This is called on .new()
function PointOfInterestMod:Constructor(  )

	self:loadConfing()

	if EternusEngine.mods.PointOfInterest.Mod == nil then
		EternusEngine.mods.PointOfInterest.Mod = self
	end

	if EternusEngine.mods.PointOfInterest.Main == nil then
	  EternusEngine.mods.PointOfInterest.Main = PointOfInterestMain.new()
	end

	if Eternus.IsClient then
		if EternusEngine.mods.PointOfInterest.ConsoleUI == nil then
	  	EternusEngine.mods.PointOfInterest.ConsoleUI = PointOfInterestConsoleUI.new()
		end
	end

end

-------------------------------------------------------------------------------
-- Called once from C++ at engine initialization time
function PointOfInterestMod:Initialize()

	self:Debug("PointOfInterestMod:Initialize was just called.....\n")

  EternusEngine.mods.PointOfInterest.Main:Initialize()

	if Eternus.IsClient then

  	if self.useConsole and EternusEngine.mods.PointOfInterest.ConsoleUI then
    	EternusEngine.mods.PointOfInterest.ConsoleUI:Initialize()
  	end

		-- use ui
		if self.options.useCompass and Eternus.IsClient then
			-- Load CEGUI scheme
			CEGUI.SchemeManager:getSingleton():createFromFile("PointOfInterest.scheme")
			self.m_compassVisible = true
			self.m_pointOfInterestCompassView = require("Scripts.UI.PointOfInterestCompass").new("PointOfInterestCompassLayout.layout")
			EternusEngine.mods.PointOfInterest.CompassUI = self.m_pointOfInterestCompassView
		end

		if self.useConsole and Eternus.IsClient and EternusEngine.mods.PointOfInterest.ConsoleUI then
			EternusEngine.mods.PointOfInterest.ConsoleUI:SetupInputSystem()
		end

		if self.options.toggleCompassWithKey and self.options.toggleCompassKey then
			self:Debug("\nRegisterning key for toggling on/off compass (show/hide): " .. self.options.toggleCompassKey .. "\n")
			Eternus.World:NKGetKeybinds():NKRegisterDirectCommand(self.options.toggleCompassKey, self, "ToggleCompass", KEY_ONCE)
		end

	end
end

-------------------------------------------------------------------------------
-- Called from C++ when the current game enters (on game start: when 100% of world loaded)
function PointOfInterestMod:Enter()
  EternusEngine.mods.PointOfInterest.Main:Enter()

  if self.useConsole and EternusEngine.mods.PointOfInterest.ConsoleUI then
    EternusEngine.mods.PointOfInterest.ConsoleUI:Enter()
  end

	if self.m_pointOfInterestCompassView then
		self.m_pointOfInterestCompassView:Show()
	end
end

-------------------------------------------------------------------------------
-- Called from C++ when the game leaves it current mode
function PointOfInterestMod:Leave()
  EternusEngine.mods.PointOfInterest.Main:Leave()

  if self.useConsole and EternusEngine.mods.PointOfInterest.ConsoleUI then
    EternusEngine.mods.PointOfInterest.ConsoleUI:Leave()
  end

	if self.m_pointOfInterestCompassView then
		self.m_pointOfInterestCompassView:Hide()
	end
end


-------------------------------------------------------------------------------
-- Called from C++ every update tick
function PointOfInterestMod:Process(dt)
  EternusEngine.mods.PointOfInterest.Main:Process(dt)

	if self.m_compassVisible and self.m_pointOfInterestCompassView then
		self.m_pointOfInterestCompassView:Update(dt)
  end
end


function PointOfInterestMod:ToggleCompass(down)
	if down then
		return
	end

	self:Debug("PointOfInterestMod:ToggleCompass(down) called\n")

	if self.m_compassVisible then
		self:Debug("Hiding compass\n")
		self.m_pointOfInterestCompassView:Hide()
		self.m_compassVisible = false
	else
		self:Debug("Making compass visible\n")
		self.m_pointOfInterestCompassView:Show()
		self.m_compassVisible = true
	end
end

function PointOfInterestMod:loadConfing()
--	NKPrint("PointOfInterestMod:loadConfing() called\n")

	if self.options == nil then
		self.options = {}
	end

	local m_user_config = NKParseFile("config.txt")


--	NKPrint("Trying to read txt file parsed with NKParseFile\n")

	if m_user_config["ENABLE_DEBUG"] ~= 0 then
		self.options.useDebug = true
	else
		self.options.useDebug = false
	end

	if m_user_config["ENABLE_CHAT_CONSOLE_MESSAGES"] ~= 0 then
		self.options.useConsole = true
	else
		self.options.useConsole = false
	end

	if m_user_config["ENABLE_COMPASS"] ~= 0 then
		self.options.useCompass = true
	else
		self.options.useCompass = false
	end

	if m_user_config["LAYOUT"] then
		-- TODO: decide how to do layout changing
		self.options.layout = "Mouse Wizard" -- for now only one layout
	end

	if m_user_config["TOGGLE_COMPASS_WITH_KEY"] ~= 0 then
		self.options.toggleCompassWithKey = true
	else
		self.options.toggleCompassWithKey = false
	end

	if m_user_config["User Keybinds"] then

		if m_user_config["User Keybinds"] then
			self.options.toggleCompassKey = m_user_config["User Keybinds"]["TOGGLE_COMPASS"]
		end
	end
end

function PointOfInterestMod:Debug(msg)
	if self.options.useDebug then
		NKPrint(msg)
	end
end

EntityFramework:RegisterModScript(PointOfInterestMod)
