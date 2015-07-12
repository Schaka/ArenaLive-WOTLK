--[[ ArenaLive Core Functions: Master Looter Icon Handler
Created by: Vadrak
Creation Date: 29.04.2014
Last Update: 17.05.2014
This file contains all relevant functions for master looter icons.
]]--

-- ArenaLive addon Name and localisation table:
local addonName, L = ...;

--[[
**************************************************
******* GENERAL HANDLER SET UP STARTS HERE *******
**************************************************
]]--
local MasterLooterIcon = ArenaLive:ConstructHandler("MasterLooterIcon", true, false, false);
MasterLooterIcon:SetHandlerClass("IndicatorIcon");

MasterLooterIcon:RegisterEvent("PARTY_LOOT_METHOD_CHANGED");



--[[
****************************************
****** HANDLER METHODS START HERE ******
****************************************
]]--
function MasterLooterIcon:GetTexture (unitFrame)
	return "Interface\GroupFrame\UI-Group-MasterLooter", 0, 1, 0, 1;
end

function MasterLooterIcon:GetShown (unitFrame)
	local unit = unitFrame.unit;
	
	if ( not unit ) then
		return false;
	end
	
	local lootMethod, lootMaster = GetLootMethod();
	local unitType = string.match(unit, "^([a-z]+)[0-9]+$") or unit;
	local unitNumber = tonumber(string.match(unit, "^[a-z]+([0-9]+)$")) or -1;

	if ( not lootMaster ) then
		lootMaster = -2;
	end
	
	if ( UnitInParty("player") and ( ( lootMaster == 0 and unit == "player" ) or ( (unitType == "party" or unitType == "raid") and unitNumber == lootMaster ) ) ) then
		return true;
	else
		return false;
	end	
end

function MasterLooterIcon:OnEvent(event, ...)
	if ( event == "PARTY_LOOT_METHOD_CHANGED" ) then
		for id, unitFrame in ArenaLive:GetAllUnitFrames() do
			if ( unitFrame[self.name] ) then
				MasterLooterIcon:Update(unitFrame);
			end
		end	
	end
end