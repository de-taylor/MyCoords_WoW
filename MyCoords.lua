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
 	    x = math.floor(posX * 10000)/100
	    y = math.floor(posY*10000)/100
	    MyCoordsFontString:SetText("("..x..", "..y..")")
        MyCoordsFontString:SetTextColor(fr,fg,fb,fa) -- set initial color values
 	end	
end

--[[  Defining slash commands --]]
SLASH_MYCOORDS1, SLASH_MYCOORDS2 = '/mc', '/mycoords';
SlashCmdList["MYCOORDS"] = function (msg, editbox)
    local myc_msg, myc_chat, myc_channel, chatarg;
  
    --[[ parse complex argument --]]
    --[[ very basic string split --]]
    local t = {}
    local i = 1
    for word in string.gmatch(msg, '([^%s]+)') do
        t[i] = word
        i=i+1
    end
    chatarg = t[1] -- which chat it's going to
    myc_channel = t[2] -- which channel it's going to
    myc_msg = "Zone: " .. zone .. ", X-Coord: " .. x .. ", Y-Coord: " .. y; -- only one type of message
    print(chatarg)
    if chatarg == "s" then
        myc_chat = "SAY"
    elseif chatarg == "y" then
        myc_chat = "YELL"
    elseif chatarg == "p" then
        myc_chat = "PARTY"
    elseif chatarg == "g" then
        myc_chat = "GUILD"
    elseif chatarg == "o" then
        myc_chat = "OFFICER"
    elseif chatarg == "r" then
        myc_chat = "RAID"
    elseif chatarg == "i" then
        myc_chat = "INSTANCE_CHAT"
    elseif chatarg == "bg" then
        myc_chat = "BATTLEGROUND"
    elseif chatarg == "wh" then
        myc_chat = "WHISPER"
    elseif msg == "ch" then
        myc_chat = "CHANNEL"
    end

    print(myc_chat,myc_channel)

    if myc_channel == nil then
        SendChatMessage(myc_msg,myc_chat)
    else
        SendChatMessage(myc_msg,myc_chat,"COMMON",myc_channel);
    end
end


function MyCoords_OnLoad(self, event,...) 
    --[[ Write out welcome text to user --]]
    print("MyCoords v0.2.2\n")

    --[[ Register events --]]
    self:RegisterEvent("ADDON_LOADED") -- track state of addon
    self:RegisterEvent("VARIABLES_LOADED") -- track state of saved variables
    
    --[[ Set frame as draggable --]]
    self:SetMovable(true)
    self:EnableMouse(true)
    self:RegisterForDrag("LeftButton")
    self:SetScript("OnDragStart",self.StartMoving)
    self:SetScript("OnDragStop",self.StopMovingOrSizing)

    --[[ Create draggable frame background --]]
    self:SetPoint("CENTER"); self:SetWidth(64); self:SetHeight(20);
    local tex = self:CreateTexture("ARTWORK");
    tex:SetAllPoints();
    tex:SetTexture(0,0.1,0.1); tex:SetAlpha(0.5);

end
function MyCoords_OnEvent(self, event, ...)
     if event == "ADDON_LOADED" and ... == "MyCoords" then
         self:UnregisterEvent("ADDON_LOADED")
         self:UnregisterEvent("VARIABLES_LOADED") -- not using it right now
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
