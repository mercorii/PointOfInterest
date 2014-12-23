include("Scripts/Core/Common.lua")
include("Scripts/CL/UI/Container.lua")

local Windows = EternusEngine.UI.Windows

-------------------------------------------------------------------------------
if PointOfInterestCompass == nil then
  PointOfInterestCompass = CL_UIContainer.Subclass("PointOfInterestCompass")
end

-------------------------------------------------------------------------------
function PointOfInterestCompass:PostLoad(args)
  self.m_window = Windows:createWindow("TUGLook/StaticImage", "Compass")
  self.m_window:setProperty("BackgroundEnabled", "false")
  self.m_window:setProperty("FrameEnabled", "false")
  self.m_window:setProperty("Image", "PointOfInterest/CompassBG")


--  self.m_text = Windows:createWindow("TUGLook/StaticText")
--  self.m_window:addChild(self.m_text)
--  self.m_text:setArea(CEGUI.UDim(0.04, 0), CEGUI.UDim(0.04, 0), CEGUI.UDim(0.92, 0), CEGUI.UDim(0.92, 0))
--  self.m_text:setHeight(CEGUI.UDim(1, 0))
--  self.m_text:setProperty("HorzFormatting", "WordWrapLeftAligned")
--  self.m_text:setProperty("VertFormatting", "TopAligned")
--  self.m_text:setProperty("BackgroundEnabled", "false")
--  self.m_text:setProperty("FrameEnabled", "false")

  EternusEngine.UI.Layers.Gameplay:addChild(self.m_window)
end

-------------------------------------------------------------------------------
function PointOfInterestCompass:SetImageItem(item)
  self.m_window:setProperty("Image", item:GetIcon())
end

-------------------------------------------------------------------------------
--function PointOfInterestCompass:SetText(text)
--  self.m_text:setText(text)
--end
