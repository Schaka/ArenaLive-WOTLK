--[[ ArenaLive Core Functions: Border Handler
Created by: Vadrak
Creation Date: 06.06.2014
Last Update: 06.06.2014
These functions are used to set up unit frame borders. It enables people to show hide and recolour them.
]]--

-- ArenaLive addon Name and localisation table:
local addonName, L = ...;

--[[
**************************************************
******* GENERAL HANDLER SET UP STARTS HERE *******
**************************************************
]]--
-- Create new Handler:
local Border = ArenaLive:ConstructHandler("Border");
Border.canToggle = true;


--[[
****************************************
****** HANDLER METHODS START HERE ******
****************************************
]]--
function Border:OnEnable(unitFrame)
	local border = unitFrame[self.name];
	border:Show();
	Border:Update(unitFrame);
end

function Border:OnDisable(unitFrame)
	local border = unitFrame[self.name];
	border:Hide();
end

function Border:Update(unitFrame)
	local border = unitFrame[self.name];
	
	if ( not border.enabled ) then
		return;
	end
	
	local database = ArenaLive:GetDBComponent(unitFrame.addon, self.name, unitFrame.group);
	local red = database.Red or 1;
	local green = database.Green or 1;
	local blue = database.Blue or 1;
	border:SetVertexColor(red, green, blue, 1);
end

Border.optionSets = {
	["Enable"] = {
		["type"] = "CheckButton",
		["title"] = L["Enable"],
		["tooltip"] = L["Enables the unit frame's border graphic."],
		["GetDBValue"] = function (frame) local database = ArenaLive:GetDBComponent(frame.addon, frame.handler, frame.group); return database.Enabled; end,
		["SetDBValue"] = function (frame, newValue) local database = ArenaLive:GetDBComponent(frame.addon, frame.handler, frame.group); database.Enabled = newValue; end,
		["postUpdate"] = function (frame, newValue, oldValue) for id, unitFrame in ArenaLive:GetAllUnitFrames() do if ( unitFrame.addon == frame.addon and unitFrame.group == frame.group and unitFrame[Border.name] ) then unitFrame:ToggleHandler(Border.name); end end end,
	},
	["Colour"] = {
		["type"] = "ColourPicker",
		["title"] = L["Border Colour"],
		["tooltip"] = L["Set the colour of the unit frame's border graphic."],
		["GetDBValue"] = function (frame) local database = ArenaLive:GetDBComponent(frame.addon, frame.handler, frame.group); return database.Red, database.Green, database.Blue; end,
		["SetDBValue"] = function (frame, newValue) local database = ArenaLive:GetDBComponent(frame.addon, frame.handler, frame.group); database.Red = newValue.red; database.Green = newValue.green; database.Blue = newValue.blue; end,
		["postUpdate"] = function (frame, newValue, oldValue) for id, unitFrame in ArenaLive:GetAllUnitFrames() do if ( unitFrame.addon == frame.addon and unitFrame.group == frame.group and unitFrame[Border.name] ) then Border:Update(unitFrame); end end end,
	},
};