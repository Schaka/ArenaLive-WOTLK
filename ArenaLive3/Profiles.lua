--[[ ArenaLive Core Functions: Profile Handler
Created by: Vadrak
Creation Date: 24.05.2014
Last Update: "
Used to manage profiles for addons.
]]--

-- ArenaLive addon Name and localisation table:
local addonName, L = ...;

--[[
**************************************************
******* GENERAL HANDLER SET UP STARTS HERE *******
**************************************************
]]--
local Profiles = ArenaLive:ConstructHandler("Profiles");
ArenaLive:ConstructEvent("ARENALIVE_ACTIVE_PROFILE_CHANGED")

local function copyTable (from, to)
	ArenaLive:CheckArgs(from, "table", to, "table");
	
	for key, value in pairs(from) do
		if ( type(value) == "table" ) then
			-- Create a new table if no table with the key exists in the to table:
			if ( not to[key] ) then
				to[key] = {};
			end
			
			-- Call this function for the sub tables:
			copyTable (from[key], to[key]);
		else
			to[key] = value;
		end
	end
end

--[[ Method: CreateProfile
	 Creates a new profile inside the data base of the specified addon.
		addonName (string): Name of the addon the profile will be created for.
		newName (string): Name of the profile that is going to be created.
		copyFromName (string [optional]): Name of an existing profile the new profile will inherit from.
			NOTE: If copyFrom refers to a profile that does not exist or is left blank, the default profile will be used instead
]]--
function Profiles:CreateProfile (addonName, newName, copyFromName)
	
	-- Get adddon's object:
	local addon = ArenaLive.addons[addonName];
	if ( not addon ) then
		ArenaLive:Message(L["Couldn't create profile for addon %s, because no addon with that name is registered."], "error", addonName);
	end
	
	-- Get addon's data base:
	local database = addon.database;
	if ( not database ) then
		ArenaLive:Message(L["Couldn't create profile for addon %s, because the addon's database wasn't found."], "error", addonName);
	elseif ( database[newName] ) then
		ArenaLive:Message(L["Couldn't create profile for addon %s, because a profile with the name %s already exists."], "error", addonName, newName);
		return;
	end
	
	-- Create a new table for the newProfile:
	database[newName] = {};
	
	-- Add new profile to addon's list of profiles:
	database.Profiles[newName] = true;
	
	if ( copyFromName and database[copyFromName] ) then
		Profiles:CopyProfile(addonName, copyFromName, newName);
	else -- Copy values from defaults:
		Profiles:CopyProfile(addonName, "default", newName);
	end
	
end

function Profiles:DeleteProfile (addonName, profileName)
		
	-- Get adddon's object:
	local addon = ArenaLive.addons[addonName];
	if ( not addon ) then
		ArenaLive:Message(L["Couldn't delete profile for addon %s, because no addon with that name is registered."], "error", addonName);
	end
	
	-- Get addon's data base:
	local database = addon.database;
	if ( not database ) then
		ArenaLive:Message(L["Couldn't delete profile for addon %s, because the addon's database wasn't found."], "error", addonName);
	end
	
	-- Prevent deleting default profile:
	if ( profileName == "default" ) then
		return;
	end	
	
	database[profileName] = nil;
	database.Profiles[profileName] = nil;
	
	-- Set profile to default for all characters that currently use the deleted profile:
	for character, profile in pairs(database.CharacterToProfile) do
		if ( profile == profileName ) then
			database.CharacterToProfile[character] = "default";
		end
	end
	
	-- If the deleted profile is the currently active, change it to the default profile:
	if ( profileName == database.ActiveProfile ) then
		Profiles:SetActiveProfile (addonName, "default");
	end
	
end

function Profiles:CopyProfile (addonName, fromProfile, toProfile)
	
	ArenaLive:CheckArgs(addonName, "string", fromProfile, "string", toProfile, "string");
	
	
	-- Get adddon's object:
	local addon = ArenaLive.addons[addonName];
	if ( not addon ) then
		ArenaLive:Message(L["Couldn't copy profile for addon %s, because no addon with that name is registered."], "error", addonName);
	end
	
	-- Get addon's data base:
	local database = addon.database;
	
	-- Do some checks for stuff that could prevent us from copying a profile:
	if ( not database ) then
		ArenaLive:Message(L["Couldn't copy profile for addon %s, because the addon's database wasn't found."], "error", addonName);
	elseif ( not ArenaLive:DBHasProfiles(addonName) ) then
		ArenaLive:Message(L["Couldn't copy profile for addon %s, because the addon does not support profiles."], "error", addonName);
	elseif ( not database[fromProfile] or not database[toProfile] ) then
		ArenaLive:Message(L["Couldn't copy profile for addon %s, because either the profile to copy from (%s) or the target profile (%s) doesn't exist."], "error", addonName, fromProfile, toProfile);
	end
	
	
	local from = database[fromProfile];
	local to = database[toProfile];
	
	-- Wipe the to table, so all options are exactly the same as in the from frame:
	table.wipe(to);
	
	-- Update all values according to the from profile:
	copyTable(from, to);

	-- Trigger a custom event. Addon's can register for it in order to update their display etc. according to the new profile:
	if ( database.ActiveProfile == toProfile ) then
		ArenaLive:TriggerEvent("ARENALIVE_ACTIVE_PROFILE_CHANGED", addonName, toProfile);
	end
end

function Profiles:GetActiveProfile(addonName)
	local addon = ArenaLive.addons[addonName];
	if ( not addon ) then
		ArenaLive:Message(L["Couldn't get profile for addon %s, because no addon with that name is registered."], "error", addonName);
	end

	-- Get addon's data base:
	local database = addon.database;

	-- Do some checks for stuff that could prevent us from copying a profile:
	if ( not database ) then
		ArenaLive:Message(L["Couldn't get profile for addon %s, because the addon's database wasn't found."], "error", addonName);
	elseif ( not ArenaLive:DBHasProfiles(addonName) ) then
		ArenaLive:Message(L["Couldn't get profile for addon %s, because the addon does not support profiles."], "error", addonName);
	end	
	
	return database.ActiveProfile;
end

function Profiles:SetActiveProfile (addonName, newActive)

	-- Get addon's object:
	local addon = ArenaLive.addons[addonName];
	if ( not addon ) then
		ArenaLive:Message(L["Couldn't copy profile for addon %s, because no addon with that name is registered."], "error", addonName);
	end

	-- Get addon's data base:
	local database = addon.database;	
	
	-- Do some checks for stuff that could prevent us from copying a profile:
	if ( not database ) then
		ArenaLive:Message(L["Couldn't set active profile for addon %s, because the addon's database wasn't found."], "error", addonName);
	elseif ( not ArenaLive:DBHasProfiles(addonName) ) then
		ArenaLive:Message(L["Couldn't set active profile for addon %s, because the addon does not support profiles."], "error", addonName);
	elseif ( not database[newActive] ) then
		ArenaLive:Message(L["Couldn't set active profile for addon %s, because there is no profile with the name %s."], "error", addonName, newActive);
	end	
	
	-- Set the new active profile:
	database.ActiveProfile = newActive;
	
	-- Also update the CharacterToProfile table accordingly for the current character:
	local name, realm;
	name = UnitName("player");
	realm = GetRealmName();
	name = name.."-"..realm;	
	database.CharacterToProfile[name] = newActive;
	
	-- Trigger event for profile change:
	ArenaLive:TriggerEvent("ARENALIVE_ACTIVE_PROFILE_CHANGED", addonName, newActive);
end


-- We can't use our predefined option dropdowns for this one, so create special functions:
local function CreateProfileDropDown(addonName, frameData)
	local frame = CreateFrame("Button", frameData.name, _G[frameData.parent], "ArenaLive_OptionsDropDownTemplate");
	frame.addon = addonName;
	
	-- Set width if necessary:
	if ( frameData.width ) then
		UIDropDownMenu_SetWidth(frame, frameData.width, frameData.padding);
	end
	
	-- Set Point:
	local point, relativePoint, relativeTo, xOffset, yOffset;
	point = frameData.point or "TOPLEFT";
	relativePoint = frameData.relativePoint or point;
	relativeTo = frameData.relativeTo or frameData.parent;
	xOffset = frameData.xOffset or 0;
	yOffset = frameData.yOffset or 0;
	frame:SetPoint(point, relativeTo, relativePoint, xOffset, yOffset);
	
	ArenaLive:AddCustomOptionFrame(frame);
	return frame;
end

local info = {};
local function ActiveProfileDropDown_OnClick(button)
	local dropDown = UIDROPDOWNMENU_OPEN_MENU;
	UIDropDownMenu_SetText(dropDown, button:GetText());
	Profiles:SetActiveProfile(dropDown.addon, button.value);
end

local function ActiveProfileDropDown_Refresh(dropDown, level, menuList)
	if ( not dropDown.addon or not ArenaLive:DBHasProfiles(dropDown.addon) ) then
		return;
	end
	
	local addon = ArenaLive.addons[dropDown.addon];
	local database = addon.database;

	for name in pairs(database.Profiles) do
		info.text = name;
		info.value = name;
		if ( name == database.ActiveProfile ) then
			info.checked = true;
		else
			info.checked = false;
		end
		info.func = ActiveProfileDropDown_OnClick;
		UIDropDownMenu_AddButton(info, level);
	end
end

function Profiles:ConstructActiveProfileDropDown(addonName, frameData)
	
	ArenaLive:CheckArgs(addonName, "string", frameData, "table");
	
	local addon = ArenaLive.addons[addonName];
	local database = addon.database;
	local frame = CreateProfileDropDown(addonName, frameData);
	
	-- Set Title:
	frame.title:SetText(L["Active Profile"]);
	UIDropDownMenu_SetText(frame, database.ActiveProfile);
	
	-- Initialise the dropdown using blizzard's standard functionset.
	UIDropDownMenu_Initialize(frame, ActiveProfileDropDown_Refresh);
	
	return frame;
end

local function CopyProfileDropDown_OnClick(button)
	local dropDown = UIDROPDOWNMENU_OPEN_MENU;
	local addon = ArenaLive.addons[dropDown.addon];
	local database = addon.database;	
	Profiles:CopyProfile(dropDown.addon, button.value, database.ActiveProfile);
end

local function CopyProfileDropDown_Refresh(dropDown, level, menuList)
	if ( not dropDown.addon or not ArenaLive:DBHasProfiles(dropDown.addon) ) then
		return;
	end
	
	local addon = ArenaLive.addons[dropDown.addon];
	local database = addon.database;

	for name in pairs(database.Profiles) do
		if ( name ~= database.ActiveProfile ) then
			info.text = name;
			info.value = name;
			info.checked = false;
			info.func = CopyProfileDropDown_OnClick;
			UIDropDownMenu_AddButton(info, level);
		end
	end
end

function Profiles:ConstructCopyProfileDropDown(addonName, frameData)
	
	ArenaLive:CheckArgs(addonName, "string", frameData, "table");
	
	local addon = ArenaLive.addons[addonName];
	local database = addon.database;
	local frame = CreateProfileDropDown(addonName, frameData);
	
	-- Set Title:
	frame.title:SetText(L["Copy Profile"]);
	UIDropDownMenu_SetText(frame, "");
	
	-- Initialise the dropdown using blizzard's standard functionset.
	UIDropDownMenu_Initialize(frame, CopyProfileDropDown_Refresh);
	
	return frame;
end

local function ConstructCreateNewProfileButton_OnClick(self, button, down)
	if ( button == "LeftButton" ) then
		local parent = self:GetParent();
		if ( not parent.addon ) then
			return;
		end
		
		local profileName = parent.editBox:GetText();
		if ( profileName and profileName ~= "" ) then
			parent.editBox:ClearFocus();
			parent.editBox:SetText("");
			
			local addon = ArenaLive.addons[parent.addon];
			local database = addon.database;

			if ( database.Profiles[profileName] ) then
				ArenaLive:Message(L["Couldn't create new profile named %s, because there already is a profile with that name for the addon %s."], "error", profileName, parent.addon);
				return;
			end
			
			Profiles:CreateProfile(parent.addon, profileName);
		end
	end
end

local function Enable(frame)
	frame.editBox:Enable();
	frame.button:Enable();
	frame.enabled = true;
end

local function Disable(frame)
	frame.editBox:Disable();
	frame.button:Disable();
	frame.enabled = false;
end

local function IsEnabled(frame)
	return frame.enabled;
end

function Profiles:ConstructCreateNewProfileFrame(addonName, frameData)
	ArenaLive:CheckArgs(addonName, "string", frameData, "table", frameData.name, "string");
	
	local frame = CreateFrame("Frame", frameData.name, _G[frameData.parent], "ArenaLive_CreateProfileFrameTemplate");
	frame.addon = addonName;
	
	-- Set child references:
	frame.editBox = _G[frameData.name.."EditBox"];
	frame.button = _G[frameData.name.."Button"];
	
	-- Enable and disable functions for combatlockdown:
	frame.Enable = Enable;
	frame.IsEnabled = IsEnabled;
	frame.Disable = Disable;
	
	-- Set Point:
	local point, relativePoint, relativeTo, xOffset, yOffset;
	point = frameData.point or "TOPLEFT";
	relativePoint = frameData.relativePoint or point;
	relativeTo = frameData.relativeTo or frameData.parent;
	xOffset = frameData.xOffset or 0;
	yOffset = frameData.yOffset or 0;
	frame:SetPoint(point, relativeTo, relativePoint, xOffset, yOffset);
	
	frame.editBox.title:SetText(L["New Profile Name:"]);
	frame.button:SetText(L["Create Profile"]);
	frame.button:SetScript("OnClick", ConstructCreateNewProfileButton_OnClick);
	ArenaLive:AddCustomOptionFrame(frame);
	return frame;
end