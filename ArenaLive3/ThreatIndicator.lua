--[[ ArenaLive Core Functions: Threat Indicator Handler
Created by: Vadrak
Creation Date: 23.05.2014
Last Update: "
This file contains the data for indicators that will show the unit frame's unit's aggro status.
]]--

-- ArenaLive addon Name and localisation table:
local addonName, L = ...;

--[[
**************************************************
******* GENERAL HANDLER SET UP STARTS HERE *******
**************************************************
]]--
local ThreatIndicator = ArenaLive:ConstructHandler("ThreatIndicator", true);

ThreatIndicator:RegisterEvent("UNIT_THREAT_SITUATION_UPDATE");

--[[
****************************************
****** HANDLER METHODS START HERE ******
****************************************
]]--
function ThreatIndicator:ConstructObject(indicator, feedbackUnit)
	indicator.feedbackUnit = feedbackUnit;
end

function ThreatIndicator:Update(unitFrame)
	local unit = unitFrame.unit;
	local indicator = unitFrame[self.name];
	
	if ( not unit or not indicator.feedbackUnit ) then
		indicator:Hide();
		return;
	end
	
	local status;
	if ( indicator.feedbackUnit ~= unit ) then
		status = UnitThreatSituation(indicator.feedbackUnit, unit);
	else
		status = UnitThreatSituation(indicator.feedbackUnit);
	end
		
	if ( status and status > 0 ) then
		indicator:SetVertexColor(GetThreatStatusColor(status));
		indicator:Show();
	else
		indicator:Hide();
	end
end

function ThreatIndicator:Reset(unitFrame)
	local indicator = unitFrame[self.name];
	indicator:Hide();
end

function ThreatIndicator:SetFeedBackUnit(unitFrame, unit)

	local indicator = unitFrame[self.name];
	indicator.feedbackUnit = unit;
end

function ThreatIndicator:OnEvent(event, ...)
	local unit = ...;
	if ( event == "UNIT_THREAT_SITUATION_UPDATE" ) then
		if ( ArenaLive:IsUnitInUnitFrameCache(unit) ) then
			for id in ArenaLive:GetAffectedUnitFramesByUnit(unit) do
				local unitFrame = ArenaLive:GetUnitFrameByID(id);
				if ( unitFrame[self.name] ) then
					ThreatIndicator:Update(unitFrame);
				end
			end
		end
	end
end