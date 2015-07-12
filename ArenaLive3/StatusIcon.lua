--[[ ArenaLive Core Functions: Status Icon Handler
Created by: Vadrak
Creation Date: 29.04.2014
Last Update: 17.05.2014
This file contains all relevant functions for status icons.
]]--

-- ArenaLive addon Name and localisation table:
local addonName, L = ...;

--[[
**************************************************
******* GENERAL HANDLER SET UP STARTS HERE *******
**************************************************
]]--
local StatusIcon = ArenaLive:ConstructHandler("StatusIcon", true, true);
StatusIcon:SetHandlerClass("IndicatorIcon");

StatusIcon:RegisterEvent("PLAYER_REGEN_DISABLED");
StatusIcon:RegisterEvent("PLAYER_REGEN_ENABLED");
StatusIcon:RegisterEvent("PLAYER_UPDATE_RESTING");
StatusIcon:RegisterEvent("UNIT_COMBAT");

-- Create a cache to store all units that currently are in combat:
local unitCombatCache = {};
local ON_UPDATE_THROTTLE = 0.5;
local DEFAULT_COMBAT_TIME = 5; -- units enagage combat shortly after UNIT_COMBAT fires. This prevents the OnUpdate function from hiding the icon when engaging combat.
StatusIcon.elapsed = 0;



--[[
****************************************
****** HANDLER METHODS START HERE ******
****************************************
]]--
function StatusIcon:GetTexture (unitFrame)

	local unit = unitFrame.unit;
	
	if ( not unit ) then
		return;
	end

	if ( IsResting() and ( unit == "player" or UnitIsUnit("player", unit) ) ) then
		return "Interface\\CharacterFrame\\UI-StateIcon", 0, 0.5, 0, 0.421875;
	elseif ( unitCombatCache[unit] or ( UnitAffectingCombat(unit) ) ) then
		return "Interface\\CharacterFrame\\UI-StateIcon", 0.5, 1 , 0, 0.5;
	else
		return nil, 0, 1, 0, 1;
	end

end

function StatusIcon:GetShown (unitFrame)
	local unit = unitFrame.unit;
	
	if ( not unit ) then
		return false;
	end
	
	if ( ( IsResting() and ( unit == "player" or UnitIsUnit("player", unit) ) ) or unitCombatCache[unit] or ( UnitAffectingCombat(unit) ) ) then
		return true;
	else
		return false;
	end
	
end

function StatusIcon:OnUpdate (elapsed)

	StatusIcon.elapsed = StatusIcon.elapsed + elapsed;
	if ( StatusIcon.elapsed >= ON_UPDATE_THROTTLE ) then
		StatusIcon.elapsed = 0;
		local theTime = GetTime();
		for unit in pairs(unitCombatCache) do
			if ( not UnitAffectingCombat(unit) and theTime > unitCombatCache[unit] ) then
				unitCombatCache[unit] = nil;
				if ( ArenaLive:IsUnitInUnitFrameCache(unit) ) then
					for id in ArenaLive:GetAffectedUnitFramesByUnit(unit) do
						local unitFrame = ArenaLive:GetUnitFrameByID(id);
						if ( unitFrame[self.name] ) then
							StatusIcon:Update(unitFrame);
						end
					end
				end
			end
		end
	end
end

function StatusIcon:OnEvent (event, ...)
	local unit = ... or "player";
	if ( event == "UNIT_COMBAT" and unit ~= "player" ) then
		if ( not unitCombatCache[unit] ) then
			unitCombatCache[unit] = GetTime() + DEFAULT_COMBAT_TIME;
			if ( ArenaLive:IsUnitInUnitFrameCache(unit) ) then
				for id in ArenaLive:GetAffectedUnitFramesByUnit(unit) do
					local unitFrame = ArenaLive:GetUnitFrameByID(id);
					if ( unitFrame[self.name] ) then
						StatusIcon:Update(unitFrame);
					end
				end
			end
		end
	else
		if ( ArenaLive:IsUnitInUnitFrameCache(unit) ) then
			for id in ArenaLive:GetAffectedUnitFramesByUnit(unit) do
				local unitFrame = ArenaLive:GetUnitFrameByID(id);
				if ( unitFrame[self.name] ) then
					StatusIcon:Update(unitFrame);
				end
			end
		end
	end
end

StatusIcon:SetScript("OnUpdate", StatusIcon.OnUpdate);