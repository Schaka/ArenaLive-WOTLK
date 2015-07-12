--[[ ArenaLive Core Functions: Role Icon Handler
Created by: Vadrak
Creation Date: 29.04.2014
Last Update: 17.05.2014
This file contains all relevant functions for role icons.
]]--

-- ArenaLive addon Name and localisation table:
local addonName, L = ...;

--[[
**************************************************
******* GENERAL HANDLER SET UP STARTS HERE *******
**************************************************
]]--
local RoleIcon = ArenaLive:ConstructHandler("RoleIcon", true, false, false);
RoleIcon:SetHandlerClass("IndicatorIcon");

RoleIcon:RegisterEvent("PLAYER_ROLES_ASSIGNED");
RoleIcon:RegisterEvent("GROUP_ROSTER_UPDATE");



--[[
****************************************
****** HANDLER METHODS START HERE ******
****************************************
]]--
function RoleIcon:GetTexture (unitFrame)
	
	local unit = unitFrame.unit;
	if ( not unit ) then
		return nil, 0, 1, 0, 1;
	end

	local role = UnitGroupRolesAssigned(unit);
	if ( role == "TANK" or role == "HEALER" or role == "DAMAGER") then
		return "Interface\\LFGFrame\\UI-LFG-ICON-PORTRAITROLES", GetTexCoordsForRoleSmallCircle(role);
	else
		return nil, 0, 1, 0, 1;
	end

end

function RoleIcon:GetShown (unitFrame)
	
	local unit = unitFrame.unit;
	if ( not unit ) then
		return false;
	end

	local role = UnitGroupRolesAssigned(unit);
	if ( role == "TANK" or role == "HEALER" or role == "DAMAGER") then
		return true;
	else
		return false;
	end

end

function RoleIcon:OnEvent(event, ...)
	if ( event == "PLAYER_ROLES_ASSIGNED" ) then
		local unit = "player";
		if ( ArenaLive:IsUnitInUnitFrameCache(unit) ) then
			for id in ArenaLive:GetAffectedUnitFramesByUnit(unit) do
				local unitFrame = ArenaLive:GetUnitFrameByID(id);
				if ( unitFrame[self.name] ) then
					RoleIcon:Update(unitFrame);
				end
			end
		end
	elseif ( event == "GROUP_ROSTER_UPDATE" ) then
		for id, unitFrame in ArenaLive:GetAllUnitFrames() do
			if ( unitFrame[self.name] ) then
				RoleIcon:Update(unitFrame);
			end
		end	
	end
end