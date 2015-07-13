--[[ ArenaLive Core Functions
Created by: Vadrak
Creation Date: 29.03.2014
Last Update: 02.03.2015
This function set builds the base for the core of ArenaLive. These functions will take control over any ArenaLive based handlers and addons.
The so called "handlers", which are defined in their respective files, control the way how certain frame types behave for any ArenaLive addons.
]]--

function log(msg)
	DEFAULT_CHAT_FRAME:AddMessage(msg);
end

function firstToUpper(str)
    return (str:gsub("^%l", string.upper))
end

LoadAddOn("Blizzard_ArenaUI")
for i=1,5 do
	_G["ArenaEnemyFrame"..i].Show = function () end;
end
for i=1,4 do
	_G["PartyMemberFrame"..i].Show = function () end;
end	

-- Set up some base values:
local ARENALIVE_CHAT_MSG_PREFIX = "|cFFFF0000ArenaLive:|r ";
local ARENALIVE_DEBUG_MSG_PREFIX = "|cFFFF0000ArenaLive Debugger:|r ";
ArenaLive.debug = false;

-- Get addon name and the localisation table:
local addonName, L = ...;

-- Default values:
ArenaLive.defaults = {
	["Version"] = "3.2.0b",
	["Grid"] = {
		["Shown"] = false,
	},
	["DebugMessages"] = {};
};

-- Test mode values:
ArenaLive.testModeValues = 
	{
		[1] = {
			["name"] = "Vadrak",
			["level"] = 90,
			["healthMin"] = 0,
			["healthMax"] = 528000,
			["healthCurr"] = 396000,
			["powerMin"] = 0,
			["powerMax"] = 600000,
			["powerCurr"] = 210000,
			["powerType"] = "MANA",
			["class"] = "PRIEST",
			["classID"] = 5,
			["specID"] = 2,
			["race"] = "Scourge",
			["sex"] = 2,
			["faction"] = "Horde",
			["reaction"] = { 1, 0, 0 },
		},
		[2] = {
			["name"] = "Daara",
			["level"] = 90,
			["healthMin"] = 0,
			["healthMax"] = 500000,
			["healthCurr"] = 250000,
			["powerMin"] = 0,
			["powerMax"] = 600000,
			["powerCurr"] = 600000,
			["powerType"] = "MANA",
			["class"] = "DRUID",
			["classID"] = 11,
			["specID"] = 4,
			["race"] = "NightElf",
			["sex"] = 3,
			["faction"] = "Alliance",
			["reaction"] = { 0, 1, 0 },
		},
		[3] = {
			["name"] = "Vishas",
			["level"] = 90,
			["healthMin"] = 0,
			["healthMax"] = 600000,
			["healthCurr"] = 360000,
			["powerMin"] = 0,
			["powerMax"] = 100,
			["powerCurr"] = 80,
			["powerType"] = "ENERGY",
			["class"] = "ROGUE",
			["classID"] = 4,
			["specID"] = 3,
			["race"] = "Human",
			["sex"] = 3,
			["faction"] = "Alliance",
			["reaction"] = { 0, 0, 1 },			
		},
		[4] = {
			["name"] = "Lyncari",
			["level"] = 90,
			["healthMin"] = 0,
			["healthMax"] = 480000,
			["healthCurr"] = 480000,
			["powerMin"] = 0,
			["powerMax"] = 27000,
			["powerCurr"] = 1000,
			["class"] = "PALADIN",
			["classID"] = 2,
			["specID"] = 3,
			["powerType"] = "MANA",
			["race"] = "Draenei",
			["sex"] = 3,
			["faction"] = "Alliance",
			["reaction"] = { 0, 0, 1 },			
		},
		[5] = {
			["name"] = "Naratya",
			["level"] = 90,
			["healthMin"] = 0,
			["healthMax"] = 528000,
			["healthCurr"] = 132000,
			["powerMin"] = 0,
			["powerMax"] = 100,
			["powerCurr"] = 50,
			["class"] = "WARRIOR",
			["classID"] = 1,
			["specID"] = 2,
			["powerType"] = "RAGE",
			["race"] = "Orc",
			["sex"] = 3,
			["faction"] = "Horde",
			["reaction"] = { 0, 0, 1 },			
		},
	};

--[[
****************************************
****** BASIC FUNCTIONS START HERE ******
****************************************
]]--

--[[ Method: Message
	 Used to post ArenaLive's system messages.
		msg (string): the message that will be sent.
		... (mixed): A list of variables that will be added to the message.
]]--
local debugMessages = {};
function ArenaLive:Message (msg, msgType, ...)
	ArenaLive:CheckArgs(msg, "string");
	
	local numArgs = select('#', ...) or 0;
	
	-- Format string if needed:
	if ( numArgs > 0 ) then
		msg = string.format(msg, ...);
	end
	
	if ( msgType == "error" ) then
		error(msg);
	elseif ( msgType == "debug" ) then
		table.insert(debugMessages, {theDate, msg});
		
		if ( ArenaLive.debug ) then
			local theDate = date("%d.%m.%y %H:%M:%S");
			print(ARENALIVE_DEBUG_MSG_PREFIX..msg);
		end
	else
		print(ARENALIVE_CHAT_MSG_PREFIX..msg);
	end

end

--[[ Method: UpdateDebugCache
	 Stores debug messages to the saved variables before player logs out.
]]--
function ArenaLive:UpdateDebugCache()
	local database = ArenaLive:GetDBComponent(addonName);
	database.DebugMessages = debugMessages;
end

--[[ Method: CheckArgs
	 Checks if all needed args for a function were handed over. Also checks their type.
		... (mixed): An even(!) list of variables to checkfollowed by the variable type they should have (e.g. arg1="Hello World!" arg2="string" arg3=1 arg4="number"...).
					 If a value doesn't fit it will create an error message.
]]--
function ArenaLive:CheckArgs (...)
	
	local numArgs = select('#', ...) or 0;
	local checkID = 1;
	
	if ( numArgs > 0 and numArgs % 2 == 0 ) then
		local object, varType, expected;
		
		while ( checkID < numArgs ) do
			object = select(checkID, ...);
			varType = type(object);
			expected = select(checkID + 1, ...);
			
			
			if ( varType ~= expected ) then
				-- varType and expected don't fit. Check if we might have to test for a special frame/object type, which is not returned by normal type function:
				if ( not object or not object.GetObjectType or object:GetObjectType() ~= expected ) then
					if ( object and object.GetObjectType ) then
						-- Change varType with objectType, in order to give a better error report:
						varType = object:GetObjectType();
					end
					ArenaLive:Message(L["Error in method ArenaLive:CheckArgs! Variable type expected: %s, but actual variable type is %s. checkID = %d."], "error", expected, varType, checkID);
					return false;
				end
			end
			
			checkID = checkID + 2;
		end
		
	elseif ( numArgs == 0 ) then
		-- No Args given.
		return true;
	else
		ArenaLive:Message(L["Error in Method ArenaLive:CheckArgs! Function needs an even number of arguments. Number of arguments: %d"], "error", numArgs);
		return false;
	end

	return true;
end

--[[ Method: CopyClassMethods
	 Copies the defined methods of a specified class table to a target object.
		ARGUMENTS:
			class (table): Table to copy methods from.
			object (table): The target object that will receive the copies.
]]--
function ArenaLive:CopyClassMethods(class, object)
	for k, v in pairs(class) do
		-- Make sure to only copy functions:
		if ( type(v) == "function" ) then
			object[k] = v;
		end
	end
end

--[[
****************************************
****** ADDON FUNCTIONS START HERE ******
****************************************
]]--
-- Create a table to store addon info:
ArenaLive.addons = {};

--[[ Method: AddAddon
	 Adds an addon object to ArenaLive's addon database.
		addon (table/frame): Object of the new addon.
		addonName (sting): Name of the new addon.
		isEventObject (boolean): If true, the standard functions to (un-)register events will be overwritten with those of ArenaLive.
		defaults (table): the addon's default values.
		hasProfiles (boolean): Is the database sorted by profiles?	
		savedVariables (string [optional]): Name of the SavedVariables table for this addon.
]]--
function ArenaLive:ConstructAddon (addon, addonName, isEventObject, defaults, hasProfiles, savedVariables)

	self:CheckArgs(addon, "table", addonName, "string");

	if ( self.addons[addonName] ) then
		self:Message(L["Couldn't add addon via method ArenaLive:AddAddon, because there already is an addon with the name %s registered."], "error", addonName);
		return;
	end

	addon.name = addonName;
	
	if ( isEventObject ) then
		self:ConstructEventObject(addon);
	end
	
	-- Set up addon object with all needed information:
	self.addons[addonName] = addon;
	addon.defaults = defaults;
	addon.hasProfiles = hasProfiles;
	addon.dbString = savedVariables;
end



--[[
*******************************************
****** DATABASE FUNCTIONS START HERE ******
*******************************************
]]--
--[[ Method: ConstructDatabase
	 Creates an ArenaLive based database for an addon.
		ARGUMENTS:
			addonName (string): Name of the addon, for which the data base will be constructed.
]]--
function ArenaLive:ConstructDatabase (addonName)
	ArenaLive:CheckArgs(addonName, "string");
	
	local addon = ArenaLive.addons[addonName];
	
	if ( addon ) then
		-- Set up database for the addon:	
		if ( _G[addon.dbString] ) then
			addon.database = _G[addon.dbString];
		else
			_G[addon.dbString] = addon.defaults;
			addon.database = _G[addon.dbString];
		end	
	end
	
	if ( ArenaLive:DBHasProfiles(addonName) ) then
		-- Set active profile according to the character that is currently logged on:
		local name, realm;
		name = UnitName("player");
		realm = GetRealmName();
		name = name.."-"..realm;
		
		if ( not addon.database.CharacterToProfile[name] ) then
			-- This is the first time the character uses ArenaLive, so load default profile:
			addon.database.CharacterToProfile[name] = "default";
		end
		
		addon.database.ActiveProfile = addon.database.CharacterToProfile[name];
	end
end

--[[ Method: DBHasProfiles
	 Returns whether a database uses a profile structure.
		ARGUMENTS:
			addonName (string): Name of the Addon.
		RETURNS:
			boolean. True, if the database has profiles or false if it hasn't not.
]]--
function ArenaLive:DBHasProfiles (addonName)

	ArenaLive:CheckArgs(addonName, "string");
	
	if ( not ArenaLive.addons[addonName] ) then
		ArenaLive:Message (L["Couldn't query if database has profiles, because no database for the addon %s is registered!"], "error", addonName);
	end

	if ( ArenaLive.addons[addonName].hasProfiles ) then
		return true;
	else
		return false;
	end
	
end

--[[ Method: GetDBComponent
	 Returns either the complete database of the specified addon or a component, depending on further args.
		ARGUMENTS:
			addonName (string): Name of the addon the database belongs to.
			frameType (string [optional]): Name of a frame type in the database's sub structure.
			handlerName (string [optional]): Name of a handler in the database's sub structure.
		RETURNS:
			The queried database component.
]]--
local component;
function ArenaLive:GetDBComponent (addonName, handlerName, frameType)
	
	ArenaLive:CheckArgs(addonName, "string");
	
	if ( not ArenaLive.addons[addonName] ) then
		ArenaLive:Message (L["Couldn't query database for value, because no database for the addon %s is registered!"], "error", addonName);
	end
	
	-- Get the needed data base:
	component = ArenaLive.addons[addonName].database;
	
	-- Check if this database uses profiles:
	if ( ArenaLive:DBHasProfiles(addonName) ) then
		component = component[component.ActiveProfile];
	end
	
	if ( frameType ) then
		component = component[frameType];
	end
	
	if ( handlerName ) then
		component = component[handlerName];
	end
	
	return component;
end

--[[ Method: GetPetUnit
	 Returns the unitID of the given unitID's pet.
		ARGUMENTS:
			unit (string): UnitID.
		RETURNS:
			The pet's unitID.
]]--
function ArenaLive:GetPetUnit(unit)
	if ( unit == "player" ) then
		return "pet";
	else
		local unitType, unitNumber = string.match(unit, "^([a-z]+)([0-9]+)$");
		if ( not unitType ) then
			unitType = unit;
		end
		
		if ( unitNumber ) then
			if ( unitType == "spectateda" ) then -- Spectated pet units are different from others.
				return "spectatedpeta"..unitNumber;
			elseif ( unitType == "spectatedb" ) then
				return "spectatedpetb"..unitNumber;
			else
				return unitType.."pet"..unitNumber;
			end
		else
			return unitType.."pet";
		end
	end
end

--[[ Method: GetPetOwnerUnit
	 Returns the owner unitID of a pet unitID or returns the unit, if the unit is not pet unit.
		ARGUMENTS:
			unit (string): UnitID.
		RETURNS:
			The pet owner's unitID.
]]--
function ArenaLive:GetPetOwnerUnit(unit)
	if ( not unit ) then
		return;
	end
	
	if ( unit == "pet" ) then
		return "player";
	else
		return string.gsub(unit, "pet", "");
	end
end

--[[ Method: CopyTable
	 Copies a table and returns the newly created table.
		ARGUMENTS:
			t (table): The table that will be copied.
		RETURNS:
			New table.
]]--
function ArenaLive:CopyTable(t)
	ArenaLive:CheckArgs(t, "table");
	
	local new = {};
	for key, value in pairs(t) do
		if ( type(value) == "table" ) then
			new[key] = self:CopyTable(value)
		else
			new[key] = value;
		end
	end
	
	return new;
end

--[[ Method: UpdateDB
	 Updates ArenaLive saved variables to the newest version.
]]--
function ArenaLive:UpdateDB()
	local database = self:GetDBComponent(addonName);
	database.version = nil;
	if ( not database.Version ) then
		-- Oldest version of ArenaLive3 [Core]:
		database.Version = "3.1.0b";
	end
	
	if ( database.Version == "3.1.0" or database.Version == "3.1.0b" ) then
		database.Version = "3.1.1b";
	end
	
	if ( database.Version == "3.1.1b" ) then
		database.DebugMessages = {};
		database.Version = "3.1.2b";
	end
	
	if ( database.Version ~= "3.2.0b" ) then
		database.Version = "3.2.0b";
	end
end