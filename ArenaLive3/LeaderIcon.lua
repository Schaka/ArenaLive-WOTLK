--[[ ArenaLive Core Functions: Leader Icon Handler
Created by: Vadrak
Creation Date: 29.04.2014
Last Update: 18.05.2014
This file contains all relevant functions for group leader icons.
]]--

-- ArenaLive addon Name and localisation table:
local addonName, L = ...;

--[[
**************************************************
******* GENERAL HANDLER SET UP STARTS HERE *******
**************************************************
]]--
local LeaderIcon = ArenaLive:ConstructHandler("LeaderIcon", true);
LeaderIcon:SetHandlerClass("IndicatorIcon");

LeaderIcon:RegisterEvent("PARTY_LEADER_CHANGED");
LeaderIcon:RegisterEvent("GROUP_ROSTER_UPDATE");



--[[
****************************************
****** HANDLER METHODS START HERE ******
****************************************
]]--
function LeaderIcon:GetTexture (unitFrame)
	
	local unit = unitFrame.unit;
	if ( not unit ) then
		return nil, 0, 1, 0, 1;
	end

	if ( IsPartyLeader() or string.sub(unit, -1) == GetPartyLeaderIndex() ) then
		if ( HasLFGRestrictions() ) then
			return "Interface\\LFGFrame\\UI-LFG-ICON-PORTRAITROLES", 0, 0.296875, 0.015625, 0.3125;
		else
			return "Interface\\GroupFrame\\UI-Group-LeaderIcon", 0, 1, 0, 1;
		end
	else
		return nil, 0, 1, 0, 1;
	end

end

function LeaderIcon:GetShown (unitFrame)
	
	local unit = unitFrame.unit;
	if ( not unit ) then
		return false;
	end

	if ( IsPartyLeader() or string.sub(unit, -1) == GetPartyLeaderIndex() ) then
		return true;
	else
		return false;
	end

end

function LeaderIcon:OnEvent(event, ...)
	if ( event == "PARTY_LEADER_CHANGED" or event == "GROUP_ROSTER_UPDATE" ) then
		for id, unitFrame in ArenaLive:GetAllUnitFrames() do
			if ( unitFrame[self.name] ) then
				LeaderIcon:Update(unitFrame);
			end
		end	
	end
end