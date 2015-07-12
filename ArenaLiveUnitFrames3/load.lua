local addonName, addon = ...;
ArenaLiveUnitFrames = addon;
local L = ArenaLiveUnitFrames.L;

-- Popups:
StaticPopupDialogs["ALUF_CONFIRM_RELOADUI"] = {
	text = L["A change makes it necessary to reload the UI in order for the interface to work correctly. Do you wish to reload the interface now?"],
	button1 = YES,
	button2 = NO,
	OnAccept = function (self) ReloadUI(); end,
	OnCancel = function (self) end,
	hideOnEscape = 1,
	timeout = 0,
	exclusive = 1,
	whileDead = 1,
	preferredIndex = STATICPOPUP_NUMDIALOGS, -- Avoid some UI taint.
}

ArenaLiveUnitFrames.defaults = {
	["CharacterToProfile"] = {
	},
	["ActiveProfile"] = "default",
	["Profiles"] = 
	{
		["default"] = true,
	},
	["default"] = {
		["Version"] = "3.2.0b";
		["FrameMover"] = {
			["FrameLock"] = false,
		},
		["PlayerFrame"] = {
				["Border"] = {
					["Enabled"] = true,
					["Red"] = 1,
					["Green"] = 1,
					["Blue"] = 1,
				},
				["UnitFrame"] = {
					["Enabled"] = true,
					["TooltipMode"] = "Always",
					["Scale"] = 1,
				},
				["HealthBar"] = {
					["ColourMode"] = "class",
					["ShowHealPrediction"] = true,
					["ShowAbsorb"] = true,
				},
				["HealthBarText"] = {
					["BarText"] = "%CURR%/%MAX%",
					["FontObject"] = "ArenaLiveFont_StatusBarText",
					["ShowDeadOrGhost"] = true,
					["ShowDisconnect"] = true,
				},
				["PowerBar"] = {
				},
				["PowerBarText"] = {
					["BarText"] = "%CURR%/%MAX%",
					["FontObject"] = "ArenaLiveFont_StatusBarText",
				},
				["Icon"] = {
					[1] = {
						["Type"] = "trinket",
						["FallBackType"] = "racial",
					},
					[2] = {
						["Type"] = "interrupt",
						["FallBackType"] = "dispel",
					},
				},
				["Portrait"] = {
					["Type"] = "threeD",
				},
				["NameText"] = {
					["ColourMode"] = "reaction",
					["FontObject"] = "ArenaLiveFont_Name",
				},
				["CCIndicator"] = {
					["Enabled"] = true,
				},
				["CastBar"] = {
					["Enabled"] = true,
					["Position"] = 
					{
						["Position"] = "BELOW",
						["AttachedTo"] = "Aura",
						["XOffset"] = 21,
						["YOffset"] = -5,
					},
				},
				["DRTracker"] = {
					["Enabled"] = true,
					["IconSize"] = 21,
					["GrowDirection"] = "RIGHT",
					["MaxShownIcons"] = 6,
					["Position"] = 
					{
						["Position"] = "BELOW",
						["AttachedTo"] = "CastHistory",
						["XOffset"] = 0,
						["YOffset"] = -5,
					},
				},
				["Aura"] = {
					["Enabled"] = true,
					["MaxShownBuffs"] = 40,
					["MaxShownDebuffs"] = 40,
					["AurasPerRow"] = 7,
					["NormalIconSize"] = 21,
					["LargeIconSize"] = 25,
					["GrowRTL"] = false,
					["GrowUpwards"] = false,
					["ShowOnlyPlayerDebuffs"] = false,
					["OnlyShowRaidBuffs"] = false,
					["OnlyShowDispellableDebuffs"] = false,
					["SpectatorFilter"] = false,
					["Position"] = 
					{
						["Position"] = "BELOW",
						["AttachedTo"] = "UnitFrame",
						["XOffset"] = 32,
						["YOffset"] = -5,
					},
				},
				["StatusIcon"] = {
					["Size"] = 16,
				},
				["LeaderIcon"] = {
					["Size"] = 16,
				},
				["MasterLooterIcon"] = {
					["Size"] = 16,
				},
				["RoleIcon"] = {
					["Size"] = 16,
				},
				["PvPIcon"] = {
					["Size"] = 48,
				},
		},
		["PetFrame"] = {
			["Border"] = {
				["Enabled"] = true,
				["Red"] = 1,
				["Green"] = 1,
				["Blue"] = 1,
			},
			["UnitFrame"] = {
				["Enabled"] = true,
				["TooltipMode"] = "Always",
				["Scale"] = 1,
			},
			["NameText"] = {
				["ColourMode"] = "reaction",
				["FontObject"] = "ArenaLiveFont_NameSmall",
			},
			["Portrait"] = {
				["Type"] = "threeD",
			},
			["CCIndicator"] = {
				["Enabled"] = true,
			},
			["HealthBar"] = {
				["ColourMode"] = "none",
				["ShowHealPrediction"] = true,
				["ShowAbsorb"] = true,
			},
			["HealthBarText"] = {
				["BarText"] = "%CURR%/%MAX%",
				["FontObject"] = "ArenaLiveFont_StatusBarTextSmall",
				["ShowDeadOrGhost"] = true,
				["ShowDisconnect"] = true,
			},
			["PowerBar"] = {
			},
			["PowerBarText"] = {
				["BarText"] = "%CURR%/%MAX%",
				["FontObject"] = "ArenaLiveFont_StatusBarTextSmall",
			},
			["Aura"] = {
				["Enabled"] = true,
				["MaxShownBuffs"] = 40,
				["MaxShownDebuffs"] = 40,
				["AurasPerRow"] = 7,
				["NormalIconSize"] = 21,
				["LargeIconSize"] = 25,
				["GrowRTL"] = false,
				["GrowUpwards"] = false,
				["ShowOnlyPlayerDebuffs"] = false,
				["OnlyShowRaidBuffs"] = false,
				["OnlyShowDispellableDebuffs"] = false,
				["SpectatorFilter"] = false,
				["Position"] = 
				{
					["Position"] = "BELOW",
					["AttachedTo"] = "UnitFrame",
					["XOffset"] = 0,
					["YOffset"] = -2,
				},
			},
		},
		["TargetFrame"] = {
				["Border"] = {
					["Enabled"] = true,
					["Red"] = 1,
					["Green"] = 1,
					["Blue"] = 1,
				},
				["UnitFrame"] = {
					["Enabled"] = true,
					["TooltipMode"] = "Always",
					["Scale"] = 1,
				},
				["HealthBar"] = {
					["ColourMode"] = "class",
					["ShowHealPrediction"] = true,
					["ShowAbsorb"] = true,
				},
				["HealthBarText"] = {
					["BarText"] = "%CURR%/%MAX%",
					["FontObject"] = "ArenaLiveFont_StatusBarText",
					["ShowDeadOrGhost"] = true,
					["ShowDisconnect"] = true,
				},
				["PowerBar"] = {
				},
				["PowerBarText"] = {
					["BarText"] = "%CURR%/%MAX%",
					["FontObject"] = "ArenaLiveFont_StatusBarText",
				},
				["Icon"] = {
					[1] = {
						["Type"] = "trinket",
						["FallBackType"] = "racial",
					},
					[2] = {
						["Type"] = "interrupt",
						["FallBackType"] = "dispel",
					},
				},
				["Portrait"] = {
					["Type"] = "threeD",
				},
				["NameText"] = {
					["ColourMode"] = "reaction",
					["FontObject"] = "ArenaLiveFont_Name",
				},
				["CCIndicator"] = {
					["Enabled"] = true,
				},
				["CastBar"] = {
					["Enabled"] = true,
					["Position"] = 
					{
						["Position"] = "BELOW",
						["AttachedTo"] = "Aura",
						["XOffset"] = 5,
						["YOffset"] = -5,
					},
				},
				["CastHistory"] = {
					["Enabled"] = true,
					["Size"] = 21,
					["Direction"] = "LEFT",
					["IconDuration"] = 7,
					["MaxIcons"] = 6,
					["Position"] = 
					{
						["Position"] = "BELOW",
						["AttachedTo"] = "CastBar",
						["XOffset"] = 28,
						["YOffset"] = -5,
					},
				},
				["DRTracker"] = {
					["Enabled"] = true,
					["IconSize"] = 21,
					["GrowDirection"] = "LEFT",
					["MaxShownIcons"] = 6,
					["Position"] = 
					{
						["Position"] = "BELOW",
						["AttachedTo"] = "CastHistory",
						["XOffset"] = 0,
						["YOffset"] = -5,
					},
				},
				["Aura"] = {
					["Enabled"] = true,
					["MaxShownBuffs"] = 40,
					["MaxShownDebuffs"] = 40,
					["AurasPerRow"] = 7,
					["NormalIconSize"] = 21,
					["LargeIconSize"] = 25,
					["GrowRTL"] = false,
					["GrowUpwards"] = false,
					["ShowOnlyPlayerDebuffs"] = false,
					["OnlyShowRaidBuffs"] = false,
					["OnlyShowDispellableDebuffs"] = false,
					["SpectatorFilter"] = false,
					["Position"] = 
					{
						["Position"] = "BELOW",
						["AttachedTo"] = "UnitFrame",
						["XOffset"] = 0,
						["YOffset"] = -5,
					},
				},
				["StatusIcon"] = {
					["Size"] = 16,
				},
				["LeaderIcon"] = {
					["Size"] = 16,
				},
				["RaidIcon"] = {
					["Size"] = 16,
				},
				["PetBattleIcon"] = {
					["Size"] = 32,
				},
				["QuestIcon"] = {
					["Size"] = 32,
				},
				["PvPIcon"] = {
					["Size"] = 48,
				},
		},
		["TargetTargetFrame"] = {
				["Border"] = {
					["Enabled"] = true,
					["Red"] = 1,
					["Green"] = 1,
					["Blue"] = 1,
				},
				["UnitFrame"] = {
					["Enabled"] = true,
					["TooltipMode"] = "Always",
					["Scale"] = 1,
				},
				["HealthBar"] = {
					["ColourMode"] = "class",
				},
				["PowerBar"] = {
				},
				["Portrait"] = {
					["Type"] = "threeD",
				},
				["NameText"] = {
					["ColourMode"] = "reaction",
					["FontObject"] = "ArenaLiveFont_NameVerySmall",
				},
		},
		["FocusFrame"] = {
				["Border"] = {
					["Enabled"] = true,
					["Red"] = 1,
					["Green"] = 1,
					["Blue"] = 1,
				},
				["UnitFrame"] = {
					["Enabled"] = true,
					["TooltipMode"] = "Always",
					["Scale"] = 1,
				},
				["HealthBar"] = {
					["ColourMode"] = "class",
					["ShowHealPrediction"] = true,
					["ShowAbsorb"] = true,
				},
				["HealthBarText"] = {
					["BarText"] = "%CURR%/%MAX%",
					["FontObject"] = "ArenaLiveFont_StatusBarText",
					["ShowDeadOrGhost"] = true,
					["ShowDisconnect"] = true,
				},
				["PowerBar"] = {
				},
				["PowerBarText"] = {
					["BarText"] = "%CURR%/%MAX%",
					["FontObject"] = "ArenaLiveFont_StatusBarText",
				},
				["Icon"] = {
					[1] = {
						["Type"] = "trinket",
						["FallBackType"] = "racial",
					},
					[2] = {
						["Type"] = "interrupt",
						["FallBackType"] = "dispel",
					},
				},
				["Portrait"] = {
					["Type"] = "threeD",
				},
				["NameText"] = {
					["ColourMode"] = "reaction",
					["FontObject"] = "ArenaLiveFont_Name",
				},
				["CCIndicator"] = {
					["Enabled"] = true,
				},
				["CastBar"] = {
					["Enabled"] = true,
					["Position"] = 
					{
						["Position"] = "BELOW",
						["AttachedTo"] = "Aura",
						["XOffset"] = 5,
						["YOffset"] = -5,
					},
				},
				["CastHistory"] = {
					["Enabled"] = true,
					["Size"] = 21,
					["Direction"] = "LEFT",
					["IconDuration"] = 7,
					["MaxIcons"] = 6,
					["Position"] = 
					{
						["Position"] = "BELOW",
						["AttachedTo"] = "CastBar",
						["XOffset"] = 28,
						["YOffset"] = -5,
					},
				},
				["DRTracker"] = {
					["Enabled"] = true,
					["IconSize"] = 21,
					["GrowDirection"] = "LEFT",
					["MaxShownIcons"] = 6,
					["Position"] = 
					{
						["Position"] = "BELOW",
						["AttachedTo"] = "CastHistory",
						["XOffset"] = 0,
						["YOffset"] = -5,
					},
				},
				["Aura"] = {
					["Enabled"] = true,
					["MaxShownBuffs"] = 40,
					["MaxShownDebuffs"] = 40,
					["AurasPerRow"] = 7,
					["NormalIconSize"] = 21,
					["LargeIconSize"] = 25,
					["GrowRTL"] = false,
					["GrowUpwards"] = false,
					["ShowOnlyPlayerDebuffs"] = false,
					["OnlyShowRaidBuffs"] = false,
					["OnlyShowDispellableDebuffs"] = false,
					["SpectatorFilter"] = false,
					["Position"] = 
					{
						["Position"] = "BELOW",
						["AttachedTo"] = "UnitFrame",
						["XOffset"] = 0,
						["YOffset"] = -5,
					},
				},
				["StatusIcon"] = {
					["Size"] = 16,
				},
				["LeaderIcon"] = {
					["Size"] = 16,
				},
				["RaidIcon"] = {
					["Size"] = 16,
				},
				["PetBattleIcon"] = {
					["Size"] = 32,
				},
				["QuestIcon"] = {
					["Size"] = 32,
				},
				["PvPIcon"] = {
					["Size"] = 48,
				},
		},
		["FocusTargetFrame"] = {
				["Border"] = {
					["Enabled"] = true,
					["Red"] = 1,
					["Green"] = 1,
					["Blue"] = 1,
				},
				["UnitFrame"] = {
					["Enabled"] = true,
					["TooltipMode"] = "Always",
					["Scale"] = 1,
				},
				["HealthBar"] = {
					["ColourMode"] = "class",
				},
				["PowerBar"] = {
				},
				["Portrait"] = {
					["Type"] = "threeD",
				},
				["NameText"] = {
					["ColourMode"] = "reaction",
					["FontObject"] = "ArenaLiveFont_NameVerySmall",
				},
		},
		["PartyFrames"] = {
			["PartyHeader"] = {
				["Enabled"] = true,
				["GrowthDirection"] = "DOWN",
				["SpaceBetweenFrames"] = 50,
				["ShowPlayer"] = false,
				["ShowArena"] = true,
				["ShowRaid"] = false,
			},
			["Border"] = {
				["Enabled"] = true,
				["Red"] = 1,
				["Green"] = 1,
				["Blue"] = 1,
			},
			["UnitFrame"] = {
				["Enabled"] = true,
				["TooltipMode"] = "Always",
				["Scale"] = 1,
			},
			["HealthBar"] = {
				["ColourMode"] = "class",
				["ShowHealPrediction"] = true,
				["ShowAbsorb"] = true,
			},
			["HealthBarText"] = {
				["BarText"] = "%CURR%/%MAX%",
				["FontObject"] = "ArenaLiveFont_StatusBarTextSmall",
				["ShowDeadOrGhost"] = true,
				["ShowDisconnect"] = true,
			},
			["PowerBar"] = {
			},
			["PowerBarText"] = {
				["BarText"] = "%CURR%/%MAX%",
				["FontObject"] = "ArenaLiveFont_StatusBarTextSmall",
			},
			["Icon"] = {
				[1] = {
					["Type"] = "trinket",
					["FallBackType"] = "racial",
				},
				[2] = {
					["Type"] = "interrupt",
					["FallBackType"] = "dispel",
				},
			},
			["Portrait"] = {
				["Type"] = "threeD",
			},
			["NameText"] = {
				["ColourMode"] = "reaction",
				["FontObject"] = "ArenaLiveFont_NameSmall",
			},
			["CCIndicator"] = {
				["Enabled"] = true,
			},
			["CastBar"] = {
				["Enabled"] = true,
				["Position"] = 
				{
					["Position"] = "BELOW",
					["AttachedTo"] = "PetFrame",
					["XOffset"] = 26,
					["YOffset"] = -5,
				},
			},
			["CastHistory"] = {
				["Enabled"] = true,
				["Size"] = 21,
				["Direction"] = "RIGHT",
				["IconDuration"] = 7,
				["MaxIcons"] = 3,
				["Position"] = 
				{
					["Position"] = "BELOW",
					["AttachedTo"] = "CastBar",
					["XOffset"] = -21,
					["YOffset"] = -5,
				},
			},
			["DRTracker"] = {
				["Enabled"] = true,
				["IconSize"] = 32,
				["GrowDirection"] = "LEFT",
				["MaxShownIcons"] = 6,
				["Position"] = 
				{
					["Position"] = "LEFT",
					["AttachedTo"] = "TargetFrame",
					["XOffset"] = -5,
					["YOffset"] = -18,
				},
			},
			["Aura"] = {
				["Enabled"] = true,
				["MaxShownBuffs"] = 6,
				["MaxShownDebuffs"] = 6,
				["AurasPerRow"] = 6,
				["NormalIconSize"] = 21,
				["LargeIconSize"] = 21,
				["GrowRTL"] = false,
				["GrowUpwards"] = false,
				["ShowOnlyPlayerDebuffs"] = false,
				["OnlyShowRaidBuffs"] = false,
				["OnlyShowDispellableDebuffs"] = false,
				["SpectatorFilter"] = false,
				["Position"] = 
				{
					["Position"] = "BELOW",
					["AttachedTo"] = "UnitFrame",
					["XOffset"] = 24,
					["YOffset"] = -5,
				},
			},
			["TargetFrame"] = {
				["Position"] = 
				{
					["Position"] = "LEFT",
					["AttachedTo"] = "UnitFrame",
					["XOffset"] = -5,
					["YOffset"] = -3,
				},
			},
			["PetFrame"] = {
				["Position"] = 
				{
					["Position"] = "RIGHT",
					["AttachedTo"] = "UnitFrame",
					["XOffset"] = 5,
					["YOffset"] = -5,
				},
			},
			["LeaderIcon"] = {
				["Size"] = 16,
			},
			["MasterLooterIcon"] = {
				["Size"] = 16,
			},
			["RoleIcon"] = {
				["Size"] = 16,
			},
			["PvPIcon"] = {
				["Size"] = 32,
			},
		},
		["PartyTargetFrame"] = {
				["Border"] = {
					["Enabled"] = true,
					["Red"] = 1,
					["Green"] = 1,
					["Blue"] = 1,
				},
				["UnitFrame"] = {
					["Enabled"] = true,
					["TooltipMode"] = "Always",
					["Scale"] = 1,
				},
				["HealthBar"] = {
					["ColourMode"] = "class",
				},
				["PowerBar"] = {
				},
				["Portrait"] = {
					["Type"] = "threeD",
				},
				["NameText"] = {
					["ColourMode"] = "reaction",
					["FontObject"] = "ArenaLiveFont_NameVerySmall",
				},
		},
		["PartyPetFrame"] = {
				["Border"] = {
					["Enabled"] = true,
					["Red"] = 1,
					["Green"] = 1,
					["Blue"] = 1,
				},
				["UnitFrame"] = {
					["Enabled"] = true,
					["TooltipMode"] = "Always",
					["Scale"] = 1,
				},
				["HealthBar"] = {
					["ColourMode"] = "none",
				},
				["HealthBarText"] = {
					["BarText"] = "%PERCENT_SHORT%%",
					["FontObject"] = "ArenaLiveFont_StatusBarTextSmall",
					["ShowDeadOrGhost"] = true,
					["ShowDisconnect"] = true,
				},
				["Portrait"] = {
					["Type"] = "threeD",
				},
				["NameText"] = {
					["ColourMode"] = "reaction",
					["FontObject"] = "ArenaLiveFont_NameVerySmall",
				},
		},
		["ArenaEnemyFrames"] = {
			["ArenaHeader"] = {
				["Enabled"] = true,
				["GrowthDirection"] = "DOWN",
				["SpaceBetweenFrames"] = 42,
			},
			["UnitFrame"] = {
				["Enabled"] = true,
				["TooltipMode"] = "Always",
				["Scale"] = 1,
			},
			["Border"] = {
				["Enabled"] = true,
				["Red"] = 1,
				["Green"] = 1,
					["Blue"] = 1,
			},
			["HealthBar"] = {
				["ColourMode"] = "class",
				["ShowHealPrediction"] = true,
				["ShowAbsorb"] = true,
			},
			["HealthBarText"] = {
				["BarText"] = "%CURR%/%MAX%",
				["FontObject"] = "ArenaLiveFont_StatusBarTextSmall",
				["ShowDeadOrGhost"] = true,
				["ShowDisconnect"] = true,
			},
			["PowerBar"] = {
			},
			["PowerBarText"] = {
				["BarText"] = "%CURR%/%MAX%",
				["FontObject"] = "ArenaLiveFont_StatusBarTextSmall",
			},
			["Icon"] = {
				[1] = {
					["Type"] = "trinket",
					["FallBackType"] = "racial",
				},
				[2] = {
					["Type"] = "interrupt",
					["FallBackType"] = "dispel",
				},
				[3] = {
					["Type"] = "specialisation",
				},
			},
			["Portrait"] = {
				["Type"] = "class",
			},
			["NameText"] = {
				["ColourMode"] = "reaction",
				["FontObject"] = "ArenaLiveFont_NameSmall",
			},
			["CCIndicator"] = {
				["Enabled"] = true,
			},
			["CastBar"] = {
				["Enabled"] = true,
				["Position"] = 
				{
					["Position"] = "LEFT",
					["AttachedTo"] = "UnitFrame",
					["XOffset"] = -32,
					["YOffset"] = -12,
				},
			},
			["CastHistory"] = {
				["Enabled"] = true,
				["Size"] = 21,
				["Direction"] = "LEFT",
				["IconDuration"] = 7,
				["MaxIcons"] = 3,
				["Position"] = 
				{
					["Position"] = "BELOW",
					["AttachedTo"] = "CastBar",
					["XOffset"] = 24,
					["YOffset"] = -5,
				},
			},
			["DRTracker"] = {
				["Enabled"] = true,
				["IconSize"] = 32,
				["GrowDirection"] = "RIGHT",
				["MaxShownIcons"] = 6,
				["Position"] = 
				{
					["Position"] = "RIGHT",
					["AttachedTo"] = "UnitFrame",
					["XOffset"] = 5,
					["YOffset"] = -18,
				},
			},
		},
		["Cooldown"] =	{
			["ShowText"] = true,
			["StaticSize"] = false,
			["TextSize"] = 24,
		},
		["CCIndicator"] =	{
			["Priorities"] = {
				["defCD"] = 8,
				["offCD"] = 3,
				["stun"] = 7,
				["silence"] = 6,
				["crowdControl"] = 5,
				["root"] = 4,
				--["disarm"] = 4, Disarms were removed in WoD.
				["usefulBuffs"] = 2,
				["usefulDebuffs"] = 1,
			},
		},
		["HideBlizzCastBar"] = true,
	},
};

ArenaLiveUnitFrames.frameGroups = {
	["PlayerFrame"] = L["Player Frame"],
	["TargetFrame"] = L["Target Frame"],
	["TargetTargetFrame"] = L["Target's Target Frame"],
	["FocusFrame"] = L["Focus Frame"],
	["FocusTargetFrame"] = L["Focus' Target Frame"],
	["PartyFrames"] = L["Party Frames"],
	["ArenaEnemyFrames"] = L["Arena Enemy Frames"],
	["PetFrame"] = L["Pet Frame"],
};

ArenaLiveUnitFrames.frames = {
	["ALUF_PlayerFrame"] = L["Player Frame"],
	["ALUF_TargetFrame"] = L["Target Frame"],
	["ALUF_TargetTargetFrame"] = L["Target's Target Frame"],
	["ALUF_FocusFrame"] = L["Focus Frame"],
	["ALUF_FocusTargetFrame"] = L["Focus' Target Frame"],
	["ALUF_PartyFrames"] = L["Party Frames"],
	["ALUF_ArenaEnemyFrames"] = L["Arena Enemy Frames"],
	["ALUF_PetFrame"] = L["Pet Frame"],
	
};

ArenaLiveUnitFrames.frameGroupToFrame = {
	["PlayerFrame"] = "ALUF_PlayerFrame",
	["TargetFrame"] = "ALUF_TargetFrame",
	["FocusFrame"] = "ALUF_FocusFrame",
	["TargetTargetFrame"] = "ALUF_TargetTargetFrame",
	["FocusTargetFrame"] = "ALUF_FocusTargetFrame",
	["PartyFrames"] = "ALUF_PartyFrames",
	["ArenaEnemyFrames"] = "ALUF_ArenaEnemyFrames",
	["PetFrame"] = "ALUF_PetFrame",
};


do
	ArenaLive:ConstructAddon(ArenaLiveUnitFrames, addonName, true, ArenaLiveUnitFrames.defaults, true, "ALUF_Database");
	ArenaLiveUnitFrames:RegisterEvent("ADDON_LOADED");
	ArenaLiveUnitFrames:RegisterEvent("ARENALIVE_ACTIVE_PROFILE_CHANGED");
end

function ArenaLiveUnitFrames:ToggleTestMode()
	local database = ArenaLive:GetDBComponent(addonName, "FrameMover");
	for frameName in pairs (ArenaLiveUnitFrames.frames) do
		local frame = _G[frameName];
		if ( database.FrameLock ) then
			frame:TestMode(false);
		else
			frame:TestMode(true);
		end
	end
end

function ArenaLiveUnitFrames:ToggleBlizzCastBar()
	local database = ArenaLive:GetDBComponent(addonName);
	if ( database.HideBlizzCastBar ) then
		CastingBarFrame:UnregisterAllEvents();
		CastingBarFrame:Hide();
	else
		-- Only touch CastingBarFrame if it was disabled ArenaLive before:
		if (not CastingBarFrame:IsEventRegistered("PLAYER_ENTERING_WORLD") ) then
			local onLoad = CastingBarFrame:GetScript("OnLoad");
			onLoad(CastingBarFrame);
		end
	end
end

local Border = ArenaLive:GetHandler("Border");
function ArenaLiveUnitFrames:UpdateFrameBorders(frame)

	if ( frame.Border ) then
		local database = ArenaLive:GetDBComponent(frame.addon, "Border", frame.group);
		local border, prefix;
		local enabled = database.Enabled;
		local red, green, blue = database.Red, database.Green, database.Blue;
		if ( frame.CastBar ) then	
			prefix = frame.CastBar:GetName();
			border = _G[prefix.."Border"];			
			if ( border ) then
				if ( enabled ) then
					border:Show();
					border:SetVertexColor(red,green, blue, 1);
				else
					border:Hide();
				end
			end
			
		end
					
		if ( frame.PetFrame ) then
			border = frame.PetFrame.Border;
			if ( border ) then
				database = ArenaLive:GetDBComponent(frame.PetFrame.addon, "Border", frame.PetFrame.group);
				database.Enabled, database.Red, database.Green, database.Blue = enabled, red, green, blue;
				frame.PetFrame:ToggleHandler(Border.name);
				Border:Update(frame.PetFrame);
			end
			
		end
					
		if ( frame.TargetFrame ) then
			border = frame.TargetFrame.Border;			
			if ( border ) then
				database = ArenaLive:GetDBComponent(frame.TargetFrame.addon, "Border", frame.TargetFrame.group);
				database.Enabled, database.Red, database.Green, database.Blue = enabled, red, green, blue;
				frame.TargetFrame:ToggleHandler(Border.name);
				Border:Update(frame.TargetFrame);
			end	
		end		
	end
end

function ArenaLiveUnitFrames:UpdateCastBarDisplay(unitFrame)
	local castBar = unitFrame.CastBar;
	local database = ArenaLive:GetDBComponent(unitFrame.addon, "CastBar", unitFrame.group);
	if ( castBar and database ) then
		local left, right, top, bottom;
		local glowLeft, glowRight, glowTop, glowBottom;
		local point, relativeTo, relativePoint, xOffset, yOffset;
		local glowPoint, glowRelativeTo, glowRelativePoint, glowXOffset, glowYOffset;
		
		if ( database.LongCastBar ) then
			left, right, top, bottom = 0.16015625, 0.84375, 0.15625, 0.9375;
			glowLeft, glowRight, glowTop, glowBottom = 0.140625, 0.85546875,  0, 1;
			
			castBar:SetSize(149, 18);
			castBar.icon:SetSize(18, 18);
			
			castBar.border:SetSize(175, 25);
			castBar.border:SetTexture("Interface\\AddOns\\ArenaLiveUnitFrames3\\Textures\\CastBarSmallLong");
			castBar.border:ClearAllPoints();
			point, relativeTo, relativePoint, xOffset, yOffset = "TOPLEFT", castBar, "TOPLEFT", -21, 2;
			
			castBar.shield:SetSize(183, 32);
			castBar.shield:SetTexture("Interface\\AddOns\\ArenaLiveUnitFrames3\\Textures\\CastBarSmallLongShieldGlow");
			castBar.shield:ClearAllPoints();
			glowPoint, glowRelativeTo, glowRelativePoint, glowXOffset, glowYOffset = "TOPLEFT", castBar, "TOPLEFT", -25, 6;
		else
			left, right, top, bottom = 0.0859375, 0.90625, 0.03125, 0.9375;
			glowLeft, glowRight, glowTop, glowBottom = 0.0625, 0.9375, 0.21875, 0.78125;
		
			castBar:SetSize(74, 24);
			castBar.icon:SetSize(25, 25);
			
			castBar.border:SetSize(105, 29);
			castBar.border:SetTexture("Interface\\AddOns\\ArenaLiveUnitFrames3\\Textures\\CastBarShort");
			castBar.border:ClearAllPoints();
			point, relativeTo, relativePoint, xOffset, yOffset = "TOPLEFT", castBar, "TOPLEFT", -26, 2;
			
			castBar.shield:SetSize(112, 36);
			castBar.shield:SetTexture("Interface\\AddOns\\ArenaLiveUnitFrames3\\Textures\\CastBarShortShieldedGlow");
			castBar.shield:ClearAllPoints();
			glowPoint, glowRelativeTo, glowRelativePoint, glowXOffset, glowYOffset = "TOPLEFT", castBar, "TOPLEFT", -30, 6;
		end
		
		if ( unitFrame.group == "ArenaEnemyFrames" ) then
			local temp = left
			left = right;
			right = temp;
			temp = glowLeft;
			glowLeft = glowRight;
			glowRight = temp;
			
			point = "TOPRIGHT";
			relativePoint = "TOPRIGHT";
			xOffset = -xOffset;
			
			glowPoint = "TOPRIGHT";
			glowRelativePoint = "TOPRIGHT";
			glowXOffset = -glowXOffset;
		end
		
		castBar.border:SetTexCoord(left, right, top, bottom);
		castBar.border:SetPoint(point, relativeTo, relativePoint, xOffset, yOffset);

		castBar.border:Show();
		castBar.shield:SetTexCoord(glowLeft, glowRight, glowTop, glowBottom);
		castBar.shield:SetPoint(glowPoint, glowRelativeTo, glowRelativePoint, glowXOffset, glowYOffset);
	end
end

-- Small recursive function to copy a table:
local function copyTable(base, target)
	
	ArenaLive:CheckArgs(base, "table", target, "table");
	
	for key, value in pairs(base) do
		if ( type(value) == "table" ) then
			target[key] = {};
			copyTable(value, target[key]);
		else
			target[key] = value;
		end
	end
end

local FrameMover = ArenaLive:GetHandler("FrameMover");
function ArenaLiveUnitFrames:OnEvent(event, ...)
	local arg1 = ...;

	if ( event == "ADDON_LOADED" and arg1 == addonName ) then	
	
		-- Initalise frames:
		ALUF_PlayerFrame:Initialise();
		FrameMover:AddFrame(ALUF_PlayerFrame);
		ALUF_PetFrame:Initialise();
		FrameMover:AddFrame(ALUF_PetFrame);
		ALUF_TargetFrame:Initialise();
		FrameMover:AddFrame(ALUF_TargetFrame);
		ALUF_FocusFrame:Initialise();
		FrameMover:AddFrame(ALUF_FocusFrame);
		ALUF_TargetTargetFrame:Initialise();
		FrameMover:AddFrame(ALUF_TargetTargetFrame);
		ALUF_FocusTargetFrame:Initialise();
		FrameMover:AddFrame(ALUF_FocusTargetFrame);
		ALUF_ArenaEnemyFrames:Initialise();
		FrameMover:AddFrame(ALUF_ArenaEnemyFrames);
		ALUF_PartyFrames:Initialise();
		FrameMover:AddFrame(ALUF_PartyFrames);

		-- Set Test mode if frame lock is disabled:
		ArenaLiveUnitFrames:ToggleTestMode();
		
		-- Initialise Options:
		ALUF_Options:Initialise();
		ALUF_UnitFrameOptions:Initialise();
		ALUF_ProfileOptions:Initialise();
		ALUF_ProfileOptions:ToggleDeleteProfileButton();
		
		-- Initial Blizzard cast bar toggle:
		ArenaLiveUnitFrames:ToggleBlizzCastBar();
	elseif ( event == "ARENALIVE_ACTIVE_PROFILE_CHANGED" and arg1 == addonName ) then
	
		-- Update database entries if necessary:
		self:UpdateDB();

		-- Update all settings according to new profile:
		for frameName in pairs(ArenaLiveUnitFrames.frames) do
			local frame = _G[frameName];
			
			local handler;
			if ( frameName == "ArenaEnemyFrames" ) then
				handler = "ArenaHeader";
			else
				handler = "UnitFrame";
			end
			
			local database = ArenaLive:GetDBComponent(addonName, handler, frame.group);
			if ( database.Enabled ) then
				if ( not frame.enabled ) then
					frame:Enable();
				end
			else
				if ( frame.enabled ) then
					frame:Disable();
				end
			end
			
			FrameMover:SetPosition(frame);
			frame:UpdateElementPositions();
			frame:Update();
		end
		
		ALUF_ProfileOptions:ToggleDeleteProfileButton();
		ArenaLiveUnitFrames:ToggleTestMode();
		ArenaLiveUnitFrames:ToggleBlizzCastBar();
	end
end

function ArenaLiveUnitFrames:UpdateDB()
	local database = ArenaLive:GetDBComponent(addonName);
	if ( not database.PetFrame ) then
		database.PetFrame = {};
		copyTable(self.defaults.default.PetFrame, database.PetFrame)
	end
	
	if ( not database.Version ) then
		database.version = nil;		
		
		for frameGroup, frameGroupOptions in pairs(database) do
			if ( type(frameGroupOptions) == "table" ) then
				if ( type(frameGroupOptions.NameText) == "table" ) then
					database[frameGroup].NameText.Size = nil;
					
					if ( frameGroup == "PlayerFrame" or frameGroup == "TargetFrame" or frameGroup == "FocusFrame" ) then
						database[frameGroup].NameText.FontObject = "ArenaLiveFont_Name";
					elseif ( frameGroup == "PetFrame" or frameGroup == "PartyFrames" or frameGroup == "ArenaEnemyFrames" ) then
						database[frameGroup].NameText.FontObject = "ArenaLiveFont_NameSmall";
					elseif ( frameGroup == "TargetTargetFrame" or frameGroup == "FocusTargetFrame" or frameGroup == "PartyTargetFrame" or frameGroup == "PartyPetFrame" ) then
						database[frameGroup].NameText.FontObject = "ArenaLiveFont_NameVerySmall";
					end
				end
				
				if ( type(frameGroupOptions.HealthBarText) == "table" ) then
					database[frameGroup].HealthBarText.BarTextSize = nil;
					
					if ( frameGroup == "PlayerFrame" or frameGroup == "TargetFrame" or frameGroup == "FocusFrame" ) then
						database[frameGroup].HealthBarText.FontObject = "ArenaLiveFont_StatusBarText";
					elseif ( frameGroup == "PetFrame" or frameGroup == "PartyFrames" or frameGroup == "ArenaEnemyFrames" or frameGroup == "PartyPetFrame" ) then
						database[frameGroup].HealthBarText.FontObject = "ArenaLiveFont_StatusBarTextSmall";
					end
				end
				
				if ( type(frameGroupOptions.PowerBarText) == "table" ) then
					database[frameGroup].PowerBarText.BarTextSize = nil;
					
					if ( frameGroup == "PlayerFrame" or frameGroup == "TargetFrame" or frameGroup == "FocusFrame" ) then
						database[frameGroup].PowerBarText.FontObject = "ArenaLiveFont_StatusBarText";
					elseif ( frameGroup == "PetFrame" or frameGroup == "PartyFrames" or frameGroup == "ArenaEnemyFrames" ) then
						database[frameGroup].PowerBarText.FontObject = "ArenaLiveFont_StatusBarTextSmall";
					end
				end
			end
		end
		
		database.Version = "3.0.0b";
	end
	
	if ( database.Version == "3.0.0b" ) then
		
		-- Remove disarm value from database:
		database.CCIndicator.Priorities.disarm = nil;
		
		-- In WoD Diminishin Return groups were reduced to 5,
		-- Update all db entries that have a higher value than that.
		for frameGroup, frameGroupOptions in pairs(database) do
			if ( type(frameGroupOptions) == "table" ) then
				if ( type(frameGroupOptions.DRTracker) == "table" ) then
					if ( frameGroupOptions.DRTracker.MaxShownIcons > 5 ) then
						database[frameGroup].DRTracker.MaxShownIcons = 5;
					end
				end
			end
		end
		
		database.Version = "3.0.1b";
	end
	
	if ( database.Version == "3.0.1b" ) then
		database.PartyFrames.PartyHeader.ShowParty = true;
		database.Version = "3.1.0b";
	end
	
	if ( database.Version ~= "3.2.0b" ) then
		database.Version = "3.2.0b";
	end
end