--[[ ArenaLive Core Functions: Target Indicator Handler
Created by: Vadrak
Creation Date: 23.05.2014
Last Update: "
This file contains the data for indicators that will show whether the unit frame's
unit is currently targeted by the player or not.
]]--

-- ArenaLive addon Name and localisation table:
local addonName, L = ...;

--[[
**************************************************
******* GENERAL HANDLER SET UP STARTS HERE *******
**************************************************
]]--
local TargetIndicator = ArenaLive:ConstructHandler("TargetIndicator", true);

TargetIndicator:RegisterEvent("PLAYER_TARGET_CHANGED");

--[[
****************************************
****** HANDLER METHODS START HERE ******
****************************************
]]--
function TargetIndicator:Update(unitFrame)
	local unit = unitFrame.unit;
	local indicator = unitFrame[self.name];

	if ( not unit ) then
		indicator:Hide();
		return;
	end
	
	if ( UnitIsUnit(unit, "target") ) then
		indicator:Show();
	else
		indicator:Hide();
	end
end

function TargetIndicator:Reset(unitFrame)
	local indicator = unitFrame[self.name];
	indicator:Hide();
end

function TargetIndicator:OnEvent(event, ...)
	if ( event == "PLAYER_TARGET_CHANGED" ) then
		for id, unitFrame in ArenaLive:GetAllUnitFrames() do
			if ( unitFrame[self.name] ) then
				TargetIndicator:Update(unitFrame);
			end
		end
	end
end