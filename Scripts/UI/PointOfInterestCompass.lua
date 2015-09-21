--- @author Mercor

include("Scripts/Core/Common.lua")
include("Scripts/UI/View.lua")

local Windows = EternusEngine.UI.Windows

-------------------------------------------------------------------------------
if PointOfInterestCompass == nil then
  PointOfInterestCompass = View.Subclass("PointOfInterestCompass")
end

-------------------------------------------------------------------------------
function PointOfInterestCompass:PostLoad(args)

  self:Debug("\n\nPointOfInterestCompass:PostLoad called\n\n")

  -- Decide which type image to use for which type
  -- TODO: Move this to config file on later point
  self.m_type_images = {
    {name = "forest", 		imageName = "PoI-Icons/forest"},
    {name = "panda", 			imageName = "PoI-Icons/panda"},
    {name = "lighthouse", imageName = "PoI-Icons/lighthouse"},
    {name = "triforce", 	imageName = "PoI-Icons/triforce"},
    {name = "sheep", 			imageName = "PoI-Icons/sheep"}
  }
  self.m_default_type_image = "PoI-Icons/forest"

  self:CreateInputMappingContext()

  self:InitElements()

  self:RegisterEvents()
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

  local nearest = nil
  local distNearest = nil

  local target = nil
  local targetOffset = nil

  for i, poi_item in ipairs(self.m_items) do
    if poi_item.poi then
      dirDis = EternusEngine.mods.PointOfInterest.Main:calculatePoIDirectionDistance(playerPos, poi_item.poi)
      if dirDis then
        if dirDis.distance > poi_item.poi.radius then
  --      local fwd = Eternus.GameState.m_activeCamera:ForwardVector()
  --      self.m_text:setText("pos: (" .. playerPos:x() .. "," .. playerPos:z() .. "), \npoiPos: (" .. poi_item.poi:NKGetPosition():x() .. "," .. poi_item.poi:NKGetPosition():z() .. "), \nfwd: (" .. fwd:x() .. "," .. fwd:z() .. "), \ndirDis.direction: " .. dirDis.direction .. ", \ncompass position: " .. (dirDis.direction / math.pi))

          -- Convert PoI direction in radians to a value in range [-1, 1].
          -- Only items with value in range [-0.5, 0.5] are shown in compass.
          -- Others are behind player's compass view (of 180 degrees), and are not shown.
          local compassX = dirDis.direction / math.pi
          local itemOffset = math.abs(compassX)

          -- see if we are targeting the compass item (if item is at the center, and it's the very centermost item)
          if itemOffset < 0.03 and (target == nil or targetOffset > itemOffset) then
            target = poi_item.poi
            targetOffset = itemOffset
          end

          -- show compass item on compass
          poi_item.item:setPosition(CEGUI.UVector2(CEGUI.UDim(compassX, 0), CEGUI.UDim(0, 0)))
        else -- if user is inside PoI radius
          poi_item.item:setPosition(CEGUI.UVector2(CEGUI.UDim(-20, 0), CEGUI.UDim(0, 0)))
          if nearest == nil or distNearest > dirDis.distance then
            nearest = poi_item.poi
            distNearest = dirDis.distance
          end
        end
      end
    end
  end

  if nearest then
    if self.m_poi_id_in_location_scroll ~= nearest.id then
      self:ShowLocationScroll(nearest)
    end
  else
    self:HideLocationScroll()
  end

  if target then
    if self.m_poi_id_in_target_poi_label ~= target.id then
      self:ShowTargetPoILabel(target)
    end
  else
    self:HideTargetPoILabel()
  end
end


function PointOfInterestCompass:InitElements()
  self.m_compass = self:GetChild("Compass")
  self.m_north = self:GetChild("Compass/North")
  self.m_east = self:GetChild("Compass/East")
  self.m_south = self:GetChild("Compass/South")
  self.m_west = self:GetChild("Compass/West")
  self.m_options_button = self:GetChild("Compass/PoI Button")
  self.m_radar = self:GetChild("Compass/Radar")

  -- target poi label
  self.m_target_poi_label = self:GetChild("Compass/PoI Label")
  self.m_target_poi_label:setProperty("Visible", "false")
  self.m_target_poi_label_visible = false
  self.m_poi_id_in_target_poi_label = nil

  -- location scroll
  self.m_location_scroll = self:GetChild("Location Scroll")
  self.m_location_scroll:setProperty("Visible", "false")
  self.m_location_scroll_visible = false
  self.m_poi_id_in_location_scroll = nil

  self.m_location_scroll_text = self:GetChild("Location Scroll/Label")
  self.m_location_scroll_text:setText("")

  -- options
  self.m_options_window = self:GetChild("Options Window")
  self.m_options_window:setProperty("Visible", "false")
  self.m_options_window_visible = false


  -- options > create
  self.m_create_poi_button = self:GetChild("Options Window/Options Container/Create PoI Button")
  self.m_close_options_window_button = self:GetChild("Options Window/Header/Close Button")

  -- options > create > fields
  self.m_title_field = self:GetChild("Options Window/Options Container/Title Field/Editbox")
  self.m_type_field = self:GetChild("Options Window/Options Container/Type Field/Editbox")
  self.m_new_poi_type = nil
  self.m_description_field = self:GetChild("Options Window/Options Container/Description Field/Editbox")

  -- options > create > type buttons
  self.m_type_sheep_button = self:GetChild("Options Window/Options Container/Icon Picker/Sheep Button")
  self.m_type_triforce_button = self:GetChild("Options Window/Options Container/Icon Picker/Triforce Button")
  self.m_type_panda_button = self:GetChild("Options Window/Options Container/Icon Picker/Panda Button")
  self.m_type_lighthouse_button = self:GetChild("Options Window/Options Container/Icon Picker/Lighthouse Button")
  self.m_type_forest_button = self:GetChild("Options Window/Options Container/Icon Picker/Forest Button")

  -- options > list pois
  self.m_list_tab = self:GetChild("List PoIs Window")
  self.m_list_tab:setProperty("Visible", "false")

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

end

function PointOfInterestCompass:RegisterEvents()
  self.m_options_button:subscribeEvent("MouseClick", function( args )
--    self:Debug("PointOfInterestMod's options button was clicked")
--    if EternusEngine.mods.PointOfInterest.ConsoleUI then
--		  EternusEngine.mods.PointOfInterest.ConsoleUI:WriteMessageToChat("Point Of Interest options btn clicked.")
--    end

    if self.m_options_window_visible then
      self:HideOptionsWindow()
    else
      self:ShowOptionsWindow()
    end
  end)

  self.m_close_options_window_button:subscribeEvent("MouseClick", function( args )
    self:Debug("PointOfInterestMod's close options button was clicked")
    if EternusEngine.mods.PointOfInterest.ConsoleUI then
      EternusEngine.mods.PointOfInterest.ConsoleUI:WriteMessageToChat("Point Of Interest options's x btn clicked.")
    end
    self:HideOptionsWindow()
  end)

  self.m_create_poi_button:subscribeEvent("MouseClick", function( args )
    self:Debug("PointOfInterestMod's create poi button was clicked")
    if EternusEngine.mods.PointOfInterest.ConsoleUI then
      EternusEngine.mods.PointOfInterest.ConsoleUI:WriteMessageToChat("Point Of Interest created.")
    end
    self:CreatePointOfInterest()
    self:HideOptionsWindow()
  end)

  self.m_type_sheep_button:subscribeEvent("MouseClick", function( args ) self:SetNewPoIType("sheep") end) -- Sheep
  self.m_type_panda_button:subscribeEvent("MouseClick", function( args ) self:SetNewPoIType("panda") end) -- danger
  self.m_type_triforce_button:subscribeEvent("MouseClick", function( args ) self:SetNewPoIType("triforce") end) -- Spiritual location
  self.m_type_forest_button:subscribeEvent("MouseClick", function( args ) self:SetNewPoIType("forest") end) -- Landmark
  self.m_type_lighthouse_button:subscribeEvent("MouseClick", function( args ) self:SetNewPoIType("lighthouse") end) -- Building

end

-------------------------------------------------------------------------------
--- Create PoI (call poiMain to actually do it)
function PointOfInterestCompass:CreatePointOfInterest()
  self:Debug("PointOfInterestCompass:CreatePointOfInterest() called")
  local radius = nil

  local player = Eternus.GameState:GetLocalPlayer()
  local pos = player:NKGetPosition() -- player position

  local title = self.m_title_field:getText()
  local description = self.m_description_field:getText()
  local poiType = self.m_new_poi_type

  local poi = EternusEngine.mods.PointOfInterest.Main:CreatePointOfInterest(pos, radius, title, description, poiType)
  if poi then
    self:AddPointOfInterest(poi)
  end
  -- TODO: if PoI creation failed, show it somehow to user
end

-------------------------------------------------------------------------------
-- Add PoI to array and to radar
function PointOfInterestCompass:AddPointOfInterest(poi)
  self:Debug("PointOfInterestCompass:AddPointOfInterest() called")

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
  poi_item:setProperty("Image", self:ResolveTypeImage(poi.type.name))
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
  self:Debug("PointOfInterestCompass:RemovePointOfInterest() called")

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

-------------------------------------------------------------------------------
--- Set the poi type for any new poi to be created
-- @param typeName Name of the type
function PointOfInterestCompass:SetNewPoIType( typeName )
  local type = EternusEngine.mods.PointOfInterest.Main:getPoIType(typeName)
  self.m_type_field:setText(type.title)
  self.m_new_poi_type = type.name
end

-------------------------------------------------------------------------------
--- Set the poi type for any new poi to be created
-- @param typeName Name of the type
function PointOfInterestCompass:ResolveTypeImage( typeName )
  for i, type in ipairs(self.m_type_images) do
    if type.name == typeName then
      return type.imageName
    end
  end

  return self.m_default_type_image
end

-------------------------------------------------------------------------------
--- Public method for allowing other mods to make compass visible (i.e. when slotting compass item)
function PointOfInterestCompass:ShowCompass()
  -- TODO: do things necessary to make compass visible
  self:Show()
end

-------------------------------------------------------------------------------
--- Public method for allowing other mods to make compass hidden (i.e when unslotting compass item)
function PointOfInterestCompass:HideCompass()
  -- TODO: do things necessary to hide compass
  self:Hide()
end

-------------------------------------------------------------------------------
--- Public method for allowing other mods to make compass visible (i.e. when slotting compass item)
function PointOfInterestCompass:ShowLocationScroll(poi)
  self.m_poi_id_in_location_scroll = poi.id
  self.m_location_scroll_visible = true
  self.m_location_scroll:setProperty("Visible", "true")
  self.m_location_scroll_text:setText(poi.title)
end

-------------------------------------------------------------------------------
--- Public method for allowing other mods to make compass hidden (i.e when unslotting compass item)
function PointOfInterestCompass:HideLocationScroll()
  self.m_location_scroll:setProperty("Visible", "false")
  self.m_location_scroll_text:setText("")
  self.m_location_scroll_visible = false
  self.m_poi_id_in_location_scroll = nil
end

-------------------------------------------------------------------------------
--- Public method for allowing other mods to make compass's target poi label visible
function PointOfInterestCompass:ShowTargetPoILabel(poi)
  self.m_poi_id_in_target_poi_label = poi.id
  self.m_target_poi_label_visible = true
  self.m_target_poi_label:setProperty("Visible", "true")
  self.m_target_poi_label:setText(poi.title)
end

-------------------------------------------------------------------------------
--- Public method for allowing other mods to make compass's target poi label hidden
function PointOfInterestCompass:HideTargetPoILabel()
  self.m_target_poi_label:setProperty("Visible", "false")
  self.m_target_poi_label:setText("")
  self.m_target_poi_label_visible = false
  self.m_poi_id_in_target_poi_label = nil
end

-------------------------------------------------------------------------------
--- Public method for allowing other mods to make compass options window visible
function PointOfInterestCompass:ShowOptionsWindow()

  self.m_options_window_visible = true
  self.m_options_window:setProperty("Visible", "true")

  self:GrabInputMappingContext()
end

-------------------------------------------------------------------------------
--- Public method for allowing other mods to make compass options window hidden
function PointOfInterestCompass:HideOptionsWindow()

  self.m_options_window:setProperty("Visible", "false")
  self.m_options_window_visible = false

  self:ReleaseInputMappingContext()
end

function PointOfInterestCompass:CreateInputMappingContext()
  -- this kind of in wrong place but who cares
  Eternus.World:NKGetKeybinds():NKRegisterNamedCommand("Toggle Mouse Mode", self, "ToggleMouseMode", KEY_ONCE)

  self.m_optionsContext = InputMappingContext.new("PointOfInterest > Options")

  self.m_optionsContext:NKSetInputPropagation(false)

  self.m_optionsContext:NKRegisterNamedCommand("Return to Menu", self, "HideOptionsWindow", KEY_ONCE)
end

function PointOfInterestCompass:GrabInputMappingContext()
  Eternus.InputSystem:NKPushInputContext(self.m_optionsContext)
end

function PointOfInterestCompass:ReleaseInputMappingContext()
  Eternus.InputSystem:NKRemoveInputContext(self.m_optionsContext)
end

function PointOfInterestCompass:ToggleMouseMode(down)
  if down then
    return
  end

  if Eternus.InputSystem:NKIsMouseGrabbed() then
    Eternus.InputSystem:NKReleaseMouseInput()
    Eternus.InputSystem:NKShowMouse()
    Eternus.InputSystem:NKCenterMouse()
  else
    Eternus.InputSystem:NKHideMouse()
    Eternus.InputSystem:NKGrabMouseInput()
  end
end

function PointOfInterestCompass:Debug(msg)
	if EternusEngine.mods.PointOfInterest.Mod.options.useDebug then
		NKPrint(msg .. "\n")
	end
end

return PointOfInterestCompass
