--[[ ArenaLive Core Functions: Master Looter Icon Handler
Created by: Vadrak
Creation Date: 01.05.2014
Last Update: 17.05.2014
This file contains all relevant functions for pvp status icons.
]]--

-- ArenaLive addon Name and localisation table:
local addonName, L = ...;

--[[
**************************************************
******* GENERAL HANDLER SET UP STARTS HERE *******
**************************************************
]]--
local PvPIcon = ArenaLive:ConstructHandler("PvPIcon", true, true);
PvPIcon:SetHandlerClass("IndicatorIcon");
PvPIcon:RegisterEvent("UNIT_FACTION");
PvPIcon:RegisterEvent("PLAYER_FLAGS_CHANGED");


--[[
****************************************
****** HANDLER METHODS START HERE ******
****************************************
]]--
function PvPIcon:Constructor (icon, texture, text)
	ArenaLive:CheckArgs(icon, "Frame", texture, "Texture");
	
	-- Set texture refrence:
	icon.texture = texture;
	icon.text = text;
end

function PvPIcon:GetTexture (unitFrame)
	local unit = unitFrame.unit;
	local icon = unitFrame[self.name];
	
	if ( not unit ) then
		return nil, 0, 1, 0, 1;
	end
	
	if ( unit == "player" and icon.text ) then
		if ( IsPVPTimerRunning() ) then
			local pvpTime = GetPVPTimer();
			local sec = math.floor(pvpTime/1000);
			local text;
			if ( sec >= 60 ) then
				text = math.ceil(sec/60).."m";
			else
				text = math.floor(sec).."s";
			end

			icon.text:SetText(text);
			icon.text:Show();
		else
			icon.text:Hide();
		end
	end
	
	local factionGroup, factionName = UnitFactionGroup(unit);
	if ( UnitIsPVPFreeForAll(unit) ) then
		return "Interface\\TargetingFrame\\UI-PVP-FFA", 0, 1, 0, 1;
	elseif ( factionGroup and factionGroup ~= "Neutral" and UnitIsPVP(unit) ) then
		return "Interface\\TargetingFrame\\UI-PVP-"..factionGroup, 0, 1, 0, 1;
	else
		return nil, 0, 1, 0, 1;
	end

end

function PvPIcon:GetShown (unitFrame)
	local unit = unitFrame.unit;
	
	if ( not unit ) then
		return false;
	end
	
	local factionGroup, factionName = UnitFactionGroup(unit);
	if ( UnitIsPVPFreeForAll(unit) or ( factionGroup and factionGroup ~= "Neutral" and UnitIsPVP(unit) ) ) then
		unitFrame[self.name]["unit"] = unit; -- Use this to enable the tooltip function
		return true;
	else
		unitFrame[self.name]["unit"] = nil;
		return false;
	end

end

function PvPIcon:OnEvent(event, ...)
	local unit = ...;
	if ( ( event == "UNIT_FACTION" and unit == "player" ) or event == "PLAYER_FLAGS_CHANGED" ) then
		if ( IsPVPTimerRunning() ) then
			self:Show();
		else
			self:Hide();
		end
	end
	
	if ( event == "UNIT_FACTION" ) then
		if ( ArenaLive:IsUnitInUnitFrameCache(unit) ) then
			for id in ArenaLive:GetAffectedUnitFramesByUnit(unit) do
				local unitFrame = ArenaLive:GetUnitFrameByID(id);
				if ( unitFrame[self.name] ) then
					PvPIcon:Update(unitFrame);
				end
			end
		end		
	end
end

local lastSec = 0;
function PvPIcon:OnUpdate(elapsed)
	if ( IsPVPTimerRunning() ) then
		local sec = math.floor(GetPVPTimer()/1000) % 60;
		if ( sec ~= lastSec ) then
			lastSec = sec;
			if ( ArenaLive:IsUnitInUnitFrameCache("player") ) then
				for id in ArenaLive:GetAffectedUnitFramesByUnit("player") do
					local unitFrame = ArenaLive:GetUnitFrameByID(id);
					if ( unitFrame[self.name] and unitFrame[self.name].text ) then
						PvPIcon:Update(unitFrame);
					end
				end
			end
		end
	else
		self:Hide();
	end
end
PvPIcon:Hide();
PvPIcon:SetScript("OnUpdate", PvPIcon.OnUpdate);