--[[ ArenaLive Core Functions: Quest Icon Handler
Created by: Vadrak
Creation Date: 29.04.2014
Last Update: 17.05.2014
This file contains all relevant functions for quest NPC indicator icons.
]]--

-- ArenaLive addon Name and localisation table:
local addonName, L = ...;

--[[
**************************************************
******* GENERAL HANDLER SET UP STARTS HERE *******
**************************************************
]]--
local QuestIcon = ArenaLive:ConstructHandler("QuestIcon", true, false, false);
QuestIcon:SetHandlerClass("IndicatorIcon");

QuestIcon:RegisterEvent("UNIT_CLASSIFICATION_CHANGED");



--[[
****************************************
****** HANDLER METHODS START HERE ******
****************************************
]]--
function QuestIcon:GetTexture (unitFrame)
	
	local unit = unitFrame.unit;
	if ( not unit ) then
		return nil, 0, 1, 0, 1;
	end

	if ( --[[UnitIsQuestBoss(unit)]] false == true ) then
		return "Interface\\TargetingFrame\\PortraitQuestBadge", 0, 1, 0, 1;
	else
		return nil, 0, 1, 0, 1;
	end	
end

function QuestIcon:GetShown (unitFrame)
	
	local unit = unitFrame.unit;
	if ( not unit ) then
		return false;
	end

	if ( --[[UnitIsQuestBoss(unit)]] false == true ) then
		return true;
	else
		return false;
	end	
end

function QuestIcon:OnEvent(event, ...)
	if ( event == "UNIT_CLASSIFICATION_CHANGED" ) then
		local unit = ...;
		if ( ArenaLive:IsUnitInUnitFrameCache(unit) ) then
			for id, unitFrame in ArenaLive:GetAffectedUnitFramesByUnit(unit) do
				local unitFrame = ArenaLive:GetUnitFrameByID(id);
				if ( unitFrame[self.name] ) then
					self:Update(unitFrame);
				end
			end
		end
	end
end