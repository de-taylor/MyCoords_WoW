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
	    MyCoordsFontString:SetText("|cFFFFFFFF("..x..", "..y..")")	
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
    local tex = self:CreateTexture("ARTWORK");
    tex:SetAllPoints();
    tex:SetTexture(0.1,0.1,0); tex:SetAlpha(0.5);
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
