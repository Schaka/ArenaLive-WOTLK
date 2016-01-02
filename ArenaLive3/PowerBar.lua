--[[ ArenaLive Core Functions: PowerBar Handler
Created by: Vadrak
Creation Date: 05.04.2014
Last Update: 17.05.2014
These functions are used to set up every power bar.
]]--

-- ArenaLive addon Name and localisation table:
local addonName, L = ...;

--[[
**************************************************
******* GENERAL HANDLER SET UP STARTS HERE *******
**************************************************
]]--

-- Create new handler:
local PowerBar = ArenaLive:ConstructHandler("PowerBar", true, true);
local PowerBarText = ArenaLive:GetHandler("PowerBarText");

-- Legit units for frequent updates with their current power:
local frequentUpdates = 
	{
		["player"] = 0,
		["target"] = 0,
	};
	
-- Register the handler for all needed events.
PowerBar:RegisterEvent("UNIT_DISPLAYPOWER");

PowerBar:RegisterEvent("UNIT_MANA");
PowerBar:RegisterEvent("UNIT_MAXMANA");

PowerBar:RegisterEvent("UNIT_ENERGY");
PowerBar:RegisterEvent("UNIT_MAXENERGY");

PowerBar:RegisterEvent("UNIT_POWER");
PowerBar:RegisterEvent("UNIT_MAXPOWER");



--[[
****************************************
****** OBJECT METHODS START HERE ******
****************************************
]]--
--[[ Method: Reset
	 Reset power bar values.
		powerBar (frame): Affected power bar.
]]--
local function Reset(powerBar)
	if ( not powerBar.lockValues ) then
		powerBar:SetMinMaxValues(0, 1);
		powerBar:SetValue(1);
	end
	
	powerBar:SetStatusBarColor(0.5, 0.5, 0.5);
end

--[[
****************************************
****** HANDLER METHODS START HERE ******
****************************************
]]--
--[[ Method: ConstructObject
	 Creates a new frame of the type power bar.
		powerBar (frame [Statusbar]): The frame that is going to be set up as a power bar.
		addonName (string): Name of the addon of the power bar's unit frame.
		frameType (string): Name of the frame group of the power bar's unit frame.
]]--
function PowerBar:ConstructObject(powerBar, addonName, frameType)
	
	ArenaLive:CheckArgs(powerBar, "StatusBar", addonName, "string", frameType, "string");

	-- Set reverse fill:
	PowerBar:SetReverseFill(powerBar, addonName, frameType);	
end


--[[ Method: SetReverseFill
	 Set whether the specified power bar should be reverse filled or not.
		powerBar (frame [Statusbar]): The affected power bar.
]]--
function PowerBar:SetReverseFill (powerBar, addonName, frameType)
		local database = ArenaLive:GetDBComponent(addonName, self.name, frameType);
		local reverseFill = database.ReverseFill;
		--powerBar:SetReverseFill(reverseFill);
end

--[[ Method: Update
	 General update function for power bars.
		powerBar (frame): Affected power bar.
]]--
function PowerBar:Update (unitFrame)
	local unit = unitFrame.unit;
	local powerBar = unitFrame[self.name];
	
	if ( not unit or powerBar.lockValues ) then
		return;
	end
	
	powerBar.disconnected = ( not UnitIsConnected(unit) and not unitFrame.test );
	PowerBar:SetPowerType(unitFrame);
	
	local maxPower, currPower;
	if ( unitFrame.test ) then
		currPower = ArenaLive.testModeValues[unitFrame.test]["powerCurr"];
		maxPower = ArenaLive.testModeValues[unitFrame.test]["powerMax"];
	else
		currPower = UnitPower(unit, powerBar.powerType);
		maxPower = UnitPowerMax(unit, powerBar.powerType);
	end
	
	powerBar.forceHideText = nil;
	if (maxPower == 0 ) then
		maxPower = 1;
		powerBar.forceHideText = true;
	end
	
	if ( powerBar.disconnected ) then
		currPower = maxPower;
	end
	
	powerBar:SetMinMaxValues(0, maxPower);
	powerBar:SetValue(currPower);
	powerBar.currValue = currPower;
end
--[[ Method: Reset
	 Resets power bars value and colour.
		powerBar (frame): Affected power bar.
]]--
function PowerBar:Reset(unitFrame)
	local powerBar = unitFrame[self.name];
	if ( not powerBar.lockValues ) then
		powerBar:SetMinMaxValues(0, 1);
		powerBar:SetValue(1);
	end
end

--[[ Method: SetPowerType
	 Sets the power bars power type and colour according to unit info.
		powerBar (frame): Affected power bar.
]]--
function PowerBar:SetPowerType(unitFrame)

	local powerBar = unitFrame[self.name];
	if ( powerBar.lockColour or powerBar.disconnected ) then
		powerBar:SetStatusBarColor(0.5, 0.5, 0.5);
		return;
	end
	
	local unit = unitFrame.unit;
	local powerType, powerToken, red, green, blue;
	if ( unitFrame.test ) then
		powerType = ArenaLive.testModeValues[unitFrame.test]["powerType"]
	else
		powerType, powerToken, red, green, blue = UnitPowerType(unit);
	end
	
	local info = PowerBarColor[powerToken];
	
	if ( info ) then
		red = info.r
		green = info.g
		blue = info.b
	else
		if ( not red ) then
			info = PowerBarColor[powerType] or PowerBarColor["MANA"];
			red = info.r
			green = info.g
			blue = info.b
		end
	end
	
	powerBar.powerType = powerType;
	powerBar:SetStatusBarColor(red, green, blue);

end

--[[ Method: OnUpdate
	 Function for the OnUpdate script. This is used to allow frequent updates for player and target power bars.
		elapsed (number): Time since last frame update.
]]--
function PowerBar:OnUpdate(elapsed)
	for unit, cacheCurrPower in pairs(frequentUpdates) do
		local currPower = UnitPower(unit, UnitPowerType(unit));
		
		if ( UnitGUID(unit) and currPower ~= cacheCurrPower ) then
			frequentUpdates[unit] = currPower;
			if ( ArenaLive:IsUnitInUnitFrameCache(unit) ) then
				for id in ArenaLive:GetAffectedUnitFramesByUnit(unit) do
					local unitFrame = ArenaLive:GetUnitFrameByID(id);
					if ( unitFrame[self.name] ) then
						PowerBar:Update(unitFrame);
					end
					if ( unitFrame["PowerBarText"] ) then
						PowerBarText:Update(unitFrame);
					end
				end
			end
		end
	end
end

--[[ Method: OnEvent
	 OnEvent script handler for PowerBar handler.
		event (string): Event that fired.
		... (mixed): A list of further args that accompany the event.
]]--
function PowerBar:OnEvent (event, ...)
	local unit = ...;
	if ( event == "UNIT_POWER" or event == "UNIT_MANA" or event == "UNIT_ENERGY" ) then
		-- Filter units that are updated by the OnUpdate script:
		if ( not frequentUpdates[unit] ) then
			if ( ArenaLive:IsUnitInUnitFrameCache(unit) ) then
				for id in ArenaLive:GetAffectedUnitFramesByUnit(unit) do
					local unitFrame = ArenaLive:GetUnitFrameByID(id);
					if ( unitFrame[self.name] ) then
						PowerBar:Update(unitFrame);
					end
					if ( unitFrame["PowerBarText"] ) then
						PowerBarText:Update(unitFrame);
					end
				end
			end
		end
	elseif ( event == "UNIT_MAXPOWER" or event == "UNIT_MAXMANA" or event == "UNIT_MAXENERGY" or event == "UNIT_DISPLAYPOWER" ) then
		if ( ArenaLive:IsUnitInUnitFrameCache(unit) ) then
			for id in ArenaLive:GetAffectedUnitFramesByUnit(unit) do
				local unitFrame = ArenaLive:GetUnitFrameByID(id);
				if ( unitFrame[self.name] ) then
					PowerBar:Update(unitFrame);
				end
				if ( unitFrame["PowerBarText"] ) then
					PowerBarText:Update(unitFrame);
				end
			end
		end
	end

end

-- Set OnUpdate script (TODO: Enable and Disable function):
PowerBar:SetScript("OnUpdate", PowerBar.OnUpdate);

-- Option Settings:
PowerBar.optionSets = {
	["ReverseFill"] = {
		["type"] = "CheckButton",
		["title"] = L["Reverse Fill Powerbar"],
		["tooltip"] = L["If checked, the powerbar will fill from right to left, instead of from left to right."],
		["GetDBValue"] = function (frame) local database = ArenaLive:GetDBComponent(frame.addon, frame.handler, frame.group); return database.ReverseFill; end,
		["SetDBValue"] = function (frame, newValue) local database = ArenaLive:GetDBComponent(frame.addon, frame.handler, frame.group); database.ReverseFill = newValue; end,
		["postUpdate"] = function (frame, newValue, oldValue) for id, unitFrame in ArenaLive:GetAllUnitFrames() do if ( unitFrame.addon == frame.addon and unitFrame.group == frame.group and unitFrame[frame.handler] ) then PowerBar:SetReverseFill(unitFrame[frame.handler], unitFrame.addon, unitFrame.group); end end end,
	},
};