local addonName = ...;
local L = ArenaLiveUnitFrames.L;
local Page = ALUF_UnitFrameOptions:ConstructHandlerPage("Aura");
Page.title = L["Aura"];

local parent = "ALUF_UnitFrameOptionsHandlerFrame";
local prefix = "ALUF_UnitFrameOptionsHandlerFrameAura";
local optionFrames;

function Page:Initialise()
	ArenaLive:ConstructOptionFrameByHandler(optionFrames["Enable"], addonName, "Aura", "Enable", "PlayerFrame");
	Page:RegisterFrame(ALUF_UnitFrameOptionsHandlerFrameAuraEnable);
	ArenaLive:ConstructOptionFrameByHandler(optionFrames["ClickThrough"], addonName, "Aura", "ClickThrough", "PlayerFrame");
	Page:RegisterFrame(ALUF_UnitFrameOptionsHandlerFrameAuraClickThrough);
	ArenaLive:ConstructOptionFrameByHandler(optionFrames["GrowUpwards"], addonName, "Aura", "GrowUpwards", "PlayerFrame");
	Page:RegisterFrame(ALUF_UnitFrameOptionsHandlerFrameAuraGrowUpwards);
	ArenaLive:ConstructOptionFrameByHandler(optionFrames["GrowRTL"], addonName, "Aura", "GrowRTL", "PlayerFrame");
	Page:RegisterFrame(ALUF_UnitFrameOptionsHandlerFrameAuraGrowRTL);
	ArenaLive:ConstructOptionFrameByHandler(optionFrames["OnlyShowRaidBuffs"], addonName, "Aura", "OnlyShowRaidBuffs", "PlayerFrame");
	Page:RegisterFrame(ALUF_UnitFrameOptionsHandlerFrameAuraOnlyShowRaidBuffs);
	ArenaLive:ConstructOptionFrameByHandler(optionFrames["OnlyShowDispellableBuffs"], addonName, "Aura", "OnlyShowDispellableBuffs", "PlayerFrame");
	Page:RegisterFrame(ALUF_UnitFrameOptionsHandlerFrameAuraOnlyShowDispellableBuffs);
	ArenaLive:ConstructOptionFrameByHandler(optionFrames["OnlyShowPlayerBuffs"], addonName, "Aura", "OnlyShowPlayerBuffs", "PlayerFrame");
	Page:RegisterFrame(ALUF_UnitFrameOptionsHandlerFrameAuraOnlyShowPlayerBuffs);
	ArenaLive:ConstructOptionFrameByHandler(optionFrames["OnlyShowDispellableDebuffs"], addonName, "Aura", "OnlyShowDispellableDebuffs", "PlayerFrame");
	Page:RegisterFrame(ALUF_UnitFrameOptionsHandlerFrameAuraOnlyShowDispellableDebuffs);
	ArenaLive:ConstructOptionFrameByHandler(optionFrames["ShowOnlyPlayerDebuffs"], addonName, "Aura", "ShowOnlyPlayerDebuffs", "PlayerFrame");
	Page:RegisterFrame(ALUF_UnitFrameOptionsHandlerFrameAuraShowOnlyPlayerDebuffs);
	ArenaLive:ConstructOptionFrameByHandler(optionFrames["NormalIconSize"], addonName, "Aura", "NormalIconSize", "PlayerFrame");
	Page:RegisterFrame(ALUF_UnitFrameOptionsHandlerFrameAuraNormalIconSize);
	ArenaLive:ConstructOptionFrameByHandler(optionFrames["LargeIconSize"], addonName, "Aura", "LargeIconSize", "PlayerFrame");
	Page:RegisterFrame(ALUF_UnitFrameOptionsHandlerFrameAuraLargeIconSize);
	ArenaLive:ConstructOptionFrameByHandler(optionFrames["AurasPerRow"], addonName, "Aura", "AurasPerRow", "PlayerFrame");
	Page:RegisterFrame(ALUF_UnitFrameOptionsHandlerFrameAuraAurasPerRow);
	ArenaLive:ConstructOptionFrameByHandler(optionFrames["MaxBuffs"], addonName, "Aura", "MaxBuffs", "PlayerFrame");
	Page:RegisterFrame(ALUF_UnitFrameOptionsHandlerFrameAuraMaxBuffs);
	ArenaLive:ConstructOptionFrameByHandler(optionFrames["MaxDebuffs"], addonName, "Aura", "MaxDebuffs", "PlayerFrame");
	Page:RegisterFrame(ALUF_UnitFrameOptionsHandlerFrameAuraMaxDebuffs);
	Page:Hide();
end

optionFrames = {
	["Enable"] = {
		["name"] = prefix.."Enable",
		["parent"] = parent,
		["point"] = "TOPLEFT",
		["relativeTo"] = parent.."Title",
		["relativePoint"] = "BOTTOMLEFT",
		["xOffset"] = 5,
		["yOffset"] = -15,
	},
	["ClickThrough"] = {
		["name"] = prefix.."ClickThrough",
		["parent"] = parent,
		["point"] = "LEFT",
		["relativeTo"] = prefix.."EnableText",
		["relativePoint"] = "RIGHT",
		["xOffset"] = 5,
		["yOffset"] = -1,
	},
	["GrowUpwards"] = {
		["name"] = prefix.."GrowUpwards",
		["parent"] = parent,
		["point"] = "TOPLEFT",
		["relativeTo"] = prefix.."Enable",
		["relativePoint"] = "BOTTOMLEFT",
		["xOffset"] = 0,
		["yOffset"] = -5,
	},
	["GrowRTL"] = {
		["name"] = prefix.."GrowRTL",
		["parent"] = parent,
		["point"] = "LEFT",
		["relativeTo"] = prefix.."GrowUpwardsText",
		["relativePoint"] = "RIGHT",
		["xOffset"] = 5,
		["yOffset"] = -1,
	},
	["OnlyShowRaidBuffs"] = {
		["name"] = prefix.."OnlyShowRaidBuffs",
		["parent"] = parent,
		["point"] = "TOPLEFT",
		["relativeTo"] = prefix.."GrowUpwards",
		["relativePoint"] = "BOTTOMLEFT",
		["xOffset"] = 0,
		["yOffset"] = -5,
	},
	["OnlyShowDispellableBuffs"] = {
		["name"] = prefix.."OnlyShowDispellableBuffs",
		["parent"] = parent,
		["point"] = "LEFT",
		["relativeTo"] = prefix.."OnlyShowRaidBuffsText",
		["relativePoint"] = "RIGHT",
		["xOffset"] = 5,
		["yOffset"] = -1,
	},
	["OnlyShowPlayerBuffs"] = {
		["name"] = prefix.."OnlyShowPlayerBuffs",
		["parent"] = parent,
		["point"] = "LEFT",
		["relativeTo"] = prefix.."OnlyShowDispellableBuffsText",
		["relativePoint"] = "RIGHT",
		["xOffset"] = 5,
		["yOffset"] = -1,
	},
	["OnlyShowDispellableDebuffs"] = {
		["name"] = prefix.."OnlyShowDispellableDebuffs",
		["parent"] = parent,
		["point"] = "TOPLEFT",
		["relativeTo"] = prefix.."OnlyShowRaidBuffs",
		["relativePoint"] = "BOTTOMLEFT",
		["xOffset"] = 0,
		["yOffset"] = -5,
	},
	["ShowOnlyPlayerDebuffs"] = {
		["name"] = prefix.."ShowOnlyPlayerDebuffs",
		["parent"] = parent,
		["point"] = "LEFT",
		["relativeTo"] = prefix.."OnlyShowDispellableDebuffsText",
		["relativePoint"] = "RIGHT",
		["xOffset"] = 5,
		["yOffset"] = -1,
	},
	["NormalIconSize"] = {
		["name"] = prefix.."NormalIconSize",
		["parent"] = parent,
		["point"] = "TOPLEFT",
		["relativeTo"] = prefix.."OnlyShowDispellableDebuffs",
		["relativePoint"] = "BOTTOMLEFT",
		["xOffset"] = 0,
		["yOffset"] = -25,
	},
	["LargeIconSize"] = {
		["name"] = prefix.."LargeIconSize",
		["parent"] = parent,
		["point"] = "LEFT",
		["relativeTo"] = prefix.."NormalIconSize",
		["relativePoint"] = "RIGHT",
		["xOffset"] = 25,
		["yOffset"] = 0,
	},
	["AurasPerRow"] = {
		["name"] = prefix.."AurasPerRow",
		["parent"] = parent,
		["point"] = "TOPLEFT",
		["relativeTo"] = prefix.."NormalIconSize",
		["relativePoint"] = "BOTTOMLEFT",
		["xOffset"] = 0,
		["yOffset"] = -35,
	},
	["MaxBuffs"] = {
		["name"] = prefix.."MaxBuffs",
		["parent"] = parent,
		["point"] = "TOPLEFT",
		["relativeTo"] = prefix.."AurasPerRow",
		["relativePoint"] = "BOTTOMLEFT",
		["xOffset"] = 0,
		["yOffset"] = -35,
	},
	["MaxDebuffs"] = {
		["name"] = prefix.."MaxDebuffs",
		["parent"] = parent,
		["point"] = "LEFT",
		["relativeTo"] = prefix.."MaxBuffs",
		["relativePoint"] = "RIGHT",
		["xOffset"] = 25,
		["yOffset"] = 0,
	},
};