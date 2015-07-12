--[[ ArenaLive Event Functions
Created by: Vadrak
Creation Date: 29.03.2014
Last Update: 16.05.2014
This files stores all event related functions for ArenaLive. It enables objects to register for event callbacks etc.
]]--

-- Get addon name and the localisation table:
local addonName, L = ...;

-- Create a table to store objects that are registered for events:
local registeredObjects = {}

-- Table to store custom events in. This is used to prevent ArenaLive's main frame from registered invalid events:
local customEvents = {};

-- Table for events that must always be registered.
local lockedEvents = {
	["ADDON_LOADED"] = true,
	["PLAYER_REGEN_DISABLED"] = true,
	["PLAYER_REGEN_ENABLED"] = true,
	["PLAYER_LOGOUT"] = true,
};

--[[
**********************************************
********* CLASS METHODS START HERE **********
**********************************************
]]--
-- Create a base class for the event objects:
local EventClass = {};

--[[ Function: RegisterEvent
	 Registers a specified event for a specified object.
		eventName (string): Name of the event to be unregistered.
		methodName (string [optional]): Name of a method that will be called when an event fires. Defaults to object:OnEvent(...)
]]--
function EventClass:RegisterEvent(eventName, methodName)
	
	ArenaLive:CheckArgs(self, "table", eventName, "string");

	-- Check if this one is the first object to register for this event:
	if ( not registeredObjects[eventName] ) then
		registeredObjects[eventName] = {};
		registeredObjects[eventName]["n"] = 0;
	end
	
	-- Now create the table entry:
	registeredObjects[eventName][self] = methodName or "OnEvent";
	registeredObjects[eventName]["n"] = registeredObjects[eventName]["n"] + 1;
	ArenaLive:CheckNumObjectsRegisteredForEvent(eventName);
end

--[[ Function: UnregisterEvent
	 Unregisters a specified event for a specified object.
		eventName (string): Name of the event to be unregistered.
]]--
function EventClass:UnregisterEvent(eventName)

	ArenaLive:CheckArgs(self, "table", eventName, "string");

	-- Check if there are any objects registered for this event:
	if ( not registeredObjects[eventName] ) then
		return;
	end
	
	-- Unregister object for specified event:
	if ( registeredObjects[eventName][self] ) then
		registeredObjects[eventName][self] = nil;
		registeredObjects[eventName]["n"] = registeredObjects[eventName]["n"] - 1;
		ArenaLive:CheckNumObjectsRegisteredForEvent(eventName);
	end
end

function EventClass:IsEventRegistered(eventName)
	if ( eventName ) then
		if ( registeredObjects[eventName] and registeredObjects[eventName][self] ) then
			return true;
		else
			return false;
		end
	else
		return false;
	end
end

--[[ Function: UnregisterAllEvents
	 Unregisters all custom events for a specified object.
]]--
function EventClass:UnregisterAllEvents()

	-- Unregister object for all events:
	for event in pairs(registeredObjects) do
		if ( registeredObjects[event][self] ) then
			registeredObjects[event][self] = nil;
			registeredObjects[event]["n"] = registeredObjects[event]["n"] - 1;
			ArenaLive:CheckNumObjectsRegisteredForEvent(event);
		end
	end

end

--[[ Function: IsRegisteredForEvent
	 Returns whether a object is registered for a specified event.
		eventName (string): Name of the event to be checked.
]]--
function EventClass:IsRegisteredForEvent(eventName)

	if ( registeredObjects[eventName] ) then
		if ( registeredObjects[eventName][self] ) then
			return true;
		else
			return false;
		end
	else
		return false;
	end

end



--[[
****************************************
****** EVENT FUNCTIONS START HERE ******
****************************************
]]--

--[[ Method: ConstructEvent
	 This functions is used to construct a custom event. If you want to use custom events in order to update your addon somehow,
	 make sure to add the events via this method first. Otherwise it would cause the ArenaLive frame to register for invalid events.
		ARGUMENTS:
			eventName (string): The name for the event.
]]--
function ArenaLive:ConstructEvent(eventName)
	ArenaLive:CheckArgs(eventName, "string");
	customEvents[eventName] = true;
end

--[[ Method: DestroyEvent
	 Deletes a custom constructed event.
		ARGUMENTS:
			eventName (string): The name for the event.
]]--
function ArenaLive:DestroyEvent(eventName)
	ArenaLive:CheckArgs(eventName, "string");
	
	if ( not customEvents[eventName] ) then
		ArenaLive:Message(L["Couldn't destroy custom event \"%s\", because there is no custom event with that name!"], "error", eventName);
		return;
	end
	
	-- Unregister all frames from this event:
	for object in pairs(registeredObjects[eventName]) do
		if ( object ~= "n" ) then
			object:UnregisterEvent(eventName);
		end
	end
	
	customEvents[eventName] = nil;
end

--[[ Method: TriggerEvent
	 This functions is used to initiate a custom event fire.
		ARGUMENTS:
			eventName (string): The name for the event.
			... (list): A list of further information that will be forwarded together with the event name to all registered frames.
]]--
function ArenaLive:TriggerEvent(eventName, ...)
	ArenaLive:OnEvent(eventName, ...);
end

--[[ Method: ConstructEventObject
	 Equips a specified object with above defined handler methods.
		object (frame/table): the object to equip with the methods.
]]--
function ArenaLive:ConstructEventObject(object)
	ArenaLive:CopyClassMethods(EventClass, object)
end

--[[ Method: DestroyEventObject
	 Removes above defined class methods from a specified object and unregisters all registered events first.
		object (frame/table): the object to equip with the methods.
]]--
function ArenaLive:DestroyEventObject(object)
	object:UnregisterAllEvents();
	
	for k in pairs(EventClass) do
		object[k] = nil;
	end
end

--[[ Method: CheckNumObjectsRegisteredForEvent
	 Checks if ArenaLive's core frame needs to (un-)register events. It also alters the events table accordingly
		eventName (string): Name of the event to be checked.
]]--
function ArenaLive:CheckNumObjectsRegisteredForEvent(eventName)

	if ( not registeredObjects[eventName] or customEvents[eventName] ) then
		return;
	end
	
	-- ArenaLive filters combat log events via the event2 arg, so check if this is a combat log event:
	local combatLog = string.match(eventName, "COMBAT_LOG_EVENT_UNFILTERED") or string.match(eventName, "COMBAT_LOG_EVENT") or false;
	local n = registeredObjects[eventName]["n"];
	
	if ( n > 0 ) then
		if ( combatLog and not ArenaLive:IsEventRegistered(combatLog) ) then
			ArenaLive:RegisterEvent(combatLog);
		elseif ( not combatLog and not ArenaLive:IsEventRegistered(eventName) ) then
			ArenaLive:RegisterEvent(eventName);
		end
		
	else
	
		-- Delete table entry for this event:
		registeredObjects[eventName]["n"] = nil;
		registeredObjects[eventName] = nil;
		
		-- Unregister ArenaLive for the specified event if needed:
		if ( combatLog and ArenaLive:IsEventRegistered(combatLog) and not lockedEvents[combatLog] ) then
			ArenaLive:UnregisterEvent(combatLog);
		elseif ( not combatLog and ArenaLive:IsEventRegistered(eventName) and not lockedEvents[eventName] ) then
			ArenaLive:UnregisterEvent(eventName);
		end
	
	end
	
end

--[[ Method: OnEvent
	 Function for handling events.
		event (string): Name of the event that fired.
		... (mixed): List of variables that accompany the event.
]]--
function ArenaLive:OnEvent(event, ...)
	local arg1 = ...;
	local event2;
	
	if ( event == "ADDON_LOADED" and arg1 == addonName ) then
		-- Initialise ArenaLive:
		ArenaLive:ConstructAddon(self, arg1, false, self.defaults, false, "ArenaLive_Database");
		ArenaLive:ConstructDatabase(arg1);
		self:UpdateDB();
		ArenaLive:InitializeGrid();
		if( self.database.DebugMessages ) then
			table.wipe(self.database.DebugMessages);
		end
	elseif ( event == "ADDON_LOADED" and self.addons[arg1] ) then
		-- Initialise Database for addons that are based on ArenaLive:
		ArenaLive:ConstructDatabase(arg1);
		
		-- Update database entries if a function is defined for the affected addon:
		local addon = self.addons[arg1];
		if ( type(addon.UpdateDB) == "function" ) then
			addon:UpdateDB();
		end
	elseif ( event == "PLAYER_LOGOUT" ) then
		ArenaLive:UpdateDebugCache();
	end
	
	
	-- Disable option frames during combat lockdown:
	if ( event == "PLAYER_REGEN_DISABLED" ) then
		ArenaLive:DisableAllOptionFrames();
	end
	
	-- Enable them again after combat lockdown fades:
	if ( event == "PLAYER_REGEN_ENABLED" ) then
		ArenaLive:EnableAllOptionFrames();
	end
	
	if ( event == "COMBAT_LOG_EVENT_UNFILTERED" or event == "COMBAT_LOG_EVENT" ) then
		event2 = select(2, ...);
		event2 = event.."_"..event2;
	end	
	
	-- Supply objects with filtered combat log events:
	if ( event2 and registeredObjects[event2] ) then
		for object, methodName in pairs(registeredObjects[event2]) do
			if ( object ~= "n" ) then
				object[methodName](object, event2, ...);
			end
		end
	end
	
	-- Supply objects with event:
	if ( registeredObjects[event] ) then
		for object, methodName in pairs(registeredObjects[event]) do
			if ( object ~= "n" ) then
				if ( type(object[methodName]) ~= "function" ) then
					ArenaLive:Message("Object %s's method %s[%s] has type %s instead of function.", "debug", tostring(object), tostring(object.name), tostring(object[methodName]), tostring(type(object[methodName])));
				else
					object[methodName](object, event, ...);
				end
			end
		end	
	end
end

-- Register locked events and set OnEvent script:
ArenaLive:RegisterEvent("PLAYER_REGEN_DISABLED");
ArenaLive:RegisterEvent("PLAYER_REGEN_ENABLED");
ArenaLive:RegisterEvent("ADDON_LOADED");
ArenaLive:RegisterEvent("PLAYER_LOGOUT");
ArenaLive:SetScript("OnEvent", ArenaLive.OnEvent);