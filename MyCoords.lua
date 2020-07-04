--[[ Updater local variables --]]
local zone = nil -- Allows us to check for proper zone below
local TimeSinceLastUpdate = 0 -- tracking update time, don't want to update every single refresh
local function UpdateCoordinates(self, elapsed)
    if zone ~= GetRealZoneText() then -- ~= is string not equal
	zone = GetRealZoneText()
  	SetMapToCurrentZone() -- allows AddOn to see current zone
    end
     TimeSinceLastUpdate = TimeSinceLastUpdate + elapsed
 	if TimeSinceLastUpdate > .5 then	
     	    TimeSinceLastUpdate = 0
   	    local posX, posY = GetPlayerMapPosition("player");		
 	    local x = math.floor(posX * 10000)/100
	    local y = math.floor(posY*10000)/100
	    MyCoordsFontString:SetText("("..x..", "..y..")")
        MyCoordsFontString:SetTextColor(fr,fg,fb,fa) -- set initial color values
 	end	
end
 
function MyCoords_OnLoad(self, event,...) 
    self:RegisterEvent("ADDON_LOADED")	

    --[[ Allowing to be dragged --]]
    self:SetMovable(true)
    self:EnableMouse(true)
    self:RegisterForDrag("LeftButton")
    self:SetScript("OnDragStart",self.StartMoving)
    self:SetScript("OnDragStop",self.StopMovingOrSizing)

    --[[ Makes Draggable Frame Visible --]]
    self:SetPoint("CENTER"); self:SetWidth(64); self:SetHeight(20);
    bgtex = self:CreateTexture("ARTWORK");
    bgtex:SetAllPoints();
    bgtex:SetTexture(0,0.1,0.1); bgtex:SetAlpha(0.5);

end
function MyCoords_OnEvent(self, event, ...)
     if event == "ADDON_LOADED" and ... == "MyCoords" then
         self:UnregisterEvent("ADDON_LOADED")		
	     MyCoords:SetSize(100, 50)
            MyCoords:SetPoint("TOP", "Minimap", "LEFT", -65, 25)
    	    MyCoords:SetScript("OnUpdate", UpdateCoordinates)
	     local coordsFont = MyCoords:CreateFontString("MyCoordsFontString", "ARTWORK", "GameFontNormal")
 	    coordsFont:SetPoint("CENTER", "MyCoords", "CENTER", 0, 0)
	    coordsFont:Show()
 	    MyCoords:Show()		
    end
end

--[[ Color for the frame and the text --]]
fr,fg,fb,fa = 1,1,1,1; -- default values for font, white with full opacity

local function MyCoords_ShowColorPicker(r,g,b,a, changedCallback)
    ColorPickerFrame:SetColorRGB(r,g,b); -- set initial RGB values
    ColorPickerFrame.hasOpacity, ColorPickerFrame.opacity = (a ~= nil), a; -- set initial opacity
    ColorPickerFrame.previousValues = {r,g,b,a};
    ColorPickerFrame.func, ColorPickerFrame.opacityFunc, ColorPickerFrame.cancelFunc = changedCallback, changedCallback, changedCallback; -- set new default callbacks
    ColorPickerFrame:Show();
end
local function MyCoords_ColorCallback(restore)
    local newR, newG, newB, newA;
    if restore then
        -- The user bailed, extract old color from ShowColorPicker table
        newR, newG, newB, newA = unpack(restore);
    else
        -- something changed
        newA, newR, newG, newB = OpacitySliderFrame:GetValue(), ColorPickerFrame:GetColorRGB();
    end

    -- update local variables
    fr, fg, fb, fa = newR, newG, newB, newA;
    -- update UI elements using this color
    MyCoordsFontString:SetTextColor(newR,newG,newB,newA);
end

--[[ Event handler for clicks --]]
function MyCoords_OnMouseDown(self, button)
    if button == "RightButton" then -- update text on right click
        MyCoords_ShowColorPicker(fr,fg,fb,fa, MyCoords_ColorCallback);
    end
end
