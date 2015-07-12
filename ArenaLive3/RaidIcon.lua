--[[ ArenaLive Core Functions: Raid Icon Handler
Created by: Vadrak
Creation Date: 29.04.2014
Last Update: 17.05.2014
This file contains all relevant functions for raid icons.
]]--

-- ArenaLive addon Name and localisation table:
local addonName, L = ...;

--[[
**************************************************
******* GENERAL HANDLER SET UP STARTS HERE *******
**************************************************
]]--
local RaidIcon = ArenaLive:ConstructHandler("RaidIcon", true, false, false);
RaidIcon:SetHandlerClass("IndicatorIcon");

RaidIcon:RegisterEvent("RAID_TARGET_UPDATE");

--[[
****************************************
****** HANDLER METHODS START HERE ******
****************************************
]]--
function RaidIcon:GetTexture (unitFrame)
	
	if ( not unitFrame.unit ) then
		return nil, 0, 1, 0, 1;
	end	
	
	local index = GetRaidTargetIndex(unitFrame.unit);
	if ( index ) then
		index = index - 1;
		local left, right, top, bottom;
		local coordIncrement = RAID_TARGET_ICON_DIMENSION / RAID_TARGET_TEXTURE_DIMENSION;
		left = mod(index , RAID_TARGET_TEXTURE_COLUMNS) * coordIncrement;
		right = left + coordIncrement;
		top = floor(index / RAID_TARGET_TEXTURE_ROWS) * coordIncrement;
		bottom = top + coordIncrement;
		return "Interface\\TargetingFrame\\UI-RaidTargetingIcons", left, right, top, bottom;
	end
	
	return nil, 0, 1, 0, 1;
end

function RaidIcon:GetShown(unitFrame)

	if ( not unitFrame.unit ) then
		return false;
	end
	
	local index = GetRaidTargetIndex(unitFrame.unit);
	if ( index ) then
		return true;
	else
		return false;
	end		
end

function RaidIcon:OnEvent(event, ...)
	if ( event == "RAID_TARGET_UPDATE" ) then
		for id, unitFrame in ArenaLive:GetAllUnitFrames() do
			if ( unitFrame[self.name] ) then
				RaidIcon:Update(unitFrame);
			end
		end	
	end
end