include("Scripts/Core/Common.lua")
include("Scripts/Core/View.lua")

local Windows = EternusEngine.UI.Windows

-------------------------------------------------------------------------------
if PointOfInterestCompass == nil then
  PointOfInterestCompass = View.Subclass("PointOfInterestCompass")
end

-------------------------------------------------------------------------------
function PointOfInterestCompass:PostLoad(args)

  NKPrint("\n\nPointOfInterestCompass:PostLoad called\n\n")

  self.m_compass = self:GetChild("Compass")
  self.m_north = self:GetChild("Compass/North")
  self.m_east = self:GetChild("Compass/East")
  self.m_south = self:GetChild("Compass/South")
  self.m_west = self:GetChild("Compass/West")
  self.m_poi_button = self:GetChild("Compass/PoI Button")
  self.m_radar = self:GetChild("Compass/Radar")

  -- radar items
  self.m_items = {}
  self.m_pois = {}

  -- TODO: for each poi in poiMain add item to self.m_items
  -- TODO: register to poiMain, so that every time new poi is added, it's added to radar

  self.m_north:setPosition(CEGUI.UVector2(CEGUI.UDim(0, 0), CEGUI.UDim(0, 0)))

  -- debug window
  -- self.m_text = Windows:createWindow("TUGLook/StaticText")
  -- self.m_containerWindow:addChild(self.m_text)
  -- self.m_text:setArea(CEGUI.UDim(0.04, 0), CEGUI.UDim(0.04, 0), CEGUI.UDim(0.24, 0), CEGUI.UDim(0.24, 0))
  -- self.m_text:setHeight(CEGUI.UDim(1, 0))
  -- self.m_text:setProperty("HorzFormatting", "WordWrapLeftAligned")
  -- self.m_text:setProperty("VertFormatting", "TopAligned")
  -- self.m_text:setProperty("BackgroundEnabled", "false")
  -- self.m_text:setProperty("FrameEnabled", "false")
  --
  -- self.m_text:setText("testing")

	self.m_poi_button:subscribeEvent("MouseClick", function( args )
		NKPrint("PointOfInterestMod's ui text was clicked")
    if EternusEngine.mods.PointOfInterest.ConsoleUI then
		  EternusEngine.mods.PointOfInterest.ConsoleUI:WriteMessageToChat("Point Of Interest created.")
    end
    self:CreatePointOfInterest()
  end)

end

-------------------------------------------------------------------------------
function PointOfInterestCompass:Update( dt )
  -- TODO: fix update process to move North in the compass

  local playerPos = Eternus.GameState:GetLocalPlayer():NKGetPosition()
  local northPos = vec3.new(playerPos:x(), playerPos:y(), playerPos:z()+1.0)
  local northRadian = EternusEngine.mods.PointOfInterest.Main:calculateDirection(playerPos, northPos)


  local eastRadian = (((northRadian + math.pi/2) + math.pi) % (2*math.pi) - math.pi) / math.pi
  local southRadian = (((northRadian + math.pi) + math.pi) % (2*math.pi) - math.pi) / math.pi
  local westRadian = (((northRadian + math.pi/2*3) + math.pi) % (2*math.pi) - math.pi) / math.pi

  northRadian = ((northRadian + math.pi) % (2*math.pi) - math.pi) / math.pi

  -- Draw compass rose (cardinal directions)
  self.m_north:setPosition(CEGUI.UVector2(CEGUI.UDim(northRadian, 0), CEGUI.UDim(0, 0)))
  self.m_east:setPosition(CEGUI.UVector2(CEGUI.UDim(eastRadian, 0), CEGUI.UDim(0, 0)))
  self.m_south:setPosition(CEGUI.UVector2(CEGUI.UDim(southRadian, 0), CEGUI.UDim(0, 0)))
  self.m_west:setPosition(CEGUI.UVector2(CEGUI.UDim(westRadian, 0), CEGUI.UDim(0, 0)))

  -- Position items
  local dirDis = nil
  for i, poi_item in ipairs(self.m_items) do
    dirDis = EternusEngine.mods.PointOfInterest.Main:calculatePoIDirectionDistance(playerPos, poi_item.poi)
    if dirDis and dirDis.distance > 1 then
      poi_item.item:setPosition(CEGUI.UVector2(CEGUI.UDim(dirDis.direction / math.pi, 0), CEGUI.UDim(0, 0)))
    end
  end
end

-------------------------------------------------------------------------------
--- Create PoI (call poiMain to actually do it)
function PointOfInterestCompass:CreatePointOfInterest()
  NKPrint("PointOfInterestCompass:CreatePointOfInterest() called")
  local radius = 1.0

  local player = Eternus.GameState:GetLocalPlayer()
  local pos = player:NKGetPosition() -- player position
  local title = nil
  local description = nil
  local poiType = nil

  local poi = EternusEngine.mods.PointOfInterest.Main:CreatePointOfInterest(pos, radius, title, description, poiType)
  if poi then
    self:AddPointOfInterest(poi)
  end
  -- TODO: if PoI creation failed, show it somehow to user
end

-------------------------------------------------------------------------------
-- Add PoI to array and to radar
function PointOfInterestCompass:AddPointOfInterest(poi)
  NKPrint("PointOfInterestCompass:AddPointOfInterest() called")

  -- check that poi.id is not already in pois that compass is currently tracking
  for i, item in ipairs(self.m_items) do
    if item.poi.id == poi.id then
      return false
    end
  end

  self.m_pois[#self.m_pois+1] = poi

  -- add poi to radar
  local poi_item = EternusEngine.UI.Windows:createWindow("TUGLook/StaticImage")
  poi_item:setProperty("Area", "{{-1,0},{0,0},{-1,26},{0,26}}")
  poi_item:setProperty("FrameEnabled", "false")
  poi_item:setProperty("Image", "PoI-Icons/forest")
  poi_item:setProperty("MaxSize", "{{1,0},{1,0}}")
  poi_item:setProperty("BackgroundEnabled", "false")
  poi_item:setProperty("VerticalAlignment", "Centre")
  poi_item:setProperty("HorizontalAlignment", "Centre")
  self.m_radar:addChild(poi_item)

  self.m_items[#self.m_items+1] = {item = poi_item, poi = poi}

  return true
end

-------------------------------------------------------------------------------
--- Remove PoI from radar.
-- Returns boolean depending on the success.
function PointOfInterestCompass:RemovePointOfInterest(poi)
  NKPrint("PointOfInterestCompass:RemovePointOfInterest() called")

  for i, item in ipairs(self.m_items) do
    if item.poi.id == poi.id then
      table.remove(self.m_items, i)

      -- remove poi from radar
      self.radar:destroyChild(item.poi_item)

      return true
    end
  end

  return false
end

-------------------------------------------------------------------------------
-- event handler for poi added to main
function PointOfInterestCompass:Event_PoIAdded(poi)
  self:AddPointOfInterest(poi)
end

-------------------------------------------------------------------------------
-- event handler for poi removed from main
function PointOfInterestCompass:Event_PoIRemoved(poi)
  self:RemovePointOfInterest(poi)
end

-------------------------------------------------------------------------------
function PointOfInterestCompass:SetImageItem(item)
--  self.m_window:setProperty("Image", item:GetIcon())
end

-------------------------------------------------------------------------------
function PointOfInterestCompass:SetText(text)
--  self.m_text:setText(text)
end
