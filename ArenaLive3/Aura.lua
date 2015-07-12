--[[ ArenaLive Core Functions: Aura Handler
Created by: Vadrak
Creation Date: 27.04.2014
Last Update: 06.06.2014
This file contains all relevant functions for buff and debuff display.
]]--

-- ArenaLive addon Name and localisation table:
local addonName, L = ...;

--[[
**************************************************
******* GENERAL HANDLER SET UP STARTS HERE *******
**************************************************
]]--
-- Create new Handler and register for all important events:
local Aura = ArenaLive:ConstructHandler("Aura", true, false, false);
Aura:RegisterEvent("UNIT_AURA");

-- Let unit frames know that this handler can be enabled/disabled:
Aura.canToggle = true;

-- Set two default variables for the maximal amount auras:
local NUM_MAX_AURAS = 40;

-- Set up a table containing all units that are controled by the player to seperate normal from large icons.
local PLAYER_UNITS = {
	player = true,
	vehicle = true,
	pet = true,
};

-- Defaults for x and y offset.
local AURA_X_OFFSET = 3;
local AURA_Y_OFFSET = 3;



--[[
****************************************
****** HANDLER METHODS START HERE ******
****************************************
]]--
--[[ Method: ConstructObject
	 Creates a new aura frame.
		auraFrame (Frame): The frame that is going to be set up as an aura frame.
		buffFrame (Frame): Frame that will hold the buff icons of the aura frame.
		debuffFrame (Frame): Frame that will hold the debuff icons of the aura frame.
]]--
function Aura:ConstructObject(auraFrame, buffFrame, debuffFrame)
	-- Set basic info:
	auraFrame.buffFrame = buffFrame;
	auraFrame.debuffFrame = debuffFrame;
	
	buffFrame.numIcons = 0;
	debuffFrame.numIcons = 0;
end

function Aura:OnEnable (unitFrame)
	local auraFrame = unitFrame[self.name];
	auraFrame:Show();
	Aura:Update(unitFrame);
end

function Aura:OnDisable (unitFrame)
	local auraFrame = unitFrame[self.name];
	Aura:Reset(unitFrame);
	auraFrame:Hide();
end

local largeAuraList = {};
local colour = {};
function Aura:Update(unitFrame)

	local unit = unitFrame.unit;
	local auraFrame = unitFrame[self.name];
	if ( not unit or not auraFrame.enabled ) then
		return;
	end
	
	local totalNumAuras = 0;
	
	-- Update Buffs:
	auraFrame, numAuras = Aura:UpdateAuras(unitFrame, "BUFF");
	local buffWidth, buffHeight = Aura:UpdateDisplay(unitFrame, auraFrame, numAuras);
	totalNumAuras = totalNumAuras + numAuras;
	
	-- Update Debuffs:
	auraFrame, numAuras = Aura:UpdateAuras(unitFrame, "DEBUFF");
	local debuffWidth, debuffHeight = Aura:UpdateDisplay(unitFrame, auraFrame, numAuras);
	totalNumAuras = totalNumAuras + numAuras;
	
	
	-- Now get actual aura frame:
	auraFrame = unitFrame[self.name];
	
	-- Switch Buff/Debuff Anchors for enemy units, if we are not in a Spectator environment:
	local database = ArenaLive:GetDBComponent(unitFrame.addon, self.name, unitFrame.group);
	local growUpwards = unitFrame.GrowUpwards;
	local point, relativeTo, relativePoint;
	
	if ( growUpwards ) then
		point = "BOTTOMLEFT";
		relativePoint = "TOPLEFT"
		yOffset = AURA_Y_OFFSET;
	else
		point = "TOPLEFT";
		relativePoint = "BOTTOMLEFT";
		yOffset = -AURA_Y_OFFSET;
	end
	
	auraFrame.buffFrame:ClearAllPoints();
	auraFrame.debuffFrame:ClearAllPoints();
	if ( UnitIsFriend("player", unit) or database.SpectatorFilter ) then	
		auraFrame.buffFrame:SetPoint(point, auraFrame, point, 0, 0);
		auraFrame.debuffFrame:SetPoint(point, auraFrame.buffFrame, relativePoint, 0, yOffset);
	else
		auraFrame.debuffFrame:SetPoint(point, auraFrame, point, 0, 0);
		auraFrame.buffFrame:SetPoint(point, auraFrame.debuffFrame, relativePoint, 0, yOffset);	
	end
	
	-- Update aura frame's width and height according to new buffs and debuffs:
	local width, height;
	if ( buffWidth > debuffWidth ) then
		width = buffWidth;
	else
		width = debuffWidth;
	end
	
	height = buffHeight + debuffHeight + AURA_Y_OFFSET;
	
	-- Adjust height to 1, if no auras are shown:
	if ( totalNumAuras < 1 ) then
		height = 1;
	end
	
	auraFrame:SetSize(width, height);
	
end

function Aura:UpdateAuras(unitFrame, auraType)
	local unit = unitFrame.unit;
	local database = ArenaLive:GetDBComponent(unitFrame.addon, self.name, unitFrame.group);
	
	local isPlayer = UnitIsUnit("player", unit);
	local canAssist = UnitCanAssist("player", unit);
	local name, rank, texture, count, dispelType, duration, expires, caster, isStealable, _, spellID;
	
	-- Get data according to aura type:
	local auraFrame, filter, maxShown;
	if( auraType == "BUFF" ) then
		auraFrame = unitFrame[self.name].buffFrame;
		filter = ( database.OnlyShowRaidBuffs and canAssist );
		maxShown = database.MaxShownBuffs;
	else
		auraFrame = unitFrame[self.name].debuffFrame;
		filter = ( database.OnlyShowDispellableDebuffs and canAssist );
		maxShown = database.MaxShownDebuffs;
	end
	
	local iconID = 1;
	local numAuras = 0;
	local auraID = 1;
		
	-- Set filter:
	if ( filter ) then
		filter = "RAID";
	end
		
	while auraID <= NUM_MAX_AURAS do
		
		-- Retrieve buff info:
		if ( auraType == "BUFF" ) then
			name, rank, texture, count, dispelType, duration, expires, caster, isStealable, _, spellID = UnitBuff(unit, auraID, filter);
		elseif ( auraType == "DEBUFF" ) then
			name, rank, texture, count, dispelType, duration, expires, caster, isStealable, _, spellID = UnitDebuff(unit, auraID, filter);
			
		end
		
		local icon = auraFrame["icon"..iconID];
		
		if ( texture and iconID <= maxShown ) then
			-- Check if the aura is filtered or not:
			if ( ( auraType == "BUFF" and Aura:ShouldShowBuff(unitFrame, auraID, filter) ) or ( auraType == "DEBUFF" and Aura:ShouldShowDebuff(unitFrame, auraID, filter) ) ) then
				
				-- If the chosen icon doesn't exist, we create a new one at this point:
				if ( not icon ) then
					icon = Aura:CreateIcon(auraFrame, auraType, iconID, unitFrame.addon);
				end
					
				-- Set tooltip relevant info:
				icon.unit = unit;
				icon:SetID(auraID);
				icon.filter = filter;
					
				-- Set Texture:
				icon.texture:SetTexture(texture);
					
				-- Set aura count:
				if ( count > 1 ) then
					icon.count:SetText(count);
					icon.count:Show();
				else
					icon.count:Hide();
				end
					
				-- Set the cooldown duration:
				if ( duration > 0 ) then
					local startTime = expires - duration;
					icon.cooldown:Set(startTime, duration);
				else
					icon.cooldown:Reset();
				end
					
				-- Show/Hide the stealable texture for Buffs:
				if ( icon.stealable ) then
					if ( not isPlayer and isStealable ) then
						icon.stealable:Show();
					else
						icon.stealable:Hide();
					end
				end
				
				-- Colour border for Debuffs:
				if ( icon.border ) then
					if ( dispelType ) then
						colour = DebuffTypeColor[dispelType];
					else
						colour = DebuffTypeColor["none"];
					end
					icon.border:SetVertexColor(colour.r, colour.g, colour.b);
				end			
				
				-- If the aura is cast by a player controlled unit, add the aura to the large icon list:
				largeAuraList[auraID] = PLAYER_UNITS[caster];
				
				icon:Show();
				
				iconID = iconID + 1;
				numAuras = numAuras + 1;
			end
		else
			-- Hide all unnecessary frames and break the loop, if there are no frames left:
			if ( icon ) then
				icon:Hide();
				iconID = iconID + 1;
			else
				break;
			end
		end
			
		auraID = auraID + 1;
	end
	
	return auraFrame, numAuras;
end

function Aura:UpdateDisplay(unitFrame, auraFrame, numAuras)
	
	local database = ArenaLive:GetDBComponent(unitFrame.addon, self.name, unitFrame.group);
	local aurasPerRow = database.AurasPerRow;
	local normalSize = database.NormalIconSize;
	local largeSize = database.LargeIconSize;
	local clickThrough = database.ClickThrough;
	local size;
	
	local largestIconSize = 0;
	local auraFrameHeight = 1;
	-- Width needs to be static in order for grow RTL to work correctly.
	local auraFrameWidth = ( largeSize + AURA_X_OFFSET ) * aurasPerRow - AURA_X_OFFSET;
	
	for i = 1, numAuras do
		local icon = auraFrame["icon"..i];
		
		-- Get icon size:
		if ( largeAuraList[i] ) then
			size = largeSize;
		else
			size = normalSize;
		end
		
		-- Set Size:
		icon:SetSize(size, size);
		if ( icon.border ) then
			icon.border:SetSize(size+1, size+1);
		elseif ( icon.stealable ) then
			icon.stealable:SetSize(size+3, size+3);
		end
		
		-- Set clickthrough state:
		if ( clickThrough ) then
			icon:EnableMouse(nil);
		else
			icon:EnableMouse(true);
		end
		
		-- Update icon's position:
		Aura:UpdateIconPosition(unitFrame, auraFrame, i);
		
		-- Update auraFrameHeight:
		if ( i == 1 ) then
			-- - 1 to remove the initial value.
			auraFrameHeight = auraFrameHeight - 1;
			largestIconSize = size;
		elseif ( aurasPerRow == 1 ) then
			auraFrameHeight = auraFrameHeight + size + AURA_Y_OFFSET;
		elseif ( i % aurasPerRow == 1 ) then
			-- New Row, add largest icon's size of the last row to the total frame height and reset the largestIconSize variable:
			auraFrameHeight = auraFrameHeight + largestIconSize + AURA_Y_OFFSET;
			largestIconSize = size;
		else
			if ( largestIconSize < size ) then
				largestIconSize = size;
			end
		end
	end
	
	
	-- Add last row's height:
	auraFrameHeight = auraFrameHeight + largestIconSize;

	-- Set new size for auraFrame:
	auraFrame:SetSize(auraFrameWidth, auraFrameHeight);
	
	return auraFrameWidth, auraFrameHeight;
end

function Aura:Reset(unitFrame)
	
	-- Reset Buffs:
	local auraFrame = unitFrame[self.name].buffFrame;
	for i = 1, auraFrame.numIcons do
		local icon = auraFrame["icon"..i];
		
		icon:Hide();
		icon.texture:SetTexture();
		icon.cooldown:Reset();
		icon.filter = nil;
		icon.unit = nil;
	end

	-- Reset Debuffs:
	auraFrame = unitFrame[self.name].debuffFrame;
	for i = 1, auraFrame.numIcons do
		local icon = auraFrame["icon"..i];
		
		icon:Hide();
		icon.texture:SetTexture();
		icon.cooldown:Reset();
		icon.filter = nil;
		icon.unit = nil;
	end	
	
	local database = ArenaLive:GetDBComponent(unitFrame.addon, self.name, unitFrame.group);
	local largeSize = database.LargeIconSize;
	auraFrame = unitFrame[self.name];
	auraFrame:SetSize(1, 1);
end

function Aura:ShouldShowBuff (unitFrame, auraIndex, filter)
	local unit = unitFrame.unit;
	local database = ArenaLive:GetDBComponent(unitFrame.addon, self.name, unitFrame.group);
	local _, _, _, _, _, _, _, caster, isStealable, _, spellID = UnitBuff(unit, auraIndex, filter);
	
	if ( database.OnlyShowPlayerBuffs and not canAttack and caster ~= "player" ) then
		return false;
	end
	
	if ( database.SpectatorFilter and not ArenaLive.spellDB["ShownBuffs"][spellID] ) then
		return false;
	end
	
	if ( database.OnlyShowDispellableBuffs ) then
		local canAttack = UnitCanAttack("player", unit);
		if ( not canAttack or ( canAttack and isStealable ) ) then
			return true;
		else
			return false;
		end
	end
	
	-- None of the above applied, show buff:
	return true;
end

function Aura:ShouldShowDebuff (unitFrame, auraIndex, filter)
	local unit = unitFrame.unit;
	local database = ArenaLive:GetDBComponent(unitFrame.addon, self.name, unitFrame.group);
	if ( not database.ShowOnlyPlayerDebuffs or not UnitCanAttack("player", unit) ) then
		return true;
	else
		local _, _, _, _, _, _, _, unitCaster, _, _, spellID, _, _, isCastByPlayer = UnitDebuff(unit, auraIndex, filter);
		
		if SpellIsAlwaysShown(spellID) then
			return true;
		end
			
		local hasCustom, alwaysShowMine, showForMySpec = SpellGetVisibilityInfo(spellID, "ENEMY_TARGET");
		
		if ( hasCustom ) then
			return showForMySpec or (alwaysShowMine and (unitCaster == "player" or unitCaster == "pet" or unitCaster == "vehicle") );
		else
			return not isCastByPlayer or unitCaster == "player" or unitCaster == "pet" or unitCaster == "vehicle";
		end
	end

end

function Aura:CreateIcon(auraFrame, auraType, index, addonName)

	local icon;
	if ( auraType == "BUFF" ) then
		icon = CreateFrame("Button", nil, auraFrame, "ArenaLive_BuffTemplate");
	elseif ( auraType == "DEBUFF" ) then
		icon = CreateFrame("Button", nil, auraFrame, "ArenaLive_DebuffTemplate");
	end

	-- NOTE: References for icon's children are set in Aura.xml via parentKey="";
	auraFrame["icon"..index] = icon;

	-- Construct Cooldown:
	ArenaLive:ConstructHandlerObject(icon.cooldown, "Cooldown", addonName, icon);
	
	auraFrame.numIcons = auraFrame.numIcons + 1;
	return icon;
end

function Aura:UpdateIconPosition(unitFrame, auraFrame, index)
	
	local icon = auraFrame["icon"..index];
	
	if ( not icon ) then
		return;
	end
	
	local database = ArenaLive:GetDBComponent(unitFrame.addon, self.name, unitFrame.group);
	local aurasPerRow = database.AurasPerRow;
	local rtlAuras = database.GrowRTL;
	local growUpwards = database.GrowUpwards;
	
	local point, relativeTo, relativePoint, xOffset, yOffset, realtiveIndex, newRow;

	-- Set offset and relativeTo:
	if ( index == 1 ) then
		yOffset = 0;
		xOffset = 0;
		relativeTo = auraFrame;
	elseif ( aurasPerRow == 1 ) then
		yOffset = AURA_Y_OFFSET;
		xOffset = 0;
		realtiveIndex = index - 1;
		relativeTo = auraFrame["icon"..realtiveIndex];
		newRow = true;
	elseif ( index % aurasPerRow == 1 ) then
		-- First icon of a new row:
		realtiveIndex = index - aurasPerRow;
		yOffset = AURA_Y_OFFSET;
		xOffset = 0;
		relativeTo = auraFrame["icon"..realtiveIndex];
		newRow = true;
	else
		-- Existing row:
		yOffset = 0;
		xOffset = AURA_X_OFFSET;
		realtiveIndex = index - 1;
		relativeTo = auraFrame["icon"..realtiveIndex];
	end
		
	
	-- Set point and relative point according to the grow upwards setting:
	if ( growUpwards ) then
		point = "BOTTOM";
		if ( newRow ) then
			relativePoint = "TOP";
		else
			relativePoint = "BOTTOM";
		end
	else
		point = "TOP";
		if ( newRow ) then
			relativePoint = "BOTTOM";
		else
			relativePoint = "TOP";
		end
		yOffset = -yOffset;
	end
	
	-- Set point and relative point according to the rtl setting:
	if ( rtlAuras ) then
		point = point.."RIGHT";
		if ( newRow ) then
			relativePoint = relativePoint.."RIGHT";
		else
			relativePoint = relativePoint.."LEFT";
		end
		xOffset = -xOffset;
	else
		point = point.."LEFT";
		if ( newRow ) then
			relativePoint = relativePoint.."LEFT";
		else
			relativePoint = relativePoint.."RIGHT";
		end
	end
	
	if ( index == 1 ) then
		relativePoint = point;
	end
	
	-- Update position:
	icon:ClearAllPoints();
	icon:SetPoint(point, relativeTo, relativePoint, xOffset, yOffset);
end

function Aura:OnEvent(event, ...)
	
	if ( event == "UNIT_AURA" ) then
		local filter = ...;
		if ( ArenaLive:IsUnitInUnitFrameCache(filter) ) then
			for id in ArenaLive:GetAffectedUnitFramesByUnit(filter) do
				local frame = ArenaLive:GetUnitFrameByID(id);
				if ( frame[self.name] ) then
					self:Update(frame);
				end
			end
		end
	elseif ( event == "AURA_DISPLAY_UPDATE" ) then
		-- TODO: Use this after option changes:
		local addonName, groupType = ...;
	end
end

-- Option Settings:
Aura.optionSets = {
	["Enable"] = {
		["type"] = "CheckButton",
		["title"] = L["Enable"],
		["tooltip"] = L["Enables the display of Buffs and Debuffs."],
		["GetDBValue"] = function (frame) local database = ArenaLive:GetDBComponent(frame.addon, frame.handler, frame.group); return database.Enabled; end,
		["SetDBValue"] = function (frame, newValue) local database = ArenaLive:GetDBComponent(frame.addon, frame.handler, frame.group); database.Enabled = newValue; end,
		["postUpdate"] = function (frame, newValue, oldValue) for id, unitFrame in ArenaLive:GetAllUnitFrames() do if ( unitFrame.addon == frame.addon and unitFrame.group == frame.group and unitFrame[Aura.name] ) then unitFrame:ToggleHandler(Aura.name); end end end,
	},
	["ClickThrough"] = {
		["type"] = "CheckButton",
		["title"] = L["Click Through"],
		["tooltip"] = L["If checked, auras will not interact with the cursor."],
		["GetDBValue"] = function (frame) local database = ArenaLive:GetDBComponent(frame.addon, frame.handler, frame.group); return database.ClickThrough; end,
		["SetDBValue"] = function (frame, newValue) local database = ArenaLive:GetDBComponent(frame.addon, frame.handler, frame.group); database.ClickThrough = newValue; end,
		["postUpdate"] = function (frame, newValue, oldValue) for id, unitFrame in ArenaLive:GetAllUnitFrames() do if ( unitFrame.addon == frame.addon and unitFrame.group == frame.group and unitFrame[Aura.name] ) then Aura:Update(unitFrame); end end end,
	},
	["GrowUpwards"] = {
		["type"] = "CheckButton",
		["title"] = L["Grow Upwards"],
		["tooltip"] = L["If checked, aura rows will grow upwards, instead of downwards."],
		["GetDBValue"] = function (frame) local database = ArenaLive:GetDBComponent(frame.addon, frame.handler, frame.group); return database.GrowUpwards; end,
		["SetDBValue"] = function (frame, newValue) local database = ArenaLive:GetDBComponent(frame.addon, frame.handler, frame.group); database.GrowUpwards = newValue; end,
		["postUpdate"] = function (frame, newValue, oldValue) for id, unitFrame in ArenaLive:GetAllUnitFrames() do if ( unitFrame.addon == frame.addon and unitFrame.group == frame.group and unitFrame[Aura.name] ) then Aura:Update(unitFrame); end end end,
	},
	["GrowRTL"] = {
		["type"] = "CheckButton",
		["title"] = L["Grow from Right to Left"],
		["tooltip"] = L["If checked, auras will grow from right to left, instead of from left to right."],
		["GetDBValue"] = function (frame) local database = ArenaLive:GetDBComponent(frame.addon, frame.handler, frame.group); return database.GrowRTL; end,
		["SetDBValue"] = function (frame, newValue) local database = ArenaLive:GetDBComponent(frame.addon, frame.handler, frame.group); database.GrowRTL = newValue; end,
		["postUpdate"] = function (frame, newValue, oldValue) for id, unitFrame in ArenaLive:GetAllUnitFrames() do if ( unitFrame.addon == frame.addon and unitFrame.group == frame.group and unitFrame[Aura.name] ) then Aura:Update(unitFrame); end end end,
	},
	["OnlyShowRaidBuffs"] = {
		["type"] = "CheckButton",
		["title"] = L["Raid Buffs"],
		["tooltip"] = L["Show only raid buffs you can cast on friendly units."],
		["GetDBValue"] = function (frame) local database = ArenaLive:GetDBComponent(frame.addon, frame.handler, frame.group); return database.OnlyShowRaidBuffs; end,
		["SetDBValue"] = function (frame, newValue) local database = ArenaLive:GetDBComponent(frame.addon, frame.handler, frame.group); database.OnlyShowRaidBuffs = newValue; end,
		["postUpdate"] = function (frame, newValue, oldValue) for id, unitFrame in ArenaLive:GetAllUnitFrames() do if ( unitFrame.addon == frame.addon and unitFrame.group == frame.group and unitFrame[Aura.name] ) then Aura:Update(unitFrame); end end end,
	},
	["OnlyShowDispellableBuffs"] = {
		["type"] = "CheckButton",
		["title"] = L["Dispellable Buffs"],
		["tooltip"] = L["Show only buffs you can dispel or spell steal on hostile units."],
		["GetDBValue"] = function (frame) local database = ArenaLive:GetDBComponent(frame.addon, frame.handler, frame.group); return database.OnlyShowDispellableBuffs; end,
		["SetDBValue"] = function (frame, newValue) local database = ArenaLive:GetDBComponent(frame.addon, frame.handler, frame.group); database.OnlyShowDispellableBuffs = newValue; end,
		["postUpdate"] = function (frame, newValue, oldValue) for id, unitFrame in ArenaLive:GetAllUnitFrames() do if ( unitFrame.addon == frame.addon and unitFrame.group == frame.group and unitFrame[Aura.name] ) then Aura:Update(unitFrame); end end end,
	},
	["OnlyShowPlayerBuffs"] = {
		["type"] = "CheckButton",
		["title"] = L["Player's Buffs"],
		["tooltip"] = L["Show only your own buffs on friendly units."],
		["GetDBValue"] = function (frame) local database = ArenaLive:GetDBComponent(frame.addon, frame.handler, frame.group); return database.OnlyShowPlayerBuffs; end,
		["SetDBValue"] = function (frame, newValue) local database = ArenaLive:GetDBComponent(frame.addon, frame.handler, frame.group); database.OnlyShowPlayerBuffs = newValue; end,
		["postUpdate"] = function (frame, newValue, oldValue) for id, unitFrame in ArenaLive:GetAllUnitFrames() do if ( unitFrame.addon == frame.addon and unitFrame.group == frame.group and unitFrame[Aura.name] ) then Aura:Update(unitFrame); end end end,
	},
	["OnlyShowDispellableDebuffs"] = {
		["type"] = "CheckButton",
		["title"] = L["Dispellable Debuffs"],
		["tooltip"] = L["Show only debuffs you can dispel on friendly units."],
		["GetDBValue"] = function (frame) local database = ArenaLive:GetDBComponent(frame.addon, frame.handler, frame.group); return database.OnlyShowDispellableDebuffs; end,
		["SetDBValue"] = function (frame, newValue) local database = ArenaLive:GetDBComponent(frame.addon, frame.handler, frame.group); database.OnlyShowDispellableDebuffs = newValue; end,
		["postUpdate"] = function (frame, newValue, oldValue) for id, unitFrame in ArenaLive:GetAllUnitFrames() do if ( unitFrame.addon == frame.addon and unitFrame.group == frame.group and unitFrame[Aura.name] ) then Aura:Update(unitFrame); end end end,
	},
	["ShowOnlyPlayerDebuffs"] = {
		["type"] = "CheckButton",
		["title"] = L["Player's Debuffs"],
		["tooltip"] = L["Show only your own debuffs on enemy units."],
		["GetDBValue"] = function (frame) local database = ArenaLive:GetDBComponent(frame.addon, frame.handler, frame.group); return database.ShowOnlyPlayerDebuffs; end,
		["SetDBValue"] = function (frame, newValue) local database = ArenaLive:GetDBComponent(frame.addon, frame.handler, frame.group); database.ShowOnlyPlayerDebuffs = newValue; end,
		["postUpdate"] = function (frame, newValue, oldValue) for id, unitFrame in ArenaLive:GetAllUnitFrames() do if ( unitFrame.addon == frame.addon and unitFrame.group == frame.group and unitFrame[Aura.name] ) then Aura:Update(unitFrame); end end end,
	},
	["LargeIconSize"] = {
		["type"] = "Slider",
		["width"] = 100,
		["height"] = 17,
		["min"] = 1,
		["max"] = 64,
		["step"] = 1,
		["inputType"] = "NUMERIC",
		["title"] = L["Large Icon Size"],
		["tooltip"] = L["Defines the size of buffs and debuffs that are cast by the player."],
		["GetDBValue"] = function (frame) local database = ArenaLive:GetDBComponent(frame.addon, frame.handler, frame.group); return database.LargeIconSize; end,
		["SetDBValue"] = function (frame, newValue) local database = ArenaLive:GetDBComponent(frame.addon, frame.handler, frame.group); database.LargeIconSize = newValue; end,
		["postUpdate"] = function (frame, newValue, oldValue) for id, unitFrame in ArenaLive:GetAllUnitFrames() do if ( unitFrame.addon == frame.addon and unitFrame.group == frame.group and unitFrame[Aura.name] ) then Aura:Update(unitFrame); end end end,
	},
	["NormalIconSize"] = {
		["type"] = "Slider",
		["width"] = 100,
		["height"] = 17,
		["min"] = 1,
		["max"] = 64,
		["step"] = 1,
		["inputType"] = "NUMERIC",
		["title"] = L["Normal Icon Size"],
		["tooltip"] = L["Defines the size of buffs and debuffs that are not cast by the player."],
		["GetDBValue"] = function (frame) local database = ArenaLive:GetDBComponent(frame.addon, frame.handler, frame.group); return database.NormalIconSize; end,
		["SetDBValue"] = function (frame, newValue) local database = ArenaLive:GetDBComponent(frame.addon, frame.handler, frame.group); database.NormalIconSize = newValue; end,
		["postUpdate"] = function (frame, newValue, oldValue) for id, unitFrame in ArenaLive:GetAllUnitFrames() do if ( unitFrame.addon == frame.addon and unitFrame.group == frame.group and unitFrame[Aura.name] ) then Aura:Update(unitFrame); end end end,
	},
	["AurasPerRow"] = {
		["type"] = "Slider",
		["width"] = 100,
		["height"] = 17,
		["min"] = 1,
		["max"] = 40,
		["step"] = 1,
		["inputType"] = "NUMERIC",
		["title"] = L["Auras per Row"],
		["tooltip"] = L["Defines the maximal number of buffs and debuffs that will be shon in a row, before a new row is started."],
		["GetDBValue"] = function (frame) local database = ArenaLive:GetDBComponent(frame.addon, frame.handler, frame.group); return database.AurasPerRow; end,
		["SetDBValue"] = function (frame, newValue) local database = ArenaLive:GetDBComponent(frame.addon, frame.handler, frame.group); database.AurasPerRow = newValue; end,
		["postUpdate"] = function (frame, newValue, oldValue) for id, unitFrame in ArenaLive:GetAllUnitFrames() do if ( unitFrame.addon == frame.addon and unitFrame.group == frame.group and unitFrame[Aura.name] ) then Aura:Update(unitFrame); end end end,
	},
	["MaxBuffs"] = {
		["type"] = "Slider",
		["width"] = 150,
		["height"] = 17,
		["min"] = 0,
		["max"] = 40,
		["step"] = 1,
		["inputType"] = "NUMERIC",
		["title"] = L["Shown Buffs"],
		["tooltip"] = L["Defines the number of maximal buffs that are shown simultaneously."],
		["GetDBValue"] = function (frame) local database = ArenaLive:GetDBComponent(frame.addon, frame.handler, frame.group); return database.MaxShownBuffs; end,
		["SetDBValue"] = function (frame, newValue) local database = ArenaLive:GetDBComponent(frame.addon, frame.handler, frame.group); database.MaxShownBuffs = newValue; end,
		["postUpdate"] = function (frame, newValue, oldValue) for id, unitFrame in ArenaLive:GetAllUnitFrames() do if ( unitFrame.addon == frame.addon and unitFrame.group == frame.group and unitFrame[Aura.name] ) then Aura:Update(unitFrame); end end end,
	},
	["MaxDebuffs"] = {
		["type"] = "Slider",
		["width"] = 150,
		["height"] = 17,
		["min"] = 0,
		["max"] = 40,
		["step"] = 1,
		["inputType"] = "NUMERIC",
		["title"] = L["Shown Debuffs"],
		["tooltip"] = L["Defines the number of maximal debuffs that are shown simultaneously."],
		["GetDBValue"] = function (frame) local database = ArenaLive:GetDBComponent(frame.addon, frame.handler, frame.group); return database.MaxShownDebuffs; end,
		["SetDBValue"] = function (frame, newValue) local database = ArenaLive:GetDBComponent(frame.addon, frame.handler, frame.group); database.MaxShownDebuffs = newValue; end,
		["postUpdate"] = function (frame, newValue, oldValue) for id, unitFrame in ArenaLive:GetAllUnitFrames() do if ( unitFrame.addon == frame.addon and unitFrame.group == frame.group and unitFrame[Aura.name] ) then Aura:Update(unitFrame); end end end,
	},
};
