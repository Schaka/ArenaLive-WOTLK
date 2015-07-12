--[[ ArenaLive Core Functions: Diminishing Return Tracker Handler
Created by: Vadrak
Creation Date: 27.04.2014
Last Update: 02.03.2015
TODO: Collect removed cache tables to reduce garbage.
]]--

-- ArenaLive addon Name and localisation table:
local addonName, L = ...;

--[[
**************************************************
******* GENERAL HANDLER SET UP STARTS HERE *******
**************************************************
]]--
local DRTracker = ArenaLive:ConstructHandler("DRTracker", true, true);
DRTracker.canToggle = true;
DRTracker.testValues = {339, 1833, 3355, 33786, 15487};

-- Register the handler for all needed events.
DRTracker:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED_SPELL_AURA_APPLIED");
DRTracker:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED_SPELL_AURA_REFRESH");
DRTracker:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED_SPELL_AURA_REMOVED");
DRTracker:RegisterEvent("ARENA_OPPONENT_UPDATE");

local DEFAULT_X_OFFSET = 5;
local DEFAULT_Y_OFFSET = 5;

local DIMINISHING_RETURN_DURATION = 18.4;
local DEFAULT_CC_DURATION = 9; -- 1 Seconds longer than actual max cc duration, so it won't proc before the cc actually finished.
local NUMBER_DIMINISHING_RETURNS = 5; -- Number of different DR categories currently in the game.

-- Table to store abbreviated CC category names:
local ccCategoriesToAbbreviation = {
	["disorient"] = L["DISORIENT_ABBREVIATION"],
	["incapacitate"] = L["INCAPACITATE_ABBREVIATION"],
	["root"] = L["ROOT_ABBREVIATION"],
	["silence"] = L["SILENCE_ABBREVIATION"],
	["stun"] = L["STUN_ABBREVIATION"],
};

-- Create a table to store all diminishing returns in:
local DRCache = {};

-- Crete throttle variables for OnUpdate script:
DRTracker.elapsed = 0;
local THROTTLE_INTERVAL = 0.1;



--[[
****************************************
****** HANDLER METHODS START HERE ******
****************************************
]]--
--[[ Method: ConstructObject
	 Creates a new aura frame.
		drTracker (Frame): The frame that is going to be set up as an diminishing return tracker.
]]--
function DRTracker:ConstructObject(drTracker, addonName, frameType)

	-- Set basic info:
	drTracker.numIcons = 0;
	
	-- Set initial size:
	DRTracker:UpdateSize(drTracker, addonName, frameType);
end

function DRTracker:OnEnable(unitFrame)
	local drTracker = unitFrame[self.name];
	drTracker:Show();
	DRTracker:Update(unitFrame);
end

function DRTracker:OnDisable(unitFrame)
	local drTracker = unitFrame[self.name];
	DRTracker:Reset(unitFrame);
	drTracker:Hide();
end

function DRTracker:Update(unitFrame)

	local guid = unitFrame.guid;
	local drTracker = unitFrame[self.name];
	
	if ( ( not guid and not unitFrame.test ) or not drTracker.enabled ) then
		return;
	end
	
	
	local database = ArenaLive:GetDBComponent(unitFrame.addon, self.name, unitFrame.group);
	local maxIcons = database.MaxShownIcons;
	local loopMax;
	
	if ( drTracker.numIcons >= maxIcons ) then
		loopMax = drTracker.numIcons;
	else
		loopMax = maxIcons;
	end

	if ( unitFrame.test ) then
		for i = 1, loopMax do
			local icon = drTracker["icon"..i];
			if ( icon and i > maxIcons ) then
				DRTracker:ResetIcon(icon);
			else
				if ( not icon ) then
					icon = DRTracker:CreateIcon(unitFrame);
				end
				local texture
				if(DRTracker.testValues[i]) then
					_, _, texture = GetSpellInfo(DRTracker.testValues[i]);
				end
				
				local drColour = math.random(3);
				local red, green, blue;
				if ( drColour == 1 ) then
					red, green, blue = 0, 1, 0;
				elseif ( drColour == 2 ) then
					red, green, blue = 1, 1, 0;
				else
					red, green, blue = 1, 0, 0;
				end
				
				local drType = ArenaLive.spellDB.DiminishingReturns[DRTracker.testValues[i]];
				if ( drType ) then
					icon.text:Show();
					icon.text:SetText(ccCategoriesToAbbreviation[drType] or "");
				else
					icon.text:Hide();
				end
				icon.text:SetTextColor(red, green, blue);
				icon.cooldown.text:SetTextColor(red, green, blue);
				icon.border:SetVertexColor(red, green, blue);
				icon.texture:SetTexture(texture or "Interface\\Icons\\INV_Misc_QuestionMark");
				icon.cooldown:Set(GetTime(), DIMINISHING_RETURN_DURATION);
				icon:Show();
			end
		end
	elseif ( DRCache[guid] ) then
		for i = 1, loopMax do
			local icon = drTracker["icon"..i];
			if ( icon and i > maxIcons ) then
				DRTracker:ResetIcon(icon);
			else
				if ( not icon ) then
					icon = DRTracker:CreateIcon(unitFrame);
				end
				
				if ( DRCache[guid][i] ) then

					if ( DRCache[guid][i]["isActive"] ) then
						local duration = DRCache[guid][i]["duration"];
						local expires = DRCache[guid][i]["expires"];
						local startTime = expires - duration;
						icon.cooldown:Set(startTime, duration);
					else
						icon.cooldown:Reset();
					end
					
					local drType = DRCache[guid][i]["type"];
					if ( drType ) then
						icon.text:Show();
						icon.text:SetText(ccCategoriesToAbbreviation[drType] or "");
					else
						icon.text:Hide();
					end
					
					icon.texture:SetTexture(DRCache[guid][i]["texture"]);
					DRTracker:UpdateIconDRColour(icon, guid);
					icon:Show();
				else
					DRTracker:ResetIcon(icon);
				end -- endif
			end -- endif
		end -- endfor
	else
		DRTracker:Reset(unitFrame);
	end
end

function DRTracker:Reset(unitFrame)
	
	local drTracker = unitFrame[self.name];
	for i = 1, drTracker.numIcons do
		local icon = drTracker["icon"..i];
		DRTracker:ResetIcon(icon);
	end

end

function DRTracker:UpdateSize(drTracker, addonName, frameType)
	
	local database = ArenaLive:GetDBComponent(addonName, self.name, frameType);
	local size = database.IconSize;
	local maxIcons = database.MaxShownIcons;
	local direction = database.GrowDirection;
	local totalWidth, totalHeight = 0, 0;
	
	-- Update icon sizes:
	for i = 1, drTracker.numIcons do
		local icon = drTracker["icon"..i];
		icon:SetSize(size, size);
		local fontName, fontHeight, fontFlags = icon.text:GetFont();
		local fontHeight = size*0.33;
		icon.text:SetFont(fontName, fontHeight, fontFlags);
	end
	
	-- Get total height and width of the DR Tracker:
	if ( direction == "LEFT" or direction == "RIGHT" ) then
		totalWidth = maxIcons * ( size + DEFAULT_X_OFFSET );
		totalHeight = size;
	elseif ( direction == "UP" or direction == "DOWN" ) then
		totalHeight = maxIcons * ( size + DEFAULT_Y_OFFSET );
		totalWidth = size;
	end
	
	drTracker:SetSize(totalWidth, totalHeight);
end

function DRTracker:CreateIcon(unitFrame)
	
	local drTracker = unitFrame[self.name];
	local database = ArenaLive:GetDBComponent(unitFrame.addon, self.name, unitFrame.group);
	local direction = database.GrowDirection;
	local size = database.IconSize;
	local id = drTracker.numIcons + 1;
	local prefix = drTracker:GetName(); 
	local icon = CreateFrame("Frame", prefix.."Icon"..id, drTracker, "ArenaLive_DrTrackerIconTemplate");
	
	
	
	-- Some References of the icon are set in the template in DRTracker.xml via parentKey="":
		-- icon.texture = Texture to show the spell icon.
		-- icon.cooldown = Cooldown frame of the icon.
	icon.text =  _G[prefix.."Icon"..id.."Text"];
	
	-- Get anchor values:
	local point, relativeTo, relativePoint, xOffset, yOffset;
	if ( direction == "LEFT" ) then
		point = "RIGHT";
		relativePoint = "LEFT";
		xOffset, yOffset = -DEFAULT_X_OFFSET, 0;
	elseif ( direction == "RIGHT" ) then
		point = "LEFT";
		relativePoint = "RIGHT";
		xOffset, yOffset = DEFAULT_X_OFFSET, 0;
	elseif ( direction == "UP" ) then
		point = "BOTTOM";
		relativePoint = "TOP";
		xOffset, yOffset = 0, DEFAULT_Y_OFFSET;
	elseif ( direction == "DOWN" ) then
		point = "TOP";
		relativePoint = "BOTTOM";
		xOffset, yOffset = 0, -DEFAULT_Y_OFFSET;
	end
	
	if ( id == 1 ) then
		relativePoint = point;
		relativeTo = drTracker;
		xOffset, yOffset = 0, 0;
	else
		relativeTo = drTracker["icon"..drTracker.numIcons];
	end
	
	icon:SetPoint(point, relativeTo, relativePoint, xOffset, yOffset);
	
	-- Set icon size:
	icon:SetSize(size, size);
	local fontName, fontHeight, fontFlags = icon.text:GetFont();
	local fontHeight = size*0.5;
	icon.text:SetFont("Fonts\\FRIZQT__.TTF", fontHeight, fontFlags);
	
	-- Set ID to easier access the icons cache entry:
	icon:SetID(id);
	
	-- Add reference to tracker:
	drTracker["icon"..id] = icon;
	drTracker.numIcons = drTracker.numIcons + 1;
	
	-- Construct Cooldown:
	ArenaLive:ConstructHandlerObject(icon.cooldown, "Cooldown", unitFrame.addon, icon);
	
	return icon;
end

function DRTracker:ResetIcon(icon)
	icon:Hide();
	icon.texture:SetTexture();
	icon.cooldown:Reset();
end

function DRTracker:UpdateIconDRColour(icon, guid)

	if ( not icon.text ) then
		return;
	end
	
	local id = icon:GetID();
	
	-- Colour the cooldown text according to the DR stacks:
	local stack = DRCache[guid][id]["drMultiplier"];
	if ( stack == 0.5 ) then
		icon.text:SetTextColor(0, 1, 0);
		icon.cooldown.text:SetTextColor(0, 1, 0);
		icon.border:SetVertexColor(0, 1, 0);
	elseif ( stack == 0.25 ) then
		icon.text:SetTextColor(1, 1, 0);
		icon.cooldown.text:SetTextColor(1, 1, 0);
		icon.border:SetVertexColor(1, 1, 0);
	elseif ( stack == 0 ) then
		icon.text:SetTextColor(1, 0, 0);
		icon.cooldown.text:SetTextColor(1, 0, 0);
		icon.border:SetVertexColor(1, 0, 0);
	end

end

function DRTracker:UpdateIconPositions(drTracker)

	for i = 1, drTracker.numIcons do
		local icon = drTracker["icon"..i];

		-- Get anchor values:
		if ( direction == "LEFT" ) then
			point = "RIGHT";
			relativePoint = "LEFT";
			xOffset, yOffset = -DEFAULT_X_OFFSET, 0;
		elseif ( direction == "RIGHT" ) then
			point = "LEFT";
			relativePoint = "RIGHT";
			xOffset, yOffset = DEFAULT_X_OFFSET, 0;
		elseif ( direction == "UP" ) then
			point = "BOTTOM";
			relativePoint = "TOP";
			xOffset, yOffset = 0, DEFAULT_Y_OFFSET;
		elseif ( direction == "DOWN" ) then
			point = "TOP";
			relativePoint = "BOTTOM";
			xOffset, yOffset = 0, -DEFAULT_Y_OFFSET;
		end
		
		if ( i == 1 ) then
			relativePoint = point;
			relativeTo = drTracker;
			xOffset, yOffset = 0, 0;
		else
			relativeTo = drTracker["icon"..i-1];
		end
		
		icon:ClearAllPoints();
		icon:SetPoint(point, relativeTo, relativePoint, xOffset, yOffset);		
	end

end

local function sortFunc(a, b)

	if ( a.isActive and not b.isActive ) then
		return true;
	elseif ( not a.isActive and b.isActive ) then
		return false;
	else
		return a.expires < b.expires;
	end

end

function DRTracker:UpdateDiminishingReturn(guid, spellID)

	local drType = ArenaLive.spellDB.DiminishingReturns[spellID];
	local drVarType = type(drType);
	if ( drVarType == "string" ) then
		DRTracker:SetDiminishingReturn(guid, spellID, drType);
	elseif ( drVarType == "table" ) then
		for key, realDRType in ipairs(drType) do
			DRTracker:SetDiminishingReturn(guid, spellID, realDRType);
		end
	end
end

function DRTracker:SetDiminishingReturn(guid, spellID, drType)
	
	if ( not guid or not spellID or not drType ) then
		return; -- Invalid method call.
	end
	
	if ( not DRCache[guid] ) then
		DRCache[guid] = {};
	end
	
	-- Get (new) spell texture:
	local _, _, texture = GetSpellInfo(spellID);		
	
	-- Iterate through all DR tables to check whether the specified DR is already used or not:
	local match;
	for index, drTable in ipairs(DRCache[guid]) do
		if ( drTable["type"] == drType ) then
			match = index;
			break;
		end
	end
	
	if ( match ) then
		-- Already active DR:
		if ( DRCache[guid][match]["drMultiplier"] > 0 ) then
			-- Update DR info, if the DR isn't already full:
			local expires = GetTime() + DEFAULT_CC_DURATION * DRCache[guid][match]["drMultiplier"];
			DRCache[guid][match]["forcedStart"] = nil;
			DRCache[guid][match]["isActive"] = nil;
			DRCache[guid][match]["duration"] = nil;
			DRCache[guid][match]["expires"] = expires;
			DRCache[guid][match]["drMultiplier"] = DRCache[guid][match]["drMultiplier"] - 0.25;
		elseif ( spellID == 108194 ) then
			-- BUGFIX: Asphyxiate silences the target,
			-- if it is immune to stuns, due to DR.
			-- Recurse with silence category instead.
			DRTracker:SetDiminishingReturn(guid, spellID, "silence");
			return;
		end
		DRCache[guid][match]["texture"] = texture;
	else		
		-- New DR for this GUID, add to guid table:
		table.insert(DRCache[guid], {});
		local n = #DRCache[guid];
		DRCache[guid][n]["type"] = drType;
		DRCache[guid][n]["spellID"] = spellID
		DRCache[guid][n]["expires"] = GetTime() + DEFAULT_CC_DURATION;
		DRCache[guid][n]["drMultiplier"] = 0.5;
		DRCache[guid][n]["texture"] = texture;
	end
	
	-- Sort GUID table by dr duration:
	table.sort(DRCache[guid], sortFunc);
	DRTracker:CallUpdateForGUID(guid);	
	
end

function DRTracker:ActivateDiminishingReturn(guid, spellID, forcedStart)
	
	if ( DRCache[guid] ) then
		for index, drTable in ipairs(DRCache[guid]) do
			if ( spellID == drTable["spellID"] and not drTable["isActive"] or ( not forcedStart and drTable["forcedStart"] ) ) then
				local duration = DIMINISHING_RETURN_DURATION;
				local expires = GetTime() + duration;
				DRCache[guid][index]["forcedStart"] = forcedStart;
				DRCache[guid][index]["duration"] = duration;
				DRCache[guid][index]["expires"] = expires;
				DRCache[guid][index]["isActive"] = true;		
					
				DRTracker:CallUpdateForGUID(guid);
			end
		end				
	end
end

function DRTracker:CallUpdateForGUID (guid)
	if ( ArenaLive:IsGUIDInUnitFrameCache(guid) ) then
		for id in ArenaLive:GetAffectedUnitFramesByGUID(guid) do
			local frame = ArenaLive:GetUnitFrameByID(id);
			if ( frame[self.name] and frame[self.name]["enabled"] ) then
				DRTracker:Update(frame);
			end
		end
	end
end

function DRTracker:OnEvent(event, ...)

	if ( event == "ARENA_OPPONENT_UPDATE" ) then
		local unit, state = ...;
		
		local guid = UnitGUID(unit);
		
		-- Reset Cache entries for an arena opponent that has left the arena:
		if ( guid and state == "destroyed" and DRCache[guid] ) then
			ArenaLive:Message("Clearing cache for arena opponent with GUID: %s", "debug", guid);
			table.wipe(DRCache[guid]);
			DRCache[guid] = nil;
			DRTracker:CallUpdateForGUID(guid);
		end
	else
		local sourceGUID = select(3, ...);
		local destGUID = select(8, ...);	
		local spellID = select(12, ...);

		if ( not ArenaLive.spellDB.DiminishingReturns[spellID] or destGUID == sourceGUID ) then
			return;
		end
		
		if ( event == "COMBAT_LOG_EVENT_UNFILTERED_SPELL_AURA_APPLIED" or event == "COMBAT_LOG_EVENT_UNFILTERED_SPELL_AURA_REFRESH" ) then
			DRTracker:UpdateDiminishingReturn(destGUID, spellID);
		elseif ( event == "COMBAT_LOG_EVENT_UNFILTERED_SPELL_AURA_REMOVED" ) then
			DRTracker:ActivateDiminishingReturn(destGUID, spellID, false);
		end

	end

end


function DRTracker:OnUpdate(elapsed)
	
	DRTracker.elapsed = DRTracker.elapsed + elapsed;
	if ( DRTracker.elapsed >= THROTTLE_INTERVAL ) then
		DRTracker.elapsed = 0;
		local theTime = GetTime();
		for guid in pairs(DRCache) do
			for index in ipairs(DRCache[guid]) do
				
				if ( not DRCache[guid][index]["isActive"] and theTime >= DRCache[guid][index]["expires"] ) then
					--[[ NOTE: This is a fallback. Sometimes the COMBAT_LOG_EVENT_UNFILTERED_SPELL_AURA_REMOVED event cannot trigger, because a unit
							   ran out of combat log range. So we automatically trigger the DR after a certain amount of time.
					]]
					DRTracker:ActivateDiminishingReturn(guid, DRCache[guid][index]["spellID"], true)
				elseif ( DRCache[guid][index]["isActive"] and theTime >= DRCache[guid][index]["expires"] ) then
					
					-- DR has expired:
					table.wipe(DRCache[guid][index]);
					table.remove(DRCache[guid], index);
					
					if ( #DRCache[guid] == 0 ) then
						DRCache[guid] = nil;
					end
					DRTracker:CallUpdateForGUID(guid);
					
				end
			end
		end
	end

end

DRTracker:SetScript("OnUpdate", DRTracker.OnUpdate);

DRTracker.optionSets = {
	["Enable"] = {
		["type"] = "CheckButton",
		["title"] = L["Enable"],
		["tooltip"] = L["Enables the diminishing return tracker."],
		["GetDBValue"] = function (frame) local database = ArenaLive:GetDBComponent(frame.addon, frame.handler, frame.group); return database.Enabled; end,
		["SetDBValue"] = function (frame, newValue) local database = ArenaLive:GetDBComponent(frame.addon, frame.handler, frame.group); database.Enabled = newValue; end,
		["postUpdate"] = function (frame, newValue, oldValue) for id, unitFrame in ArenaLive:GetAllUnitFrames() do if ( unitFrame.addon == frame.addon and unitFrame.group == frame.group and unitFrame[frame.handler] ) then unitFrame:ToggleHandler(frame.handler); end end end,
	},
	["Size"] = {
		["type"] = "Slider",
		["title"] = L["Icon Size"],
		["tooltip"] = L["Sets the size of the diminishing return tracker's icons."],
		["width"] = 100,
		["height"] = 17,		
		["min"] = 1,
		["max"] = 64,
		["step"] = 1,
		["inputType"] = "NUMERIC",
		["GetDBValue"] = function (frame) local database = ArenaLive:GetDBComponent(frame.addon, frame.handler, frame.group); return database.IconSize; end,
		["SetDBValue"] = function (frame, newValue) local database = ArenaLive:GetDBComponent(frame.addon, frame.handler, frame.group); database.IconSize = newValue; end,
		["postUpdate"] = function (frame, newValue, oldValue) for id, unitFrame in ArenaLive:GetAllUnitFrames() do if ( unitFrame.addon == frame.addon and unitFrame.group == frame.group and unitFrame[frame.handler] ) then DRTracker:UpdateSize(unitFrame[frame.handler], unitFrame.addon, unitFrame.group); end end end,
	},
	["Direction"] = {
		["type"] = "DropDown",
		["title"] = L["Direction"],
		["tooltip"] = L["Sets the growing direction of the diminishing return tracker."],
		["width"] = 125,
		["infoTable"] = {
			[1] = {
				["value"] = "UP",
				["text"] = L["Up"],
			},
			[2] = {
				["value"] = "RIGHT",
				["text"] = L["Right"],
			},
			[3] = {
				["value"] = "DOWN",
				["text"] = L["Down"],
			},
			[4] = {
				["value"] = "LEFT",
				["text"] = L["Left"],
			},
		},
		["GetDBValue"] = function (frame) local database = ArenaLive:GetDBComponent(frame.addon, frame.handler, frame.group); return database.GrowDirection; end,
		["SetDBValue"] = function (frame, newValue) local database = ArenaLive:GetDBComponent(frame.addon, frame.handler, frame.group); database.GrowDirection = newValue; end,
		["postUpdate"] = function (frame, newValue, oldValue) for id, unitFrame in ArenaLive:GetAllUnitFrames() do if ( unitFrame.addon == frame.addon and unitFrame.group == frame.group and unitFrame[frame.handler] ) then DRTracker:UpdateIconPositions(unitFrame[frame.handler]); end end end,
	},
	["ShownIcons"] = {
		["type"] = "Slider",
		["title"] = L["Shown Icons"],
		["tooltip"] = L["Sets the maximal number of icons that are shown simultaneously."],
		["width"] = 100,
		["height"] = 17,		
		["min"] = 1,
		["max"] = NUMBER_DIMINISHING_RETURNS,
		["step"] = 1,
		["inputType"] = "NUMERIC",
		["GetDBValue"] = function (frame) local database = ArenaLive:GetDBComponent(frame.addon, frame.handler, frame.group); return database.MaxShownIcons; end,
		["SetDBValue"] = function (frame, newValue) local database = ArenaLive:GetDBComponent(frame.addon, frame.handler, frame.group); database.MaxShownIcons = newValue; end,
		["postUpdate"] = function (frame, newValue, oldValue) for id, unitFrame in ArenaLive:GetAllUnitFrames() do if ( unitFrame.addon == frame.addon and unitFrame.group == frame.group and unitFrame[frame.handler] ) then DRTracker:Update(unitFrame); end end end,
	},
};