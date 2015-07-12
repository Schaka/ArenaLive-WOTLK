local addonName = ...;
local L = ArenaLiveUnitFrames.L;

local prefix = "ALUF_ProfileOptions";
local optionFrames;
local Profiles = ArenaLive:GetHandler("Profiles");

function ALUF_ProfileOptions:Initialise()
	ALUF_ProfileOptionsTitle:SetText(L["ArenaLive [UnitFrames] Profile Options:"]);
	ALUF_ProfileOptions.name = L["Profiles"];
	ALUF_ProfileOptions.parent = L["ArenaLive [UnitFrames]"];
	InterfaceOptions_AddCategory(ALUF_ProfileOptions);
	
	Profiles:ConstructActiveProfileDropDown(addonName, optionFrames["ActiveProfile"]);
	Profiles:ConstructCopyProfileDropDown(addonName, optionFrames["CopyProfile"]);
	Profiles:ConstructCreateNewProfileFrame(addonName, optionFrames["CreateProfile"]);
	ArenaLive:ConstructOptionFrame(optionFrames["DeleteActiveProfile"], addonName);
end

function ALUF_ProfileOptions:ToggleDeleteProfileButton()
	if ( ArenaLiveUnitFrames.database.ActiveProfile == "default" ) then
		ALUF_ProfileOptionsDeleteActiveProfile:Disable();
	else
		ALUF_ProfileOptionsDeleteActiveProfile:Enable();
	end
end

optionFrames = {
	["ActiveProfile"] = {
		["name"] = prefix.."ActiveProfile",
		["parent"] = prefix,
		["point"] = "TOPLEFT",
		["relativeTo"] = prefix.."Title",
		["relativePoint"] = "BOTTOMLEFT",
		["xOffset"] = -10,
		["yOffset"] = -25,
		["width"] = 250,
	},
	["CopyProfile"] = {
		["name"] = prefix.."CopyProfile",
		["parent"] = prefix,
		["point"] = "TOPLEFT",
		["relativeTo"] = prefix.."ActiveProfile",
		["relativePoint"] = "TOPRIGHT",
		["xOffset"] = 0,
		["yOffset"] = 0,
		["width"] = 250,
	},
	["CreateProfile"] = {
		["name"] = prefix.."CreateProfile",
		["parent"] = prefix,
		["point"] = "TOPLEFT",
		["relativeTo"] = prefix.."ActiveProfile",
		["relativePoint"] = "BOTTOMLEFT",
		["xOffset"] = 20,
		["yOffset"] = -25,
	},
	["DeleteActiveProfile"] = {
		["name"] = prefix.."DeleteActiveProfile",
		["parent"] = prefix,
		["point"] = "TOPLEFT",
		["relativeTo"] = prefix.."CreateProfile",
		["relativePoint"] = "BOTTOMLEFT",
		["xOffset"] = 0,
		["yOffset"] = -25,
		["type"] = "Button",
		["title"] = L["Delete Active Profile"],
		["func"] = function(frame) local profileName = Profiles:GetActiveProfile(addonName); Profiles:DeleteProfile(addonName, profileName); UIDropDownMenu_SetText(ALUF_ProfileOptionsActiveProfile, Profiles:GetActiveProfile(addonName)); end
	},
};