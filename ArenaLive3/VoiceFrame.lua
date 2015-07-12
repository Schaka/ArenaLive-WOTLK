--[[ ArenaLive Core Functions: Voice Chat Icon Handler
Created by: Vadrak
Creation Date: 24.05.2014
Last Update: "
This file contains the data for indicators that will show whether a unit is speaking in voice chat or not etc.
]]--

-- ArenaLive addon Name and localisation table:
local addonName, L = ...;

--[[
**************************************************
******* GENERAL HANDLER SET UP STARTS HERE *******
**************************************************
]]--
local VoiceFrame = ArenaLive:ConstructHandler("VoiceFrame", true);

VoiceFrame:RegisterEvent("VOICE_START");
VoiceFrame:RegisterEvent("VOICE_STOP");
VoiceFrame:RegisterEvent("MUTELIST_UPDATE");

--[[
****************************************
****** HANDLER METHODS START HERE ******
****************************************
]]--
function VoiceFrame:ConstructObject(voiceFrame, icon, flash, muted)
	voiceFrame.icon = icon;
	voiceFrame.flash = flash;
	voiceFrame.muted = muted;
end

function VoiceFrame:Update(unitFrame)
	local unit = unitFrame.unit;
	local voiceFrame = unitFrame[self.name];

	if ( not unit ) then
		voiceFrame:Hide();
		return;
	end
	
	local mode;	
	local inInstance, instanceType = IsInInstance();
	if ( (instanceType == "pvp") or (instanceType == "arena") ) then
		mode = "Battleground";
	elseif ( IsInRaid() ) then
		mode = "raid";
	else
		mode = "party";
	end
	
	local status = GetVoiceStatus(unit, mode);
	if ( status ) then
		voiceFrame.icon:Show();
		
		if ( GetMuteStatus(unit, mode) ) then
			voiceFrame.flash:Hide();
			voiceFrame.muted:Show();
		elseif ( UnitIsTalking(UnitName(unit)) ) then
			voiceFrame.flash:Show();
			voiceFrame.muted:Hide();
		else
			voiceFrame.flash:Hide();
			voiceFrame.muted:Hide();
		end
	else
		voiceFrame:Hide();
	end
end

function VoiceFrame:Reset(unitFrame)
	local voiceFrame = unitFrame[self.name];
	voiceFrame:Hide();
end

function VoiceFrame:SetFeedBackUnit(unitFrame, unit)

	local indicator = unitFrame[self.name];
	indicator.feedbackUnit = unit;
end

function VoiceFrame:OnEvent(event, ...)
	local unit = ...;
	if ( event == "VOICE_START" or event == "VOICE_STOP" ) then
		if ( ArenaLive:IsUnitInUnitFrameCache(unit) ) then
			for id in ArenaLive:GetAffectedUnitFramesByUnit(unit) do
				local unitFrame = ArenaLive:GetUnitFrameByID(id);
				if ( unitFrame[self.name] ) then
					VoiceFrame:Update(unitFrame);
				end
			end
		end
	elseif ( event == "MUTELIST_UPDATE" ) then
		for id, unitFrame in ArenaLive:GetAllUnitFrames() do
			if ( unitFrame[self.name] ) then
				VoiceFrame:Update(unitFrame);
			end
		end
	end
end