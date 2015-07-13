--[[ ArenaLive Core Functions: Arena Header
Created by: Vadrak
Creation Date: 16.07.2014
Last Update: 
This file is used to construct and manage arena enemy frame groups.
]]--

-- ArenaLive addon Name and localisation table:
local addonName, L = ...;

--[[
**************************************************
******* GENERAL HANDLER SET UP STARTS HERE *******
**************************************************
]]--
local ArenaHeader = ArenaLive:ConstructHandler("ArenaHeader", true);
local HealthBar = ArenaLive:GetHandler("HealthBar");
local PowerBar = ArenaLive:GetHandler("PowerBar");

local headers = {};

local NUM_MAX_ARENA_OPPONENTS = 5;

-- Set up a table for frames that need an update after CombatLockDown fades.
local headersToUpdate = {};

-- Register Events:
ArenaHeader:RegisterEvent("PLAYER_REGEN_ENABLED");
ArenaHeader:RegisterEvent("PLAYER_ENTERING_WORLD");
ArenaHeader:RegisterEvent("ARENA_OPPONENT_UPDATE");
ArenaHeader:RegisterEvent("ARENA_PREP_OPPONENT_SPECIALIZATIONS");

--Create a base class for this handler. All objects of the type UnitFrame will inherit functions from this one:
local ArenaHeaderClass = {};

--[[ Configuration Attributes for Arena Header:
	direction (string): Direction to which the unit frames will grow. Can be UP, DOWN, LEFT or RIGHT. Default: DOWN.
	space (number): Space in pixels between frames. Default: 0.
]]

--[[ Control Attributes for Arena Header:
	al_framelock (boolean): Defines whether the frame is locked or in config mode.
	numOpponents: Number of opponents. This is used to know which frames should be shown.
]]

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
 if ( name ~= "numopponents" and name ~= "al_framelock" ) then
  return;
 end

 if (not self:GetAttribute("al_framelock") ) then
  self:Show();
  for i = 1, 5 do
   local frameName = "Frame"..i;
   local frame = self:GetFrameRef(frameName);
   frame:Show();
  end
 elseif ( tonumber(self:GetAttribute("numopponents")) > 0 ) then
  local opponents = self:GetAttribute("numopponents");
  self:Show();
  for i = 1, 5 do
   local frameName = "Frame"..i;
   local frame = self:GetFrameRef(frameName);
   if ( i <= tonumber(opponents) ) then
    frame:Show();
   else
    frame:Hide();
   end
  end
 else
  self:Hide();
 end
]];

ArenaHeader.optionSets = {
	["Enable"] = {
		["type"] = "CheckButton",
		["title"] = L["Enable"],
		["tooltip"] = L["Enables Arena Frames."],
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
		["tooltip"] = L["Sets the direction to which the arena frames will grow."],
		["width"] = 150,
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
--[[ Method: ConstructObject
	 Create a unit frame and equip it with necessary methods etc.
		header (frame): The arena header frame.
		template (string): name of a template that will be used to create the arena header's unit frames.
		addonName (string): Name of the header's addon.
		initFunc (function): A function that will be called to initialise the header's unit frames.
		frameGroup (string): The header's frame group in the addon's database.
]]--
function ArenaHeader:ConstructObject(header, template, initFunc, addonName, frameGroup)

	-- Set control values:
	header.addon = addonName;
	header.group = frameGroup;
	header.template = template;
	header.initFunc = initFunc;
	
	local database = ArenaLive:GetDBComponent(addonName, self.name, frameGroup);
	
	-- Set initial values for attributes:
	header:SetAttribute("direction", database.GrowthDirection);
	header:SetAttribute("space", database.SpaceBetweenFrames);
	header:SetAttribute("numopponents", 0);
	
	-- Copy header class methods:
	ArenaLive:CopyClassMethods(ArenaHeaderClass, header);
	
	
	-- Create unit frames:
	local headerName = header:GetName();
	for i = 1, NUM_MAX_ARENA_OPPONENTS do
		local frame = CreateFrame("Button", headerName.."ArenaEnemyFrame"..i, header, template);
		header["Frame"..i] = frame;
		frame:SetID(i);
		ArenaLive:ConstructHandlerObject(frame, "UnitFrame", addonName, frameGroup, "target", "focus", nil, nil, true);
		header.initFunc(frame);
		header:SetFrameRef("Frame"..i, frame);
	end
	
	-- Add to headers table:
	headers[header] = true;
	
	-- Toggle header:
	header:Toggle();
end

function ArenaHeader:OnEvent(event, ...)
	if ( event == "PLAYER_REGEN_ENABLED" ) then
		for header in pairs(headersToUpdate) do
			if ( header.updateNumOpponents) then
				header:UpdateNumOpponents()
			end
			
			if ( header.updateAnchors ) then
				header:UpdateAnchors()
			end
			
			headersToUpdate[header] = nil;
		end
	elseif ( event == "PLAYER_ENTERING_WORLD" ) then
		for header in pairs(headers) do
			if ( header.enabled ) then
				header:UpdateNumOpponents();
			end
		end
	elseif ( event == "ARENA_OPPONENT_UPDATE" ) then
		local unit, state = ...;
		local numOpponents = GetNumArenaOpponents();
		for header in pairs(headers) do
			if ( header.enabled ) then
				local unitNumber = tonumber(string.match(unit, "^[a-z]+([0-9]+)$"));
				local frame = header["Frame"..unitNumber];
				
				if ( header:GetAttribute("numopponents") < numOpponents ) then
					header:UpdateNumOpponents();
				end				
				
				--[[ INFORMATION ON ARENA_OPPONENT_UPDATE:
					 seen = An enemy gets visible
					 unseen = An enemy gets invisible to the player or releases his/her Ghost.
					 destroyed = An enemy leaves the Arena.
					 cleared = This fires after you leave the Arena.
				]]--	
				if ( state == "seen" and UnitGUID(unit) ) then
					header:UnlockFrame(unitNumber);
					frame:UpdateGUID();
					frame:Update();
				elseif ( state == "destroyed" ) then
					header:UnlockFrame(unitNumber);
					frame:Update();
				elseif ( state == "cleared" ) then
					header:UnlockFrame(unitNumber);
					frame:UpdateGUID();
					frame:Reset();
				elseif ( state == "unseen" ) then
					header:LockFrame(unitNumber);
				end
			end
		end
	elseif ( event == "ARENA_PREP_OPPONENT_SPECIALIZATIONS" ) then
		for header in pairs(headers) do
			if ( header.enabled ) then
				header:UpdateNumOpponents();
			end
		end
	end
end

--[[
****************************************
****** CLASS METHODS START HERE ******
****************************************
]]--
function ArenaHeaderClass:Enable()
	local database = ArenaLive:GetDBComponent(self.addon, "FrameMover");
	self:SetScript("OnAttributeChanged", self.OnAttributeChanged);
	self:WrapScript(self, "OnAttributeChanged", onAttributeChangedSnippet);
	
	-- Enable frames:
	for i = 1, NUM_MAX_ARENA_OPPONENTS do
		local frame = self["Frame"..i];
		frame:Enable();
		frame:UpdateUnit("arena"..i);
	end
	
	
	self:UpdateNumOpponents();
	self:UpdateAnchors();
	self:SetAttribute("al_framelock", database.FrameLock);
	self.enabled = true;
	
	if ( type(self.OnEnable) == "function" ) then
		self:OnEnable();
	end
end

function ArenaHeaderClass:Disable()
	self:UnwrapScript(self, "OnAttributeChanged");
	self:SetScript("OnAttributeChanged", nil);
	
	-- Disable frames:
	for i = 1, NUM_MAX_ARENA_OPPONENTS do
		local frame = self["Frame"..i];
		frame:Disable();
	end	
	
	self.enabled = false;
	self:Hide();
	
	if ( type(self.OnDisable) == "function" ) then
		self:OnDisable();
	end
end

function ArenaHeaderClass:Toggle()
	local database = ArenaLive:GetDBComponent(self.addon, "ArenaHeader", self.group);
	local enabled = database.Enabled;
	if ( enabled ) then
		self:Enable();
	else
		self:Disable();
	end
end

function ArenaHeaderClass:UpdateAnchors()
	if ( not InCombatLockdown() ) then
		local direction = self:GetAttribute("direction") or "DOWN";
		local space = self:GetAttribute("space") or 0;
		
		local point, relativePoint, xOffset, yOffset = directionToPoints(self);
		local relativeTo, width, height;
		for i = 1, NUM_MAX_ARENA_OPPONENTS do
			local frame = self["Frame"..i];
			frame:ClearAllPoints();	
			
			if ( i == 1 ) then
				width, height = frame:GetSize();
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

				frame:SetPoint(point, self, point, firstX, firstY);
			else
				relativeTo = self["Frame"..i-1];
				frame:SetPoint(point, relativeTo, relativePoint, xOffset, yOffset);
			end
		end
		
		if ( direction == "DOWN" or direction == "UP" ) then
			width = width + 10;
			height = height*5 + space*4 + 10;
		else
			width = width*5 + space*4 + 10;
			height = height + 10;
		end
		
		self:SetSize(width, height);
		self.updateAnchors = nil;
	else
		self.updateAnchors = true;
		headersToUpdate[self] = true;
	end
end

function ArenaHeaderClass:UpdateNumOpponents()
	if ( not InCombatLockdown() ) then
		local numOpponents = 0;
		for i = 1, MAX_BATTLEFIELD_QUEUES do
			local status, _, _, _, _, teamSize = GetBattlefieldStatus(i)
			if (status == "active") then
				numOpponents = teamSize;
			end
		end
		
		if ( numOpponents == 0 ) then
			numOpponents = numOpponents or 0;
		end

		self:SetAttribute("numopponents", numOpponents);
		self.updateNumOpponents = nil;
	else
		self.updateNumOpponents = true;
		headersToUpdate[self] = true;
	end
end

function ArenaHeaderClass:OnAttributeChanged(name, value)
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
		self:UpdateAnchors();
	elseif ( name == "numopponents" and value > 0 ) then	
		for i = 1, value do
			local frame = self["Frame"..i];
			frame:Update();
			-- We are in the preparation room if GetNumArenaOpponents() returns 0, although attribute numopponents is bigger than 0.
			-- If this is the case, we need to reset health bar and power bars in order to make sure that they are filled completely and coloured grey.
			if ( GetNumArenaOpponents() == 0 ) then
				if ( frame.HealthBar ) then
					HealthBar:Reset(frame);
				end
				
				if ( frame.PowerBar ) then
					PowerBar:Reset(frame);
				end
				self:LockFrame(i);
			end
		end
	end
end

function ArenaHeaderClass:Update()
	for i = 1, NUM_MAX_ARENA_OPPONENTS do
		local frame = self["Frame"..i];
		frame:Update();
	end
end

function ArenaHeaderClass:Reset()
	for i = 1, NUM_MAX_ARENA_OPPONENTS do
		local frame = self["Frame"..i];
		frame:Reset();
	end
end

function ArenaHeaderClass:TestMode(mode)
	for i = 1, NUM_MAX_ARENA_OPPONENTS do
		local frame = self["Frame"..i];
		frame:TestMode(mode);
	end
end

function ArenaHeaderClass:LockFrame(frameID)
	if ( not frameID ) then
		return;
	end
	local frame = self["Frame"..frameID];
	
	if ( frame.HealthBar ) then
		frame.HealthBar.lockValues = true;
		frame.HealthBar.lockColour = true;
		frame.HealthBar:SetStatusBarColor(0.5, 0.5, 0.5);
	end
	
	if ( frame.PowerBar ) then
		frame.PowerBar.lockValues = true;
		frame.PowerBar.lockColour = true;
		frame.PowerBar:SetStatusBarColor(0.5, 0.5, 0.5);	
	end
end

function ArenaHeaderClass:UnlockFrame(frameID)
	if ( not frameID ) then
		return;
	end
	local frame = self["Frame"..frameID];
	
	if ( frame.HealthBar ) then
		frame.HealthBar.lockValues = nil;
		frame.HealthBar.lockColour = nil;
	end
	
	if ( frame.PowerBar ) then
		frame.PowerBar.lockValues = nil;
		frame.PowerBar.lockColour = nil;	
	end
	
	frame:Update();
end