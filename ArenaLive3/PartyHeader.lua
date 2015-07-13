--[[ ArenaLive Core Functions: Party Header
Created by: Vadrak
Creation Date: 03.08.2014
Last Update: 10.09.2014
This file is used to construct and manage party frames.
]]--

-- ArenaLive addon Name and localisation table:
local addonName, L = ...;

--[[
**************************************************
******* GENERAL HANDLER SET UP STARTS HERE *******
**************************************************
]]--
local PartyHeader = ArenaLive:ConstructHandler("PartyHeader", true, true);
local headers = {};
local UnitRangeCache = {};
local NUM_MAX_PARTY_MEMBERS = 4;

-- Set up a table for frames that need an update after CombatLockDown fades:
local headersToUpdate = {};

-- Register events:
PartyHeader:RegisterEvent("PLAYER_REGEN_ENABLED");
PartyHeader:RegisterEvent("GROUP_ROSTER_UPDATE");
PartyHeader:RegisterEvent("PLAYER_ENTERING_WORLD");

--Create a base class for this handler. All objects of the type UnitFrame will inherit functions from this one:
local PartyHeaderClass = {};

--[[ Function: directionToPoints
	 Returns anchor information for a arena header's unit frames.
		header (frame): The affected arena header.
		RETURNS:
			point, relativePoint, xOffset, yOffset for the arena header's unit frames.
]]--
local function directionToPoints(header)
	local direction = header:GetAttribute("direction") or "DOWN";
	local space = header:GetAttribute("space") or 0;

	if ( direction == "UP" ) then
		return "BOTTOM", "TOP", 0, space;
	elseif ( direction == "RIGHT" ) then
		return "LEFT", "RIGHT", space, 0;
	elseif ( direction == "DOWN" ) then
		return "TOP", "BOTTOM", 0, -space;
	elseif ( direction == "LEFT" ) then
		return "RIGHT", "LEFT", -space, 0;
	end
end

local onAttributeChangedSnippet = [[
	
 if ( name ~= "al_framelock" and name ~= "state-partymembers" and name ~= "showplayer" and name ~= "state-ingroup" and name ~= "showparty" and name ~= "showraid" and name ~= "inarena" and name ~= "showarena" ) then
  return;
 end
 
 local frame, frameName;
 if ( not self:GetAttribute("al_framelock") ) then
  self:Show();
   
  frame = self:GetFrameRef("PlayerFrame");
  if ( self:GetAttribute("showplayer") ) then
   frame:Show();
  else
   frame:Hide();
  end
  
  for i = 1, 4 do
   frameName = "Frame"..i;
   frame = self:GetFrameRef(frameName);
   frame:Show();
  end
 elseif ( (self:GetAttribute("state-ingroup") == "party" and self:GetAttribute("showparty") ) or ( self:GetAttribute("state-ingroup") == "raid" and self:GetAttribute("showraid") ) or ( self:GetAttribute("inarena") and self:GetAttribute("showarena") ) ) then
  self:Show();
  
  frame = self:GetFrameRef("PlayerFrame");
  if ( self:GetAttribute("showplayer") ) then
   frame:Show();
  else
   frame:Hide();
  end
  
  for i = 1, 4 do
   frameName = "Frame"..i;
   frame = self:GetFrameRef(frameName);
   local numMembers = self:GetAttribute("state-partymembers");
   if ( i <= tonumber(numMembers) ) then
    frame:Show();
   else
    frame:Hide();
   end
  end
 else
  self:Hide();
  frame = self:GetFrameRef("PlayerFrame");
  frame:Hide();
  
  for i = 1, 4 do
   frameName = "Frame"..i;
   frame = self:GetFrameRef(frameName);
   frame:Hide();
  end
 end
]]

local existingUnitsSnippet = [[ [target=party4, exists] 4; [target=party3, exists] 3; [target=party2, exists] 2; [target=party1, exists] 1; 0  ]];
local groupTypeSnippet = [[ [group:raid] raid; [group:party] party; nil ]];

PartyHeader.optionSets = {
	["Enable"] = {
		["type"] = "CheckButton",
		["title"] = L["Enable"],
		["tooltip"] = L["Enables Party Frames."],
		["GetDBValue"] = function (frame) local database = ArenaLive:GetDBComponent(frame.addon, frame.handler, frame.group); return database.Enabled; end,
		["SetDBValue"] = function (frame, newValue) local database = ArenaLive:GetDBComponent(frame.addon, frame.handler, frame.group); database.Enabled = newValue; end,
		["postUpdate"] = function (frame, newValue, oldValue)
			for header in pairs(headers) do
				if ( header.addon == frame.addon and header.group == frame.group ) then
					if ( newValue ) then
						header:Enable();
					else
						header:Disable();
					end
				end
			end
		end,
	},
	["ShowPlayer"] = {
		["type"] = "CheckButton",
		["title"] = L["Show Player"],
		["tooltip"] = L["Shows a frame for the player in the party frame header."],
		["GetDBValue"] = function (frame) local database = ArenaLive:GetDBComponent(frame.addon, frame.handler, frame.group); return database.ShowPlayer; end,
		["SetDBValue"] = function (frame, newValue) local database = ArenaLive:GetDBComponent(frame.addon, frame.handler, frame.group); database.ShowPlayer = newValue; end,
		["postUpdate"] = function (frame, newValue, oldValue)
			for header in pairs(headers) do
				if ( header.addon == frame.addon and header.group == frame.group ) then
						header:SetAttribute("showplayer", newValue);
						PartyHeader:UpdateAnchors(header);
				end
			end
		end,
	},
	["ShowParty"] = {
		["type"] = "CheckButton",
		["title"] = L["Show in Party"],
		["tooltip"] = L["Sets whether the party frames are shown while in a party or not."],
		["GetDBValue"] = function (frame) local database = ArenaLive:GetDBComponent(frame.addon, frame.handler, frame.group); return database.ShowParty; end,
		["SetDBValue"] = function (frame, newValue) local database = ArenaLive:GetDBComponent(frame.addon, frame.handler, frame.group); database.ShowParty = newValue; end,
		["postUpdate"] = function (frame, newValue, oldValue)
			for header in pairs(headers) do
				if ( header.addon == frame.addon and header.group == frame.group ) then
						header:SetAttribute("showparty", newValue);
				end
			end
		end,
	},
	["ShowRaid"] = {
		["type"] = "CheckButton",
		["title"] = L["Show in Raid"],
		["tooltip"] = L["Sets whether the party frames are shown while in a raid group or not."],
		["GetDBValue"] = function (frame) local database = ArenaLive:GetDBComponent(frame.addon, frame.handler, frame.group); return database.ShowRaid; end,
		["SetDBValue"] = function (frame, newValue) local database = ArenaLive:GetDBComponent(frame.addon, frame.handler, frame.group); database.ShowRaid = newValue; end,
		["postUpdate"] = function (frame, newValue, oldValue)
			for header in pairs(headers) do
				if ( header.addon == frame.addon and header.group == frame.group ) then
						header:SetAttribute("showraid", newValue);
				end
			end
		end,
	},
	["ShowArena"] = {
		["type"] = "CheckButton",
		["title"] = L["Show in Arena"],
		["tooltip"] = L["Sets whether the party frames are shown while in arena or not."],
		["GetDBValue"] = function (frame) local database = ArenaLive:GetDBComponent(frame.addon, frame.handler, frame.group); return database.ShowArena; end,
		["SetDBValue"] = function (frame, newValue) local database = ArenaLive:GetDBComponent(frame.addon, frame.handler, frame.group); database.ShowArena = newValue; end,
		["postUpdate"] = function (frame, newValue, oldValue)
			for header in pairs(headers) do
				if ( header.addon == frame.addon and header.group == frame.group ) then
						header:SetAttribute("showarena", newValue);
				end
			end
		end,
	},
	["SpaceBetweenFrames"] = {
		["type"] = "Slider",
		["title"] = L["Space Between Frames"],
		["tooltip"] = L["Sets the space between the arena frames."],
		["width"] = 150,
		["height"] = 17,		
		["min"] = 0,
		["max"] = 100,
		["step"] = 1,
		["inputType"] = "NUMERIC",
		["GetDBValue"] = function (frame) local database = ArenaLive:GetDBComponent(frame.addon, frame.handler, frame.group); return database.SpaceBetweenFrames; end,
		["SetDBValue"] = function (frame, newValue) local database = ArenaLive:GetDBComponent(frame.addon, frame.handler, frame.group); database.SpaceBetweenFrames = newValue; end,
		["postUpdate"] = function (frame, newValue, oldValue)
			for header in pairs(headers) do
				if ( header.addon == frame.addon and header.group == frame.group ) then
					header:SetAttribute("space", newValue);
				end
			end
		end,
	},
	["GrowthDirection"] = {
		["type"] = "DropDown",
		["title"] = L["Growth Direction"],
		["tooltip"] = L["Sets the direction to which the party frames will grow."],
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
		["GetDBValue"] = function (frame) local database = ArenaLive:GetDBComponent(frame.addon, frame.handler, frame.group); return database.GrowthDirection; end,
		["SetDBValue"] = function (frame, newValue) local database = ArenaLive:GetDBComponent(frame.addon, frame.handler, frame.group); database.GrowthDirection = newValue; end,
		["postUpdate"] = function (frame, newValue, oldValue)
			for header in pairs(headers) do
				if ( header.addon == frame.addon and header.group == frame.group ) then
					header:SetAttribute("direction", newValue);
				end
			end
		end,
	},
};



--[[
****************************************
****** HANDLER METHODS START HERE ******
****************************************
]]--
function PartyHeader:ConstructObject(header, template, initFunc, addonName, frameGroup)

	-- Set control values:
	header.addon = addonName;
	header.group = frameGroup;
	header.template = template;
	header.initFunc = initFunc;
	
	local database = ArenaLive:GetDBComponent(addonName, self.name, frameGroup);
	
	-- Set initial values for attributes:
	header:SetAttribute("showparty", database.ShowParty);
	header:SetAttribute("showraid", database.ShowRaid);
	header:SetAttribute("showarena", database.ShowArena);
	header:SetAttribute("showplayer", database.ShowPlayer);
	header:SetAttribute("direction", database.GrowthDirection);
	header:SetAttribute("space", database.SpaceBetweenFrames);
	
	-- Copy header class methods:
	ArenaLive:CopyClassMethods(PartyHeaderClass, header);
	
	-- Create unit frames:
	local headerName = header:GetName();
	local frame;
	for i = 1, NUM_MAX_PARTY_MEMBERS do
		if ( i == 1 ) then
			frame = CreateFrame("Button", headerName.."PlayerFrame", header, template);
			header["PlayerFrame"] = frame;
			ArenaLive:ConstructHandlerObject(frame, "UnitFrame", addonName, frameGroup, "target", "menu", nil, nil, true);
			header.initFunc(frame);
			header:SetFrameRef("PlayerFrame", frame);
		end
		
		frame = CreateFrame("Button", headerName.."Frame"..i, header, template);
		header["Frame"..i] = frame;
		frame:SetID(i);
		ArenaLive:ConstructHandlerObject(frame, "UnitFrame", addonName, frameGroup, "target", "menu", nil, nil, true);
		header.initFunc(frame);
		header:SetFrameRef("Frame"..i, frame);
	end
	
	-- Add to headers table:
	headers[header] = true;
	
	-- Toggle header:
	header:Toggle();
end

function PartyHeader:UpdateAll()
	for header in pairs(headers) do
		if ( header.enabled ) then
			header:Update();
		end
	end
end

function PartyHeader:UpdateAllRange()
	for header in pairs(headers) do
		if ( header.enabled ) then
			header:UpdateRange();
		end
	end
end

function PartyHeader:UpdateAnchors(header)
	if ( not InCombatLockdown() ) then
		local direction = header:GetAttribute("direction") or "DOWN";
		local space = header:GetAttribute("space") or 0;
		
		local point, relativePoint, xOffset, yOffset = directionToPoints(header);
		local relativeTo, firstRelativePoint, width, height;
		local frame;
		for i = 1, NUM_MAX_PARTY_MEMBERS do			
			if ( i == 1 ) then
				local firstX, firstY;
				if ( direction == "UP" ) then
					firstX, firstY = 0, 5;
				elseif ( direction == "RIGHT" ) then
					firstX, firstY = 5, 0;
				elseif ( direction == "DOWN" ) then
					firstX, firstY = 0, -5;
				elseif ( direction == "LEFT" ) then
					firstX, firstY = -5, 0;
				end
				
				if ( header:GetAttribute("showplayer") ) then
					frame = header["PlayerFrame"];
					frame:ClearAllPoints();
					frame:SetPoint(point, header, point, firstX, firstY);
					relativeTo = frame;
					firstX, firstY = xOffset, yOffset;
					firstRelativePoint = relativePoint;
				else
					relativeTo = header;
					firstRelativePoint = point;
				end
				
				frame = header["Frame"..i];
				frame:ClearAllPoints();
				width, height = frame:GetSize();
				frame:SetPoint(point, relativeTo, firstRelativePoint, firstX, firstY);
			else
				frame = header["Frame"..i];
				frame:ClearAllPoints();
				relativeTo = header["Frame"..i-1];
				frame:SetPoint(point, relativeTo, relativePoint, xOffset, yOffset);
			end
		end
		
		local numFrames = NUM_MAX_PARTY_MEMBERS;
		if ( header:GetAttribute("showplayer") ) then
			numFrames = numFrames + 1;
		end
		if ( direction == "DOWN" or direction == "UP" ) then
			width = width + 10;
			height = height * numFrames + space * (numFrames - 1) + 10;
		else
			width = width * numFrames + space * (numFrames - 1) + 10;
			height = height + 10;
		end
		
		header:SetSize(width, height);
		header.updateAnchors = nil;
	else
		header.updateAnchors = true;
		headersToUpdate[header] = true;
	end
end

function PartyHeader:UpdateInArena(header)
	if ( not InCombatLockdown() ) then
		
		local _, instanceType = IsInInstance();
		if ( instanceType == "arena" ) then
			header:SetAttribute("inarena", true);
		else
			header:SetAttribute("inarena", nil);
		end
		
		header.updateInArena = nil;
		
	else
		header.updateInArena = true;
		headersToUpdate[header] = true;
	end
end

function PartyHeader:OnEvent(event, ...)
	local filter = ...;
	if ( event == "PLAYER_REGEN_ENABLED" ) then
		for header in pairs(headersToUpdate) do
			if ( header.updateInArena ) then
			end
			
			if ( header.updateAnchors ) then
				PartyHeader:UpdateAnchors(header);
			end
		end
	elseif ( event == "GROUP_ROSTER_UPDATE" ) then
		for header in pairs(headers) do
			if ( header.enabled ) then
				header:UpdateGUIDs();
				header:Update();
			end
		end
	elseif ( event == "PLAYER_ENTERING_WORLD" ) then
		for header in pairs(headers) do
			if ( header.enabled ) then
				PartyHeader:UpdateInArena(header);
			end
		end		
	end
end
local THROTTLE, ELAPSED = 0.1, 0;
function PartyHeader:OnUpdate(elapsed)
	ELAPSED = ELAPSED + elapsed;
	if ( ELAPSED >= THROTTLE ) then
		ELAPSED = 0;
		for i = 1, 4 do
			local unit = "party"..i;
			local inRange = ( not UnitExists(unit) or ( UnitInRange(unit) ) );
			if ( UnitRangeCache[unit] ~= inRange ) then
				UnitRangeCache[unit] = inRange;
				self:UpdateAllRange();
			end
		end
	end
end
PartyHeader:SetScript("OnUpdate", PartyHeader.OnUpdate);
--[[
****************************************
****** CLASS METHODS START HERE ******
****************************************
]]--
function PartyHeaderClass:Enable()
	local database = ArenaLive:GetDBComponent(self.addon, "FrameMover");
	self:SetScript("OnAttributeChanged", self.OnAttributeChanged);
	self:WrapScript(self, "OnAttributeChanged", onAttributeChangedSnippet);
	RegisterStateDriver(self, "partymembers", existingUnitsSnippet);
	RegisterStateDriver(self, "ingroup", groupTypeSnippet);
	
	-- Enable frames:
	local frame;
	for i = 1, NUM_MAX_PARTY_MEMBERS do
		if ( i == 1 ) then
			frame = self["PlayerFrame"];
			if ( self:GetAttribute("showplayer") ) then
				frame:Enable();
				frame:UpdateUnit("player");
			else
				frame:Disable();
			end
		end
		frame = self["Frame"..i];
		frame:Enable();
		frame:UpdateUnit("party"..i);
	end
	
	PartyHeader:UpdateAnchors(self);
	PartyHeader:UpdateInArena(self);
	self:SetAttribute("al_framelock", database.FrameLock);
	self.enabled = true;
	
	if ( type(self.OnEnable) == "function" ) then
		self:OnEnable();
	end
end

function PartyHeaderClass:Disable()
	self:SetScript("OnAttributeChanged", nil);
	self:UnwrapScript(self, "OnAttributeChanged");
	UnregisterStateDriver(self, "partymembers");
	UnregisterStateDriver(self, "ingroup");
	
	-- Disable frames:
	local frame;
	for i = 1, NUM_MAX_PARTY_MEMBERS do
		if ( i == 1 ) then
			frame = self["PlayerFrame"];
			frame:Disable();
		end
		frame = self["Frame"..i];
		frame:Disable();
	end
	
	self.enabled = false;
	self:Hide();
	
	if ( type(self.OnDisable) == "function" ) then
		self:OnDisable();
	end
end

function PartyHeaderClass:Toggle()
	local database = ArenaLive:GetDBComponent(self.addon, "PartyHeader", self.group);
	if ( database.Enabled ) then
		self:Enable();
	else
		self:Disable();
	end
end

function PartyHeaderClass:Update()
	local database = ArenaLive:GetDBComponent(self.addon, "PartyHeader", self.group);
	if ( database.Enabled ) then
		local frame;
		for i = 1, NUM_MAX_PARTY_MEMBERS do
			if ( i == 1 ) then
				frame = self["PlayerFrame"];
				frame:Update();
			end
			frame = self["Frame"..i];
			frame:Update();
		end
	end
end
function PartyHeaderClass:UpdateRange()
	for i = 1, NUM_MAX_PARTY_MEMBERS do
		local frame = self["Frame"..i];
		local unit = "party"..i;
		
		if ( UnitRangeCache[unit] ) then
			frame:SetAlpha(1);
		else
			frame:SetAlpha(0.75);
		end
	end
end
function PartyHeaderClass:Reset()
	local frame;
	for i = 1, NUM_MAX_PARTY_MEMBERS do
		if ( i == 1 ) then
			frame = self["PlayerFrame"];
			frame:Reset();
		end
		frame = self["Frame"..i];
		frame:Reset();
	end
end

function PartyHeaderClass:TestMode(mode)
	local database = ArenaLive:GetDBComponent(self.addon, "PartyHeader", self.group);
	if ( database.Enabled ) then
		local frame;
		for i = 1, NUM_MAX_PARTY_MEMBERS do
			if ( i == 1 ) then
				frame = self["PlayerFrame"];
				frame:TestMode(mode);
			end
			frame = self["Frame"..i];
			frame:TestMode(mode);
		end
	end
end

function PartyHeaderClass:UpdateGUIDs()
	local frame, guid;
	for i = 1, NUM_MAX_PARTY_MEMBERS do
		frame = self["Frame"..i];
		guid = UnitGUID("party"..i);
		if ( guid ~= frame.guid ) then
			frame:UpdateGUID();
		end
	end
end

function PartyHeaderClass:OnAttributeChanged(name, value)
	for i=1,4 do
		local tempFrame = _G["PartyMemberFrame"..i];
		if ( tempFrame and tempFrame:IsShown() ) then
			tempFrame:Hide();
		end
	end
	if ( name == "al_framelock" ) then
		if ( value ) then
			self:EnableMouse(false);
			if ( self.background ) then
				self.background:Hide();
			end
		else
			self:EnableMouse(true);
			if ( self.background ) then
				self.background:Show();
			end
		end
	elseif ( name == "direction" or name == "space" ) then
		PartyHeader:UpdateAnchors(self);
	elseif ( name == "showplayer" ) then
		local frame = self.PlayerFrame;
		if ( value ) then
			frame:Enable();
			frame:UpdateUnit("player");
		else
			frame:Disable();
		end	
	end
end

