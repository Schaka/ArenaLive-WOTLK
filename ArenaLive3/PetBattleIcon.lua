--[[ ArenaLive Core Functions: Master Looter Icon Handler
Created by: Vadrak
Creation Date: 01.05.2014
Last Update: 17.05.2014
This file contains all relevant functions for battle pet icons.
]]--

-- ArenaLive addon Name and localisation table:
local addonName, L = ...;

--[[
**************************************************
******* GENERAL HANDLER SET UP STARTS HERE *******
**************************************************
]]--
local PetBattleIcon = ArenaLive:ConstructHandler("PetBattleIcon", false, false, false);
PetBattleIcon:SetHandlerClass("IndicatorIcon");



--[[
****************************************
****** HANDLER METHODS START HERE ******
****************************************
]]--
function PetBattleIcon:GetTexture (unitFrame)
	local unit = unitFrame.unit;
	
	if ( not unit ) then
		return nil, 0, 1, 0, 1;
	end
	
	if ( --[[UnitIsWildBattlePet(unit) or UnitIsBattlePetCompanion(unit)]] false == true ) then
		local petType = UnitBattlePetType(unit);
		return "Interface\\TargetingFrame\\PetBadge-"..PET_TYPE_SUFFIX[petType], 0, 1, 0, 1;
	else
		return nil, 0, 1, 0, 1;
	end
end

function PetBattleIcon:GetShown(unitFrame)
	local unit = unitFrame.unit;
	
	if ( not unit ) then
		return false;
	end
	
	if ( --[[UnitIsWildBattlePet(unit) or UnitIsBattlePetCompanion(unit)]] false == true ) then
		return true;
	else
		return false;
	end
end