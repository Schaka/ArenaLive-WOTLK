--[[ ArenaLive Core Functions: Combo Point Frame Handler
Created by: Vadrak
Creation Date: 30.07.2014
Last Update: "
Includes functions for the combo point frames for rogues and cat druids.
]]--

-- ArenaLive addon Name and localisation table:
local addonName, L = ...;

--[[
**************************************************
******* GENERAL HANDLER SET UP STARTS HERE *******
**************************************************
]]--
local ComboFrame = ArenaLive:ConstructHandler("ComboFrame", true, true);
ComboFrame:RegisterEvent("PLAYER_COMBO_POINTS");
ComboFrame:RegisterEvent("UNIT_COMBO_POINTS");
ComboFrame:RegisterEvent("PLAYER_TARGET_CHANGED");

local COMBO_POINT_FADEIN = 0.3;
local fadingComboPoints = {};
local numFadingComboPoints = 0;

--[[
****************************************
****** HANDLER METHODS START HERE ******
****************************************
]]--
--[[ Method: ConstructObject
	 Creates a new frame of the type health bar.
		comboFrame (frame [Frame]): The frame that is going to be set up as a combo point frame.
		comboPoint1-5 (Texture): A texture that shows a combo point.
		fadeInTime (number [optional]): Time in seconds it takes for a combo point to fade in. Defaults to value of COMBO_POINT_FADEIN.
]]--
function ComboFrame:ConstructObject(comboFrame, comboPoint1, comboPoint2, comboPoint3, comboPoint4, comboPoint5, fadeInTime)
	
	ArenaLive:CheckArgs(comboFrame, "Frame", comboPoint1, "Texture", comboPoint2, "Texture", comboPoint3, "Texture", comboPoint4, "Texture", comboPoint5, "Texture");
	
	-- Set some base values:
	comboFrame.fadeInTime = fadeInTime or COMBO_POINT_FADEIN;
	comboFrame.lastNumPoints = 0;
	
	-- Set combo point references
	comboFrame.cp1 = comboPoint1;
	comboFrame.cp2 = comboPoint2;
	comboFrame.cp3 = comboPoint3;
	comboFrame.cp4 = comboPoint4;
	comboFrame.cp5 = comboPoint5;
end

function ComboFrame:Update(unitFrame)
	local comboFrame = unitFrame[self.name];
	local unit = unitFrame.unit;
	
	if ( not unit ) then
		ComboFrame:Reset(unitFrame);
		return;
	end

	local comboPoints = GetComboPoints("player", unit);
	if ( comboPoints > 0 ) then
		if ( not comboFrame:IsShown() ) then
			comboFrame:Show();
		end
		
		
		for i = 1, 5 do
			local comboPoint = comboFrame["cp"..i];
			if ( i <= comboPoints ) then
				if ( i > comboFrame.lastNumPoints ) then
					comboPoint:Show();
					comboPoint.fadeTime = comboFrame.fadeInTime;
					comboPoint.timeSpentFading = 0;
					comboPoint:SetAlpha(0);
				
					fadingComboPoints[comboPoint] = true;
					numFadingComboPoints = numFadingComboPoints + 1;

					if ( not ComboFrame:IsShown() ) then
						ComboFrame:Show();
					end
				end
			else
				ComboFrame:ResetSingle(comboPoint);
			end
		end
	else
		ComboFrame:Reset(unitFrame);
	end
	comboFrame.lastNumPoints = comboPoints;
end

function ComboFrame:Reset(unitFrame)
	local comboFrame = unitFrame[self.name];
	
	for i = 1, 5 do
		local comboPoint = comboFrame["cp"..i];
		ComboFrame:ResetSingle(comboPoint);
	end
	comboFrame:Hide();
end

function ComboFrame:ResetSingle(comboPoint)
		if ( fadingComboPoints[comboPoint] ) then
			fadingComboPoints[comboPoint] = nil;
			numFadingComboPoints = numFadingComboPoints - 1;
		end
		comboPoint:Hide();
		comboPoint.fadeTime = 0;
		comboPoint.timeSpentFading = 0;
		comboPoint:SetAlpha(0);	
end

function ComboFrame:OnEvent(event, ...)
	for id, unitFrame in ArenaLive:GetAllUnitFrames() do
		if ( unitFrame[self.name] ) then
			ComboFrame:Update(unitFrame);
		end
	end
end

function ComboFrame:OnUpdate(elapsed)
	if ( numFadingComboPoints > 0 ) then
		for comboPoint, timeLeft in pairs(fadingComboPoints) do
			comboPoint.timeSpentFading = comboPoint.timeSpentFading + elapsed;
			
			local newAlpha = 1 * ( comboPoint.timeSpentFading / comboPoint.fadeTime );
			if ( newAlpha >= 1 ) then
				fadingComboPoints[comboPoint] = nil;
				numFadingComboPoints = numFadingComboPoints - 1;
				comboPoint:SetAlpha(1);
				comboPoint.fadeTime = 0;
				comboPoint.timeSpentFading = 0;				
			else
				comboPoint:SetAlpha(newAlpha);
			end
		end
	else
		ComboFrame:Hide();
	end
end
ComboFrame:SetScript("OnUpdate", ComboFrame.OnUpdate);