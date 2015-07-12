--[[ ArenaLive Core Functions: Statusbar Text Handler
Created by: Vadrak
Creation Date: 11.04.2014
Last Update: 17.01.2015
This file contains all relevant functions for status bar text handlers.
]]--

-- ArenaLive addon Name and localisation table:
local addonName, L = ...;

--[[
**************************************************
******* GENERAL HANDLER SET UP STARTS HERE *******
**************************************************
]]--
-- Create new Handler:
-- NOTE: This one doesn't need to register events as we simply use the events created by PowerBar and HealthBar handlers to trigger text updates.
local StatusBarText = ArenaLive:ConstructHandler("StatusBarText");

local ABBREVIATION_THOUSAND = "K";
local ABBREVIATION_MILLION = "M";



--[[
****************************************
****** HANDLER METHODS START HERE ******
****************************************
]]--
--[[ Method: ConstructObject
	 Creates a new FontString of the type status bar text. 
		statusBarText (object [FontString]): The FontString that is going to be set up as a status bar text.
]]--
function StatusBarText:ConstructObject(statusBarText, unitFrame)
	ArenaLive:CheckArgs(statusBarText, "FontString");
	self:SetTextObject(unitFrame);
end

function StatusBarText:SetTextObject(unitFrame)
	local database = ArenaLive:GetDBComponent(unitFrame.addon, self.name, unitFrame.group);
	local text = unitFrame[self.name];
	
	--database.FontObject
	text:SetFontObject("GameFontNormal");
end

function StatusBarText:Update(unitFrame)
	
	local unit = unitFrame.unit;
	
	local statusBarText = unitFrame[self.name];
	statusBarText:Show();
	
	if ( not unit ) then
		statusBarText:SetText("");
		return;
	end

	-- Get Text that will be shown:
	local text = self:GetText(unitFrame);

	-- Update Text:
	statusBarText:SetText(text);
end

function StatusBarText:Reset(unitFrame)
	local statusBarText = unitFrame[self.name];
	statusBarText:Hide();
end

function StatusBarText:FormatText(text, value, maxValue)

	-- Percent display:
	local percent, percent_short, decimal;
	if ( maxValue > 0 ) then
		percent = ( value / maxValue ) * 100; 
		percent_short = ( value / maxValue ) * 100; 
		decimal = math.floor(percent_short * 10);
		--percent = BreakUpLargeNumbers(percent);
		decimal = tonumber(string.sub(decimal, -1)) or 0;

		if ( decimal > 5 or math.floor(percent_short) == 0 ) then
			percent_short = math.ceil(percent_short);
		else
			percent_short = math.floor(percent_short);
		end
	else
		percent = 0;
		percent_short = 0;
	end
	
	text = string.gsub(text, "%%PERCENT_SHORT%%", percent_short);
	text = string.gsub(text, "%%PERCENT%%", percent);
	
	-- Current Health/Power Display
	local current = --[[BreakUpLargeNumbers(value);]] value;
	local current_short = value;
	local strLen = string.len(value);
	
	if ( strLen > 6 ) then
		if ( strLen == 7 ) then
			local decimal = LARGE_NUMBER_SEPERATOR..string.sub(value, 2, 2);
			current_short = string.sub(value, 1, -7)..decimal..ABBREVIATION_MILLION;
		else
			current_short = string.sub(value, 1, -7)..ABBREVIATION_MILLION;
		end
	elseif ( strLen > 4 ) then
		current_short = string.sub(value, 1, -4)..ABBREVIATION_THOUSAND;
	elseif (strLen > 3 ) then
		current_short = --[[BreakUpLargeNumbers(value);]] value;
	end
	
	text = string.gsub(text, "%%CURR_SHORT%%", current_short);
	text = string.gsub(text, "%%CURR%%", current);
	
	
	-- Max Health/Power Display
	local maximal = --[[BreakUpLargeNumbers(maxValue);]] maxValue;
	local maximal_short = maxValue;
	strLen = string.len(maxValue);
	
	if ( strLen > 6 ) then
		if ( strLen == 7 ) then
			local decimal = LARGE_NUMBER_SEPERATOR..string.sub(maxValue, 2, 2);
			maximal_short = string.sub(maxValue, 1, -7)..decimal..ABBREVIATION_MILLION;
		else
			maximal_short = string.sub(maxValue, 1, -7)..ABBREVIATION_MILLION;
		end
		
	elseif ( strLen > 4 ) then
		maximal_short = string.sub(maxValue, 1, -4)..ABBREVIATION_THOUSAND;
	elseif (strLen > 3 ) then
		maximal_short = --[[BreakUpLargeNumbers(maxValue);]] maxValue;
	end
	
	text = string.gsub(text, "%%MAX_SHORT%%", maximal_short);
	text = string.gsub(text, "%%MAX%%", maximal);
	
	return text;
end
