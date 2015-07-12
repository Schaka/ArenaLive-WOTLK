--[[ ArenaLive Core Functions: UnitFrame Handler
Created by: Vadrak
Creation Date: 03.04.2014
Last Update: 16.05.2014
These functions are used to set up every standard unit frame. For grouped unit frames (party/raid/arena) see also GroupHeader.lua.
]]--

-- ArenaLive addon Name and localisation table:
local addonName, L = ...;

--[[
**************************************************
******* GENERAL HANDLER SET UP STARTS HERE *******
**************************************************
]]--
-- Create new Handler and register for all important events:
local UnitFrame = ArenaLive:ConstructHandler("UnitFrame", true);
UnitFrame:RegisterEvent("PLAYER_REGEN_ENABLED");
UnitFrame:RegisterEvent("PLAYER_TARGET_CHANGED");
UnitFrame:RegisterEvent("PLAYER_FOCUS_CHANGED");
UnitFrame:RegisterEvent("UNIT_PET");
UnitFrame:RegisterEvent("UNIT_CONNECTION");
UnitFrame:RegisterEvent("UNIT_NAME_UPDATE");
UnitFrame:RegisterEvent("PLAYER_ENTERING_WORLD");

-- Create a table to update frame's unit after combat lockdown fades if they tried to change it during combat lockdown
UnitFrame.updateUnitCallback = {};

-- Create tables to store registered unit frames sorted by unitID, GUID:
UnitFrame.UnitFrames = {};
UnitFrame.IndexByUnit = {};
UnitFrame.IndexByGUID = {};

--[[ Method: GetAllUnitFrames
	 This function basically is similar to the standard pairs() iterate function.
	 It returns the next function and the table containing all unit frames.
		RETRUNS:
			next: next function to iterate through the table.
			table: The table including all unit frames.
			nil is returned as a third value so the next function starts at an initial key-value pair.
]]--
function ArenaLive:GetAllUnitFrames ()
	return next, UnitFrame.UnitFrames, nil;
end

--[[ Method: GetAffectedUnitFramesByUnit
	 This function basically is similar to the standard pairs() iterate function.
	 It returns the next function and the table containing all IDs of unit frames that currently show the queried unit.
		ARGUMENTS:
			unit: unitID to query the unit frame data base for.
		RETRUNS:
			next: next function to iterate through the table.
			table: The table including all frame IDs that currently show the specified unit.
			nil is returned as a third value so the next function starts at an initial key-value pair.
]]--
function ArenaLive:GetAffectedUnitFramesByUnit (unit)
	return next, UnitFrame.IndexByUnit[unit], nil;
end

function ArenaLive:IsUnitInUnitFrameCache(unit)
	if ( UnitFrame.IndexByUnit[unit] ) then
		return true;
	else
		return false;
	end
end

--[[ Method: GetAffectedUnitFramesByUnit
	 This function basically is similar to the standard pairs() iterate function.
	 It returns the next function and the table containing all IDs of unit frames that currently show the queried GUID.
		ARGUMENTS:
			guid: GUID to query the unit frame data base for.
		RETRUNS:
			next: next function to iterate through the table.
			table: The table including all frame IDs that currently show the specified GUID.
			nil is returned as a third value so the next function starts at an initial key-value pair.
]]--
function ArenaLive:GetAffectedUnitFramesByGUID (guid)
	return next, UnitFrame.IndexByGUID[guid], nil;
end

function ArenaLive:IsGUIDInUnitFrameCache(guid)
	if ( UnitFrame.IndexByGUID[guid] ) then
		return true;
	else
		return false;
	end
end

--[[ Method: GetUnitFrameByID
	 Returns the unit frame with the specified ID from the unit frame database.
	 It returns the next function and the table containing all IDs of unit frames that currently show the queried GUID.
		ARGUMENTS:
			id: ID of the unit frame that will be returned.
		RETRUNS:
			frame: The unit frame with the specified ID.
]]--
function ArenaLive:GetUnitFrameByID (id)
	return UnitFrame.UnitFrames[id];
end

--[[ We make unit frames SecureHandlers in order to detect, whether a unit frame should be shown or not.
	 So the following code snippet is used to regulate visibility of a normal unit frame.
	 For further details on this functionality see: http://www.wowwiki.com/SecureHandlers or SecureHandlers.lua in WoW's FrameXML.
	 function args: self, name, value
]]
local onAttributeChangedSnippet = [[
 if ( name ~= "state-unitexists" and name ~= "al_alwaysvisible" and name ~= "al_framelock" and name ~= "unit" ) then
  return;
 end

 if ( self:GetAttribute("al_alwaysvisible") ) then
  self:Show();
 elseif (not self:GetAttribute("al_framelock") ) then
  self:Show();
 elseif ( self:GetAttribute("state-unitexists") ) then
  self:Show();
 else
  self:Hide();
 end
]];

UnitFrame.optionSets = {
	["Enable"] = {
		["type"] = "CheckButton",
		["title"] = L["Enable"],
		["tooltip"] = L["Enables the unit frame."],
		["GetDBValue"] = function (frame) local database = ArenaLive:GetDBComponent(frame.addon, "UnitFrame", frame.group); return database.Enabled; end,
		["SetDBValue"] = function (frame, newValue) local database = ArenaLive:GetDBComponent(frame.addon, "UnitFrame", frame.group); database.Enabled = newValue; end,
		["postUpdate"] = function (frame, newValue, oldValue)
			for id, unitFrame in ArenaLive:GetAllUnitFrames() do 
				if ( unitFrame.addon == frame.addon and unitFrame.group == frame.group ) then
					if ( newValue ) then
						unitFrame:Enable();
					else 
						unitFrame:Disable();
					end
				end
			end
		end,
	},
	["ClickThrough"] = {
		["type"] = "CheckButton",
		["title"] = L["Click Through"],
		["tooltip"] = L["If checked, the unit frame will not interact with the cursor."],
		["GetDBValue"] = function (frame) local database = ArenaLive:GetDBComponent(frame.addon, "UnitFrame", frame.group); return database.ClickThrough; end,
		["SetDBValue"] = function (frame, newValue) local database = ArenaLive:GetDBComponent(frame.addon, "UnitFrame", frame.group); database.ClickThrough = newValue; end,
		["postUpdate"] = function (frame, newValue, oldValue)
			for id, unitFrame in ArenaLive:GetAllUnitFrames() do 
				if ( unitFrame.addon == frame.addon and unitFrame.group == frame.group ) then
						unitFrame:EnableMouse((not newValue));
				end
			end
		end,
	},
	["ToolTipMode"] = {
		["type"] = "DropDown",
		["title"] = L["Show Tooltip"],
		["infoTable"] = {
			[1] = {
				["text"] = L["Always"],
				["value"] = "Always",
			},
			[2] = {
				["text"] = L["Out of Combat"],
				["value"] = "OutOfCombat",
			},
			[3] = {
				["text"] = L["Never"],
				["value"] = "Never",
			},
		},
		["GetDBValue"] = function (frame) local database = ArenaLive:GetDBComponent(frame.addon, "UnitFrame", frame.group); return database.TooltipMode; end,
		["SetDBValue"] = function (frame, newValue) local database = ArenaLive:GetDBComponent(frame.addon, "UnitFrame", frame.group); database.TooltipMode = newValue; end,		
	},
	["Scale"] = {
		["type"] = "Slider",
		["width"] = 150,
		["height"] = 17,
		["min"] = 50,
		["max"] = 200,
		["step"] = 1,
		["inputType"] = "NUMERIC",
		["title"] = L["Frame Scale (%)"],
		["tooltip"] = L["Sets the scale of the unit frame."],
		["GetDBValue"] = function (frame) local database = ArenaLive:GetDBComponent(frame.addon, frame.handler, frame.group); local scale = database.Scale or 1 return scale*100; end,
		["SetDBValue"] = function (frame, newValue) local database = ArenaLive:GetDBComponent(frame.addon, frame.handler, frame.group); database.Scale = newValue/100; end,
		["postUpdate"] = function (frame, newValue, oldValue)
			for id, unitFrame in ArenaLive:GetAllUnitFrames() do
				if ( unitFrame.addon == frame.addon and unitFrame.group == frame.group ) then
					local scale = newValue / 100;
					unitFrame:SetScale(scale);
					unitFrame:Update();
				end
			end
		end,
	},
};

--[[
****************************************
****** CLASS METHODS START HERE ******
****************************************
]]--
--Create a base class for this handler. All objects of the type UnitFrame will inherit functions from this one:
local UnitFrameClass = {};

--[[ Method: Enable
	 Enables the unit frame and all its constituents.
]]--
function UnitFrameClass:Enable ()
	-- Set general attributes according to saved variables:
	local database = ArenaLive:GetDBComponent(self.addon, "FrameMover");
	local frameLock = database.FrameLock;
	
	database = ArenaLive:GetDBComponent(self.addon, "UnitFrame", self.group);
	local scale = database.Scale or 1;
	
	if ( not self.hasHeader ) then
		--[[ RegisterUnitWatch with asState = true. 
			 This way it will change an attribute "state-unitexists" to true if the frame's unit exists.
			 This will call the onAttributeChangedSnippet I defined above and check whether the frame should be shown or not.
			 For further details see: http://www.wowwiki.com/SecureStateDriver or SecureStateDriver.lua in WoW's FrameXML.
		]]
		RegisterUnitWatch(self, true);
			
		-- Wrap secure onAttribute snippet:
		self:WrapScript(self, "OnAttributeChanged", onAttributeChangedSnippet);
	end
	
	self:SetAttribute("al_framelock", frameLock);
	self:SetScale(scale);
	self.enabled = true;
	
	-- Set Clickthrough state:
	self:EnableMouse((not database.ClickThrough));
	
	if ( type(self.OnEnable) == "function" ) then
		self:OnEnable();
	end
end

--[[ Method: Disable
	 Disables the unit frame and all its constituents.
]]--
function UnitFrameClass:Disable ()		
	if ( not self.hasHeader ) then
		-- Unwrap secure onAttribute snippet:
		self:UnwrapScript(self, "OnAttributeChanged");
		UnregisterUnitWatch(self);
	end
		
	self:UpdateUnit();
	self:Reset();
	self:Hide();
	self.enabled = false;
	
	if ( type(self.OnDisable) == "function" ) then
		self:OnDisable();
	end
end

--[[ Method: UpdateGUID
	 Update the unitID the frame shows.
		ARGUMENTS:
			unit (string): A viable unitID (e.g. "player", "target", ...)
]]--
function UnitFrameClass:UpdateUnit(unit)
	
	if ( self.enabled ) then
		if ( not InCombatLockdown() ) then
			-- self.unit is set via the OnAttributeChanged script in order to prevent self.unit being set without the attribute being changed.
			self:SetAttribute("unit", unit);
		else
			-- In case we're affected by combat lockdown the UnitFrame handler will update the unit as soon as combat fades:
			UnitFrame.updateUnitCallback[self] = unit or "reset";
			ArenaLive:Message("Tried to change %s's unit during combat lockdown. Adding it to the callback list...", "debug", self:GetName() or tostring(self));
		end
	else
		--ArenaLive:Message("Tried to change %s's unit although the frame is disabled. Please enable the frame and try again...", "debug", self:GetName() or tostring(self));
	end
end

--[[ Method: UpdateGUID
	 This function is used to update the frames GUID key after a unit change occured or after the same
	 unitID displays a different player/npc.
]]--
function UnitFrameClass:UpdateGUID ()
	if ( self.unit ) then
		local guid = UnitGUID(self.unit);
		
		if ( not self.guid or guid ~= self.guid ) then
			-- Reset old guid if necessary:
			if ( self.guid ) then
				UnitFrame.IndexByGUID[self.guid][self.id] = nil;
			end
			
			if ( guid ) then
				-- Add to global UF storage table:
				if ( not UnitFrame.IndexByGUID[guid] ) then
					UnitFrame.IndexByGUID[guid] = {};
				end
				UnitFrame.IndexByGUID[guid][self.id] = true;
			end
			-- Update frame's value:
			self.guid = guid;
		end
	elseif ( not self.unit and self.guid ) then
		-- Reset guid for there is no unit:	
		UnitFrame.IndexByGUID[self.guid][self.id] = nil;
		self.guid = nil;
	end
end

--[[ Method: Update
	 This function is used to set, whether the frame is in test mode or not. It will assign a number
	 to the .test key of the frame. This will be used in order to get sample values set in Core.lua.
		ARGUMENTS:
			mode (boolean): Depending on this value the test mode is either activated or deactivated.
]]--
function UnitFrameClass:TestMode (mode)
	if ( mode and ( not self.unit or not UnitExists(self.unit) ) ) then
		-- Random number to get one of the test mode data tables.
		local number = random(1, 5);
		self.test = number;
	else
		self.test = nil;
	end

	self:Update();
	
end

--[[ Method: Update
	 This function is used to update all registered handlers. Normally this is called after the unit of the frame changed
	 or the unitID serves to display a different player/npc. It brings all 
]]--
function UnitFrameClass:Update()
	if ( self.enabled ) then
		for handlerName, handler in pairs(ArenaLive.handlers) do
			if ( self[handlerName] ) then
				handler:Update(self);
			end
		end
	end
end

--[[ Method: Reset
	 This function is used to reset all registered handlers to their initial value/settings etc.
	 Mainly used when unit is set to nil via :UpdateUnit method.
]]--
function UnitFrameClass:Reset ()
	if ( self.enabled ) then
		for handlerName, handler in pairs(ArenaLive.handlers) do
			if ( self[handlerName] and type(handler.Reset) == "function" ) then
				handler:Reset(self);
			end
		end	
	end
end

--[[ Method: OnAttributeChanged
	 Function to use for the OnAttributeChanged script.
		ARGUMENTS:
			name (string): Name of the attribute that was changed.
			value (depends): New value of the affected attribute.
]]--
function UnitFrameClass:OnAttributeChanged (name, value)

	if ( name ~= "unit" or value == self.unit ) then
		return;
	end	
	
	
	if ( self.unit ) then
		-- Delete old entry:
		UnitFrame.IndexByUnit[self.unit][self.id] = nil;
	end

	-- Add to global UF storage table:
	if ( value ) then
		if ( not UnitFrame.IndexByUnit[value] ) then
			UnitFrame.IndexByUnit[value] = {};
		end
		UnitFrame.IndexByUnit[value][self.id] = true;
	end
	
	self.unit = value;
	self:UpdateGUID();
	
	-- Update frame:
	self:Update();

end

--[[ Method: OnEnter
	 Function to use for the OnEnter script.
]]--
function UnitFrameClass:OnEnter ()

	local database = ArenaLive:GetDBComponent(self.addon, "UnitFrame", self.group);
	local showTooltip = database.TooltipMode;
	
	if ( ( showTooltip == "OutOfCombat" and not InCombatLockdown() ) or ( showTooltip == "Always" ) ) then
		if ( self.unit and UnitExists(self.unit) ) then
			GameTooltip_SetDefaultAnchor(GameTooltip, self);
			GameTooltip:SetUnit(self.unit, self.hideStatusOnTooltip)
			local r, g, b = GameTooltip_UnitColor(self.unit);
			GameTooltipTextLeft1:SetTextColor(r, g, b);
			GameTooltip:Show();
		end		
	end

end

--[[ Method: OnLeave
	 Function to use for the OnLeave script.
]]--
function UnitFrameClass:OnLeave ()
	if ( GameTooltip:IsShown() ) then
		GameTooltip:FadeOut();
	end
end

--[[ Method: RegisterHandler
	 Registers a subordinate handler. This way it will get unit and guid info from the unit frame etc.
		ARGUMENTS:
			object (frame/object): the frame/object that will be registered and constructed as the specified handler type.
			handlerName (string): Name of the handler type.
			identifier (string/number [depends]: This is used to set the key entry for a new object of a multiple handler type object.
												 CAUTION: It has correlate with the respective database entry for this object in order 
														  to retrieve the needed settings to set up the object.
			... (list): A list of further arguments to construct the handler object.
]]--
local handler;
function UnitFrameClass:RegisterHandler(object, handlerName, identifier, ...)

	ArenaLive:CheckArgs(handlerName, "string");	
	
	handler = ArenaLive:GetHandler(handlerName);
	local frameName = self:GetName() or tostring(self);
	
	if ( handler.multiple ) then
		if ( not self[handlerName] ) then
			-- This is the first instance of this handler created for this specific unit frame.
			-- So create a table for the handler:
			self[handlerName] = {};
		end
		
		object.id = identifier;
		
		ArenaLive:ConstructHandlerObject(object, handlerName, ...);
		self[handlerName][identifier] = object;
	else
		if ( not self[handlerName] ) then
			self[handlerName] = object;
			ArenaLive:ConstructHandlerObject(object, handlerName, ...);
		else
			ArenaLive:Message(L["Couldn't register handler %s for unit frame %s, because there already is a handler of that type registered!"], "error", handlerName, frameName);
		end	
	
	end
	
	-- Enable/Disable new handler if necessary:
	self:ToggleHandler(handlerName);
end

--[[ Method: UnregisterHandler
	 Unregisters a subordinate handler by its type.
		handlerName (string): Name of the handler type.
]]--
function UnitFrameClass:UnregisterHandler (handlerName)

	ArenaLive:CheckArgs(handlerName, "string");
	
	handler = ArenaLive:GetHandler(handlerName);
	local frameName = self:GetName() or tostring(self);
	
	if ( self[handlerName] ) then
		if ( handler.multiple ) then
			table.wipe(self[handlerName]);
		end
		
		self[handlerName] = nil;
		
	else
		ArenaLive:Message (L["Couldn't unregister handler %s for unit frame %s, because there is no handler of that type registered!"], "error", handlerName, frameName);
	end

end

function UnitFrameClass:ToggleHandler (handlerName)
	handler = ArenaLive:GetHandler(handlerName);
	if ( not handler.canToggle ) then
		return;
	end
	
	local database = ArenaLive:GetDBComponent(self.addon, handler.name, self.group);
	if ( database.Enabled ) then
		self[handlerName].enabled = true;
		if ( handler.OnEnable ) then
			handler:OnEnable(self);
		end
	else
		self[handlerName].enabled = nil;
		if ( handler.OnDisable ) then
			handler:OnDisable(self);
		end
	end
end

--[[
****************************************
****** HANDLER METHODS START HERE ******
****************************************
]]--
--[[ Method: ConstructObject
	 Create a unit frame and equip it with necessary methods etc.
		frame (frame): The unit frame.
		addonName (string): Name of the addon the frame belongs to.
		frameGroup (string): Unit frame group in the addon's data base the frame belongs to.
		leftClick (string [optional]): Action to execute when frame is left clicked. Defaults to "target".
		rightClick (string [optional]): Action to execute when frame is right clicked. Defaults to "togglemenu".
		menuFunc (function [optional]): If either leftClick or rightClick is set to "menu" then add the function to open the menu here. Otherwise leave this blank.
		alwaysVisible (boolean): If true, the frame will allways be visible, even if it has no unit.
		hasHeader (boolean): This is to inform the function if the frame is part of a frame group (e.g. Party frames, Arena Frames etc.) or not. DO NOT CONFUSE THIS WITH the frameGroup arg.
]]--
function UnitFrame:ConstructObject(frame, addonName, frameGroup, leftClick, rightClick, menuFunc, alwaysVisible, hasHeader)
	
	if ( InCombatLockdown() ) then
		ArenaLive:Message (L["Couldn't construct new unit frame, because interface currently is in combat lockdown!"], "error", handlerName, frameName);
		return;
	end
	
	ArenaLive:CheckArgs(frame, "Button", addonName, "string");

	-- Set addon name:
	frame.addon = addonName;
	frame.group = frameGroup;
	frame.hasHeader = hasHeader;
	
	-- Set up clicking scripts:
	frame:RegisterForClicks("LeftButtonUp", "RightButtonUp");
	frame:SetAttribute("*type1", leftClick or "target");
	frame:SetAttribute("*type2", rightClick or "togglemenu");
	
	if ( leftClick == "menu" or rightClick == "menu" ) then
		frame.menu = menuFunc;
	end
	
	-- Add unit frame methods and set scripts:
	ArenaLive:CopyClassMethods(UnitFrameClass, frame);
	
	frame:SetScript("OnAttributeChanged", frame.OnAttributeChanged);
	frame:SetScript("OnEnter", frame.OnEnter);
	frame:SetScript("OnLeave", frame.OnLeave);	
	
	-- Add ClickCast functionality:
	UnitFrame:RegisterClickCast(frame);	

	-- Add Frame to unit frame table and set its ID according to the entry:
	table.insert(UnitFrame.UnitFrames, frame);
	frame.id = #UnitFrame.UnitFrames;
	
	local database = ArenaLive:GetDBComponent(addonName, self.name, frameGroup);
	if ( database.Enabled ) then
		frame:Enable();
	else
		frame:Disable();
	end
	
	-- Set Attribute after enabling/disabling the frame so it will update the visibility once:
	if ( not hasHeader ) then
		frame:SetAttribute("al_alwaysvisible", alwaysVisible);
	end
	
	--ArenaLive:Message("Successfully created new unit frame with the name %s!", "debug", frame:GetName() or tostring(frame));
end

--[[ Method: RegisterClickCast
	 Registers click cast addons for the specified frame.
		frame (frame): the affected frame.
]]--
function UnitFrame:RegisterClickCast(frame)

	-- If the addon is loaded before the click cast addon set up the table for these addon's first.
	if ( not ClickCastFrames ) then
		ClickCastFrames = {};
	end
	
	ClickCastFrames[frame] = true;

end

--[[ Method: UnregisterClickCast
	 Unregisters click cast addons for the specified frame.
		frame (frame): the affected frame.
]]--
function UnitFrame:UnregisterClickCast(frame)

	if ( ClickCastFrames ) then
		ClickCastFrames[frame] = nil;
	end

end

--[[ Method: OnEvent
	 ArenaLive's CoreEvent.lua will forward all registered event fires for the UnitFrame handler to this method.
		event (string): The event that fired.
		... (list): A list of further information that accompanies the event trigger.
]]--
function UnitFrame:OnEvent(event, ...)
	local filter = ...;
	
	if ( event == "PLAYER_REGEN_ENABLED" ) then
		for frame, unit in pairs(self.updateUnitCallback) do
			if ( unit == "reset" ) then
				frame:UpdateUnit();
			else
				frame:UpdateUnit(unit);
			end
		end
		table.wipe(self.updateUnitCallback);
	elseif ( event == "PLAYER_TARGET_CHANGED" ) then
		if ( UnitExists("target") ) then
			if ( ArenaLive:IsUnitInUnitFrameCache("target") ) then
				for id, isRegistered in ArenaLive:GetAffectedUnitFramesByUnit("target") do
					local frame = self.UnitFrames[id];
					frame:UpdateGUID();
					frame:Update();
				end
			end
		end
	elseif ( event == "PLAYER_FOCUS_CHANGED" ) then
		if ( UnitExists("focus") ) then
			if ( ArenaLive:IsUnitInUnitFrameCache("focus") ) then
				for id, isRegistered in ArenaLive:GetAffectedUnitFramesByUnit("focus") do
					local frame = self.UnitFrames[id];
					frame:UpdateGUID();
					frame:Update();
				end
			end
		end
	elseif ( event == "PLAYER_ENTERING_WORLD" ) then
		-- NOTE: May cause lags, because we update ALL the unit frames at once during every loading screen. Just keep this note in case we need to get rid of it:
		for id, frame in ArenaLive:GetAllUnitFrames() do
			if ( frame.enabled ) then
				frame:Update();
			end
		end
	else
		if ( event == "UNIT_PET") then
			local unitType = string.match(filter, "^([a-z]+)[0-9]+$") or filter;
			local unitNumber = tonumber(string.match(filter, "^[a-z]+([0-9]+)$"));
			
			if ( unitType == "player" ) then
				filter = "pet";
			elseif ( unitNumber ) then
				filter = unitType.."pet"..unitNumber;
			else
				filter = unitType.."pet";
			end
		end
		
		if ( ArenaLive:IsUnitInUnitFrameCache(filter) ) then
			for id, isRegistered in ArenaLive:GetAffectedUnitFramesByUnit(filter) do
				local frame = self.UnitFrames[id];
				frame:UpdateGUID();
				frame:Update();
			end
		end

	end
end