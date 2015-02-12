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
include("Scripts/UI/PointOfInterestCompass.lua")

-------------------------------------------------------------------------------
-- This is called on .new() ?
function PointOfInterestMod:Constructor(  )
	NKPrint("PointOfInterestMod:Constructor was just called.....\n")

	-- Load CEGUI scheme
	CEGUI.SchemeManager:getSingleton():createFromFile("PointOfInterest.scheme")
end

-------------------------------------------------------------------------------
-- Called once from C++ at engine initialization time
function PointOfInterestMod:Initialize()
	NKPrint("PointOfInterestMod:Initialize was just called.....\n")
  self.useConsole = true

  EternusEngine.mods.PointOfInterest.Main:Initialize()

  if self.useConsole then
    EternusEngine.mods.PointOfInterest.ConsoleUI:Initialize()
  end

	-- use ui
	self.m_pointOfInterestCompassView = PointOfInterestCompass.new("PointOfInterestCompassLayout.layout")
	EternusEngine.mods.PointOfInterest.CompassUI = self.m_pointOfInterestCompassView

	if self.useConsole then
		EternusEngine.mods.PointOfInterest.ConsoleUI:SetupInputSystem()
	end
end

function PointOfInterestMod:SetupInputSystem()
	NKPrint("PointOfInterestMod:SetupInputSystem was just called.....\n")

	-- if self.useConsole then
	-- 	EternusEngine.mods.PointOfInterest.ConsoleUI:SetupInputSystem()
	-- end
end

-------------------------------------------------------------------------------
-- Called from C++ when the current game enters (on game start: when 100% of world loaded)
function PointOfInterestMod:Enter()
  EternusEngine.mods.PointOfInterest.Main:Enter()

  if self.useConsole then
    EternusEngine.mods.PointOfInterest.ConsoleUI:Enter()
  end

	self.m_pointOfInterestCompassView:Show()
end

-------------------------------------------------------------------------------
-- Called from C++ when the game leaves it current mode
function PointOfInterestMod:Leave()
  EternusEngine.mods.PointOfInterest.Main:Leave()

  if self.useConsole then
    EternusEngine.mods.PointOfInterest.ConsoleUI:Leave()
  end

	self.m_pointOfInterestCompassView:Hide()
end


-------------------------------------------------------------------------------
-- Called from C++ every update tick
function PointOfInterestMod:Process(dt)
  EternusEngine.mods.PointOfInterest.Main:Process(dt)

	if self.m_pointOfInterestCompassView then
		self.m_pointOfInterestCompassView:Update(dt)
  end
end

EntityFramework:RegisterModScript(PointOfInterestMod)
