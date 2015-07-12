--[[ ArenaLive Core Functions: HealthBar Handler
Created by: Vadrak
Creation Date: 04.04.2014
Last Update: 17.05.2014
These functions are used to set up every health bar.
]]--

-- ArenaLive addon Name and localisation table:
local addonName, L = ...;

--[[
**************************************************
******* GENERAL HANDLER SET UP STARTS HERE *******
**************************************************
]]--
-- Create new Handler and register for all important events:
local HealthBar = ArenaLive:ConstructHandler("HealthBar", true, true);
local HealthBarText = ArenaLive:GetHandler("HealthBarText");

HealthBar:RegisterEvent("UNIT_HEALTH");
HealthBar:RegisterEvent("UNIT_FACTION");
HealthBar:RegisterEvent("UNIT_MAXHEALTH");
HealthBar:RegisterEvent("UNIT_ABSORB_AMOUNT_CHANGED");
HealthBar:RegisterEvent("UNIT_HEAL_ABSORB_AMOUNT_CHANGED");
HealthBar:RegisterEvent("UNIT_HEAL_PREDICTION");

-- Legit units for frequent updates with their current HP.
local frequentUpdates = 
	{
		["player"] = 0,
		["target"] = 0,
		["spectateda1"] = 0,
		["spectateda2"] = 0,
		["spectateda3"] = 0,
		["spectateda4"] = 0,
		["spectateda5"] = 0,
		["spectateda6"] = 0,
		["spectateda7"] = 0,
		["spectateda8"] = 0,
		["spectateda9"] = 0,
		["spectateda10"] = 0,
		["spectatedb1"] = 0,
		["spectatedb2"] = 0,
		["spectatedb3"] = 0,
		["spectatedb4"] = 0,
		["spectatedb5"] = 0,
		["spectatedb6"] = 0,
		["spectatedb7"] = 0,
		["spectatedb8"] = 0,
		["spectatedb9"] = 0,
		["spectatedb10"] = 0,
	};


--[[
****************************************
****** HANDLER METHODS START HERE ******
****************************************
]]--
--[[ Method: ConstructObject
	 Creates a new frame of the type health bar.
		healthBar (frame [Statusbar]): The frame that is going to be set up as a health bar.
		healPredictionBar (texture/frame [optional]): A texture or frame that shows incoming healing on the health bar.
		absorbBar (texture/frame [optional]): A texture or frame that shows absorb on the health bar.
		absorbBarOverlay (texture/frame [optional]): A overlay texture for the absorb bar to make it look fancy *lol*.
		absorbBarOverlayTileSize (number [optional]): Tile Size of the overlay texture. If you have an overlay you NEED to set this (set it to 0 if you don't have a tile).
		absorbBarFullHPIndicator (texture [optional]): A texture that will mark the 100% HP value, when current health < 100% and absorb + current health > maxhealth.
		healAbsorbBar (frame/texture [optional]): A texture or frame that shows healing absorb (e.g. DK's Necrotic Strike) on the health bar. (TODO NYI)
]]--
function HealthBar:ConstructObject(healthBar, healPredictionBar, absorbBar, absorbBarOverlay, absorbBarOverlayTileSize, absorbBarFullHPIndicator, healAbsorbBar, addonName, frameType)

	ArenaLive:CheckArgs(healthBar, "StatusBar");
	
	-- Set up references:
	healthBar.predictionBar = healPredictionBar;
	healthBar.absorbBar = absorbBar;
	healthBar.healAbsorbBar = healAbsorbBar;
	
	if ( healthBar.absorbBar ) then
		healthBar.absorbBar.overlay = absorbBarOverlay;
		healthBar.absorbBar.tileSize = absorbBarOverlayTileSize;
		healthBar.absorbBar.fullHPindicator = absorbBarFullHPIndicator;
	end	

	-- Set reverse fill:
	HealthBar:SetReverseFill(healthBar, addonName, frameType);
end

--[[ Method: SetReverseFill
	 Set whether the specified health bar should be reverse filled or not.
		healthBar (frame [Statusbar]): The affected health bar.
]]--
function HealthBar:SetReverseFill (healthBar, addonName, frameType)
		local database = ArenaLive:GetDBComponent(addonName, self.name, frameType);
		local reverseFill = database.ReverseFill;
		--healthBar:SetReverseFill(reverseFill);
end

--[[ Method: UpdateHealth
	 General update function the health bar.
		healthBar (frame): Affected HealthBar.
]]--
function HealthBar:Update (unitFrame, funcName)
	
	local healthBar = unitFrame[self.name];
	local unit = unitFrame.unit;
	local ufName = unitFrame:GetName();

	if ( not unitFrame.test and ( not unit or healthBar.lockValues ) ) then
		return;
	end
	
	local maxHealth, currHealth;
	
	if ( unitFrame.test ) then
		maxHealth = ArenaLive.testModeValues[unitFrame.test]["healthMax"];
		currHealth = ArenaLive.testModeValues[unitFrame.test]["healthCurr"];
	else
		maxHealth = UnitHealthMax(unit);
		currHealth = UnitHealth(unit);		
	end
	
	healthBar.hideText = nil;
	if ( maxHealth == 0 ) then
		maxHealth = 1;
		healthBar.hideText = true;
	end

	if ( unitFrame.test ) then
		healthBar.disconnected = nil;
	else
		healthBar.disconnected = not UnitIsConnected(unit);
	end
		
	if ( healthBar.disconnected ) then
		currHealth = maxHealth;
	end
	
	healthBar:SetMinMaxValues(0, maxHealth);
	healthBar:SetValue(currHealth);
	healthBar.currValue = currHealth;
	
	HealthBar:UpdateAbsorb (unitFrame);
	HealthBar:UpdateHealPrediction(unitFrame);
	HealthBar:SetColour(unitFrame);
	
end

--[[ Method: UpdateAbsorb
	 If the specified health bar has an absorb bar, this function will update the absorb display.
		healthBar (frame): Affected HealthBar.
]]--
function HealthBar:UpdateAbsorb (unitFrame)
	
	local healthBar = unitFrame[self.name];
	local absorbBar = healthBar.absorbBar
	local unit = unitFrame.unit;

	local database = ArenaLive:GetDBComponent(unitFrame.addon, self.name, unitFrame.group);
	local showAbsorb = database.ShowAbsorb;
	
	if ( unitFrame.test or not absorbBar or not showAbsorb or not unit ) then
		if ( absorbBar ) then
			absorbBar:Hide();
		
			if ( absorbBar.overlay ) then
				absorbBar.overlay:Hide();
			end
			
			if ( absorbBar.fullHPindicator ) then
				absorbBar.fullHPindicator:Hide();
			end
		end
		return;
	end
	
	local minValue, maxValue = healthBar:GetMinMaxValues();
	local maxHealth = UnitHealthMax(unit);
	local currHealth = healthBar.currValue;
	local absorb = --[[UnitGetTotalAbsorbs(unit) or ]]0;

	-- If max health is smaller than health + absorb, set max value of the healthbar to health + absorb.
	if ( currHealth + absorb > maxHealth ) then
		maxValue = currHealth + absorb;
	else
		maxValue = maxHealth;
	end	

	healthBar:SetMinMaxValues(minValue, maxValue);
	
	if ( absorb == 0 ) then
		absorbBar:Hide();
		
		if ( absorbBar.overlay ) then
			absorbBar.overlay:Hide();
		end
			
		if ( absorbBar.fullHPindicator ) then
			absorbBar.fullHPindicator:Hide();
		end
	else
		absorbBar:ClearAllPoints();
		
		-- Set the position of the absorb bar according to reverse fill settings of the healthbar
		if ( healthBar:GetReverseFill() ) then
			absorbBar:SetPoint("TOPRIGHT", healthBar:GetStatusBarTexture(), "TOPLEFT", 0, 0);
			absorbBar:SetPoint("BOTTOMRIGHT",healthBar:GetStatusBarTexture(), "BOTTOMLEFT", 0, 0);
		else
			absorbBar:SetPoint("TOPLEFT", healthBar:GetStatusBarTexture(), "TOPRIGHT", 0, 0);
			absorbBar:SetPoint("BOTTOMLEFT", healthBar:GetStatusBarTexture(), "BOTTOMRIGHT", 0, 0);
		end		
		
		local totalWidth, totalHeight = healthBar:GetSize();

		local barWidth = (absorb / maxValue) * totalWidth;
		absorbBar:SetWidth(barWidth);
		absorbBar:Show();
		
		if ( absorbBar.overlay ) then
			absorbBar.overlay:SetSize(barWidth, totalHeight);
			absorbBar.overlay:ClearAllPoints();
			absorbBar.overlay:SetPoint(healthBar.absorbBar:GetPoint());
			absorbBar.overlay:SetTexCoord(0, barWidth / absorbBar.tileSize, 0, totalHeight / absorbBar.tileSize);
			absorbBar.overlay:Show();
		end
				
		if ( absorbBar.fullHPindicator ) then
			if ( maxValue > maxHealth ) then
				local xOffset = (maxHealth / maxValue) * totalWidth;
				absorbBar.fullHPindicator:ClearAllPoints();
						
				if ( healthBar:GetReverseFill() ) then
					absorbBar.fullHPindicator:SetPoint("TOPRIGHT", healthBar:GetStatusBarTexture(), "TOPRIGHT", -xOffset, 0);
				else
					absorbBar.fullHPindicator:SetPoint("TOPLEFT", healthBar:GetStatusBarTexture(), "TOPLEFT", xOffset, 0);
				end
					
				absorbBar.fullHPindicator:SetHeight(healthBar:GetHeight());
				absorbBar.fullHPindicator:Show();
			else
				absorbBar.fullHPindicator:Hide();
			end
		end			
	end
end

--[[ Method: UpdateHealPrediction
	 If the specified health bar has a heal prediction bar, this function will update it.
		healthBar (frame): Affected HealthBar.
]]--
local MAX_INCOMING_HEAL_OVERFLOW = 1.0;
function HealthBar:UpdateHealPrediction (unitFrame)
	
	local healthBar = unitFrame[self.name];
	local predictionBar = healthBar.predictionBar;
	
	local database = ArenaLive:GetDBComponent(unitFrame.addon, self.name, unitFrame.group);
	local showHealPrediction = database.ShowHealPrediction;
	local unit = unitFrame.unit;
	
	if ( unitFrame.test or not predictionBar or not showHealPrediction or not unit ) then
		if ( predictionBar ) then
			predictionBar:Hide();
		end
		return;
	end
	
	local maxHealth = UnitHealthMax(unit);
	local currHealth = healthBar.currValue;
	local predictedHeal = --[[UnitGetIncomingHeals(unit) or]] 0;
	if ( maxHealth <= 0 ) then
		return;
	end
	
	if ( currHealth + predictedHeal > maxHealth * MAX_INCOMING_HEAL_OVERFLOW ) then
		predictedHeal = maxHealth * MAX_INCOMING_HEAL_OVERFLOW - currHealth;
	end	

	if ( predictedHeal == 0 ) then
		predictionBar:Hide();
	else
		predictionBar:ClearAllPoints();
			
		-- Set the position of the health prediction bar according to reverse fill settings of the healthbar
		if ( healthBar:GetReverseFill() ) then
			predictionBar:SetPoint("TOPRIGHT", healthBar:GetStatusBarTexture(), "TOPLEFT", 0, 0);
		else
			predictionBar:SetPoint("TOPLEFT", healthBar:GetStatusBarTexture(), "TOPRIGHT", 0, 0);
		end

		local totalWidth, totalHeight = healthBar:GetSize();
		local barWidth = (predictedHeal / maxHealth) * totalWidth;
		
		predictionBar:SetSize(barWidth, totalHeight);
		predictionBar:Show();	
	end

end

function HealthBar:Reset(unitFrame)
	local healthBar = unitFrame[self.name];
	if ( not healthBar.lockValues ) then
		healthBar:SetMinMaxValues(0, 1);
		healthBar:SetValue(1);
	end

	healthBar:SetStatusBarColor(0.5, 0.5, 0.5);
	
	if ( healthBar.absorbBar ) then
		healthBar.absorbBar:Hide();
	end

	if ( healthBar.absorbOverlay ) then
		healthBar.absorbOverlay:Hide();
	end

	if ( healthBar.absorbIndicator ) then
		healthBar.absorbIndicator:Hide();
	end

	if ( healthBar.healAbsorbBar ) then
		healthBar.healAbsorbBar:Hide();
	end

	if ( healthBar.predictionBar ) then
		healthBar.predictionBar:Hide();
	end
	
end

--[[ Method: SetColour
	 Sets the health bars colour according to a saved variable entry.
		healthBar (frame): Affected HealthBar.
]]--
function HealthBar:SetColour (unitFrame)

	if ( not unitFrame.unit ) then
		return;
	end
	
	local healthBar = unitFrame[self.name];
	local unit = unitFrame.unit;
	if ( healthBar.lockColour or healthBar.disconnected ) then
		healthBar:SetStatusBarColor(0.5, 0.5, 0.5);
		return;
	end
	
	
	local red, green, blue = 0, 1, 0;
	local isPlayer = UnitIsPlayer(unit);
	
	local database = ArenaLive:GetDBComponent(unitFrame.addon, self.name, unitFrame.group);
	local colourMode = database.ColourMode;
	
	if ( colourMode == "class" and ( isPlayer or unitFrame.test ) ) then
	
		local _, class 
		if ( unitFrame.test ) then
			class = ArenaLive.testModeValues[unitFrame.test]["class"];
		else
			_, class = UnitClass(unit);
		end
		
		if ( class ) then
			red, green, blue = RAID_CLASS_COLORS[class]["r"], RAID_CLASS_COLORS[class]["g"], RAID_CLASS_COLORS[class]["b"];
		end
	elseif ( colourMode == "class" ) then
		-- For NPCs show if they were tapped by someone else or not:
		if ( not UnitPlayerControlled(unit) and UnitIsTapped(unit) and not UnitIsTappedByPlayer(unit) and not UnitIsTappedByAllThreatList(unit) ) then
			-- Instead of 0.5 we use 0.7 to make it distinguishable from a resetted health bar.
			red, green, blue = 0.7, 0.7, 0.7
		end
	elseif ( colourMode == "reaction" ) then
		
		if ( unitFrame.test ) then
			red, green, blue = unpack(ArenaLive.testModeValues[unitFrame.test]["reaction"]);
		elseif ( not UnitPlayerControlled(unit) and UnitIsTapped(unit) and not UnitIsTappedByPlayer(unit) and not UnitIsTappedByAllThreatList(unit) ) then
			-- Instead of 0.5 we use 0.7 to make it distinguishable from a resetted health bar.
			red, green, blue = 0.7, 0.7, 0.7;
		else
			red, green, blue = UnitSelectionColor(unit);
		end
	elseif ( colourMode == "smooth" ) then
		-- Luckily Blizzard has already written a perfect function for smooth health bar colour. I just adjust this to the addon's needs.
		local value = healthBar.currValue; 
		local minValue = 0;
		local maxValue;

		if ( unitFrame.test ) then
			maxValue = ArenaLive.testModeValues[unitFrame.test]["healthMax"];
		else
			maxValue = UnitHealthMax(unit);	
		end		
		
		if ( (maxValue - minValue) > 0 ) then
			value = (value - minValue) / (maxValue - minValue);
		else
			value = 0;
		end
		
		if( value > 0.5 ) then
			red = (1.0 - value) * 2;
			green = 1.0;
		else
			red = 1.0;
			green = value * 2;
		end

		blue = 0;
	elseif ( colourMode == "team" ) then
		local addonDB = ArenaLive:GetDBComponent(unitFrame.addon);
		local factionGroup = UnitFactionGroup(unit);
		if ( addonDB.TeamA and addonDB.TeamB ) then
			local unitType = string.match(unit, "^([a-z]+)[0-9]+$") or unit;
			if ( unitType == "spectateda" or unitType == "spectatedpeta" or factionGroup == "Alliance" ) then
				red, green, blue = unpack(addonDB.TeamA.Colour);
			elseif ( unitType == "spectatedb" or unitType == "spectatedpetb" or factionGroup == "Horde" ) then
				red, green, blue = unpack(addonDB.TeamB.Colour);
			end
		end
	end
	
	healthBar:SetStatusBarColor(red, green, blue);
end

--[[ Method: OnUpdate
	 Function for the OnUpdate script. This is used to allow frequent updates for player and target health bars.
		elapsed (number): Time since last frame update.
]]--
function HealthBar:OnUpdate (elapsed)
	for unit, currCacheHealth in pairs(frequentUpdates) do
		local currHealth = UnitHealth(unit);
		if ( UnitGUID(unit) and currHealth ~= currCacheHealth ) then
			frequentUpdates[unit] = currHealth;
			if ( ArenaLive:IsUnitInUnitFrameCache(unit) ) then
				for id in ArenaLive:GetAffectedUnitFramesByUnit(unit) do
					local unitFrame = ArenaLive:GetUnitFrameByID(id);
					if ( unitFrame[self.name] ) then
						HealthBar:Update(unitFrame);
						-- Update health bar text if there is one for this unit frame:
						if ( unitFrame.HealthBarText ) then
							HealthBarText:Update(unitFrame);
						end
					end
				end
			end
		end
	end
end

--[[ Method: OnEvent
	 OnEvent script handler for HealthBar handler.
		event (string): Event that fired.
		... (mixed): A list of further args that accompany the event.
]]--
function HealthBar:OnEvent (event, ...)
	local unit = ...;
	
	if ( event == "UNIT_HEALTH" ) then
		-- Filter units that are updated by the OnUpdate script:
		if ( not frequentUpdates[unit] ) then
			if ( ArenaLive:IsUnitInUnitFrameCache(unit) ) then
				for id in ArenaLive:GetAffectedUnitFramesByUnit(unit) do
					local unitFrame = ArenaLive:GetUnitFrameByID(id);
					if ( unitFrame[self.name] ) then
						HealthBar:Update(unitFrame);
						-- Update health bar text if there is one for this unit frame:
						if ( unitFrame.HealthBarText ) then
							HealthBarText:Update(unitFrame);
						end
					end
				end
			end
		end
	elseif ( event == "UNIT_MAXHEALTH" ) then
		if ( ArenaLive:IsUnitInUnitFrameCache(unit) ) then
			for id in ArenaLive:GetAffectedUnitFramesByUnit(unit) do
				local unitFrame = ArenaLive:GetUnitFrameByID(id);
				if ( unitFrame[self.name] ) then
					HealthBar:Update(unitFrame);
					-- Update health bar text if there is one for this unit frame:
					if ( unitFrame.HealthBarText ) then
						HealthBarText:Update(unitFrame);
					end
				end
			end
		end
	elseif ( event == "UNIT_ABSORB_AMOUNT_CHANGED" ) then
		if ( ArenaLive:IsUnitInUnitFrameCache(unit) ) then
			for id in ArenaLive:GetAffectedUnitFramesByUnit(unit) do
				
				local unitFrame = ArenaLive:GetUnitFrameByID(id);
				if ( unitFrame[self.name] ) then
					HealthBar:UpdateAbsorb(unitFrame);
				end
			end
		end
	elseif ( event == "UNIT_HEAL_ABSORB_AMOUNT_CHANGED" ) then
		-- TODO
	elseif ( event == "UNIT_HEAL_PREDICTION" ) then
		if ( ArenaLive:IsUnitInUnitFrameCache(unit) ) then
			for id in ArenaLive:GetAffectedUnitFramesByUnit(unit) do
				local unitFrame = ArenaLive:GetUnitFrameByID(id);
				if ( unitFrame[self.name] ) then
					HealthBar:UpdateHealPrediction(unitFrame);
				end
			end
		end
	elseif ( event == "UNIT_FACTION" ) then
		if ( ArenaLive:IsUnitInUnitFrameCache(unit) ) then
			for id in ArenaLive:GetAffectedUnitFramesByUnit(unit) do
				local unitFrame = ArenaLive:GetUnitFrameByID(id);
				if ( unitFrame[self.name] ) then
					HealthBar:SetColour(unitFrame);
				end
			end
		end
	end

end

-- Option Settings:
HealthBar.optionSets = {
	["ColourMode"] = {
		["type"] = "DropDown",
		["title"] = L["Colour Mode"],
		["tooltip"] = L["Set the colour mode of the unit frame's health bar."],
		["width"] = 150,
		["infoTable"] = {
			[1] = {
				["text"] = L["None"],
				["value"] = "none",
			},
			[2] = {
				["text"] = L["Class Colour"],
				["value"] = "class",
			},
			[3] = {
				["text"] = L["Reaction Colour"],
				["value"] = "reaction",
			},
			[4] = {
				["text"] = L["Current Health"],
				["value"] = "smooth",
			},
		},
		["GetDBValue"] = function (frame) local database = ArenaLive:GetDBComponent(frame.addon, frame.handler, frame.group); return database.ColourMode; end,
		["SetDBValue"] = function (frame, newValue) local database = ArenaLive:GetDBComponent(frame.addon, frame.handler, frame.group); database.ColourMode = newValue; end,
		["postUpdate"] = function (frame, newValue, oldValue) for id, unitFrame in ArenaLive:GetAllUnitFrames() do if ( unitFrame.addon == frame.addon and unitFrame.group == frame.group ) then HealthBar:SetColour(unitFrame); end end end,
	},
	["EnableAbsorb"] = {
		["type"] = "CheckButton",
		["title"] = L["Show Absorbs"],
		["tooltip"] = L["Enables the display of absorb shields."],
		["GetDBValue"] = function (frame) local database = ArenaLive:GetDBComponent(frame.addon, frame.handler, frame.group); return database.ShowAbsorb; end,
		["SetDBValue"] = function (frame, newValue) local database = ArenaLive:GetDBComponent(frame.addon, frame.handler, frame.group); database.ShowAbsorb = newValue; end,
		["postUpdate"] = function (frame, newValue, oldValue) for id, unitFrame in ArenaLive:GetAllUnitFrames() do if ( unitFrame.addon == frame.addon and unitFrame.group == frame.group ) then HealthBar:Update(unitFrame); end end end,
	},
	["EnablePredictedHeal"] = {
		["type"] = "CheckButton",
		["title"] = L["Show Predicted Healing"],
		["tooltip"] = L["Enables the display of incoming heals."],
		["GetDBValue"] = function (frame) local database = ArenaLive:GetDBComponent(frame.addon, frame.handler, frame.group); return database.ShowHealPrediction; end,
		["SetDBValue"] = function (frame, newValue) local database = ArenaLive:GetDBComponent(frame.addon, frame.handler, frame.group); database.ShowHealPrediction = newValue; end,
		["postUpdate"] = function (frame, newValue, oldValue) for id, unitFrame in ArenaLive:GetAllUnitFrames() do if ( unitFrame.addon == frame.addon and unitFrame.group == frame.group ) then HealthBar:UpdateHealPrediction(unitFrame); end end end,
	},
	["ReverseFill"] = {
		["type"] = "CheckButton",
		["title"] = L["Reverse Fill Healthbar"],
		["tooltip"] = L["If checked, the healthbar will fill from right to left, instead of from left to right."],
		["GetDBValue"] = function (frame) local database = ArenaLive:GetDBComponent(frame.addon, frame.handler, frame.group); return database.ReverseFill; end,
		["SetDBValue"] = function (frame, newValue) local database = ArenaLive:GetDBComponent(frame.addon, frame.handler, frame.group); database.ReverseFill = newValue; end,
		["postUpdate"] = function (frame, newValue, oldValue) for id, unitFrame in ArenaLive:GetAllUnitFrames() do if ( unitFrame.addon == frame.addon and unitFrame.group == frame.group and unitFrame[HealthBar.name] ) then HealthBar:SetReverseFill(unitFrame[HealthBar.name], unitFrame.addon, unitFrame.group); HealthBar:Update(unitFrame); end end end,
	},
};

-- Set OnUpdate script:
HealthBar:SetScript("OnUpdate", HealthBar.OnUpdate);