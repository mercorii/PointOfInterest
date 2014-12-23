-- The idea of this file is just to be the entry point for the mod.
-- In ideal world this file wouldn't be needed.

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

-------------------------------------------------------------------------------
-- Include mod files
include("Scripts/PointOfInterestMain.lua")
include("Scripts/UI/PointOfInterestConsoleUI.lua")

-------------------------------------------------------------------------------
-- This is called on .new() ?
function PointOfInterestMod:Constructor(  )
		CEGUI.SchemeManager:getSingleton():createFromFile("PointOfInterest.scheme")
end

-------------------------------------------------------------------------------
-- Called once from C++ at engine initialization time
function PointOfInterestMod:Initialize()
  self.useConsole = true

  EternusEngine.mods.PointOfInterest.Main:Initialize()

  if self.useConsole then
    EternusEngine.mods.PointOfInterest.ConsoleUI:Initialize()
  end

	-- use ui
	self.cl_debuggingBox = CL_DebuggingBox.new("SurvivalLayout.layout")
	self.cl_debuggingBox:SetPosition(0.8, 0.0)
	self.cl_debuggingBox:SetSize(0.2, 0.2)
	self.cl_debuggingBox:SetText("Here! I'm over here! Notice me!")
end

-------------------------------------------------------------------------------
-- Called from C++ when the current game enters
function PointOfInterestMod:Enter()
  EternusEngine.mods.PointOfInterest.Main:Enter()

  if self.useConsole then
    EternusEngine.mods.PointOfInterest.ConsoleUI:Enter()
  end

	self.cl_debuggingBox:Show()
end

-------------------------------------------------------------------------------
-- Called from C++ when the game leaves it current mode
function PointOfInterestMod:Leave()
  EternusEngine.mods.PointOfInterest.Main:Leave()

  if self.useConsole then
    EternusEngine.mods.PointOfInterest.ConsoleUI:Leave()
  end

	self.cl_debuggingBox:Hide()
end


-------------------------------------------------------------------------------
-- Called from C++ every update tick
function PointOfInterestMod:Process(dt)
  EternusEngine.mods.PointOfInterest.Main:Process(dt)
end

EntityFramework:RegisterModScript(PointOfInterestMod)
