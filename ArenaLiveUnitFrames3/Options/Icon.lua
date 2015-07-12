local addonName = ...;
local L = ArenaLiveUnitFrames.L;
local Page = ALUF_UnitFrameOptions:ConstructHandlerPage("Icon");
Page.title = L["Icon"];

local parent = "ALUF_UnitFrameOptionsHandlerFrame";
local prefix = "ALUF_UnitFrameOptionsHandlerFrameIcon";
local optionFrames;

function Page:Initialise()
	ArenaLive:ConstructOptionFrameByHandler(optionFrames["1Type"], addonName, "Icon", "IconType", "PlayerFrame");
	Page:RegisterFrame(ALUF_UnitFrameOptionsHandlerFrameIcon1Type);
	ArenaLive:ConstructOptionFrameByHandler(optionFrames["1Fallback"], addonName, "Icon", "FallBackType", "PlayerFrame");
	Page:RegisterFrame(ALUF_UnitFrameOptionsHandlerFrameIcon1Fallback);
	ArenaLive:ConstructOptionFrameByHandler(optionFrames["2Type"], addonName, "Icon", "IconType", "PlayerFrame");
	Page:RegisterFrame(ALUF_UnitFrameOptionsHandlerFrameIcon2Type);
	ArenaLive:ConstructOptionFrameByHandler(optionFrames["2Fallback"], addonName, "Icon", "FallBackType", "PlayerFrame");
	Page:RegisterFrame(ALUF_UnitFrameOptionsHandlerFrameIcon2Fallback);
	Page:Hide();
end

optionFrames = {
	["1Type"] = {
		["id"] = 1,
		["title"] = L["Top Icon Type"],
		["name"] = prefix.."1Type",
		["parent"] = parent,
		["point"] = "TOPLEFT",
		["relativeTo"] = parent.."Title",
		["relativePoint"] = "BOTTOMLEFT",
		["xOffset"] = 5,
		["yOffset"] = -15,
	},
	["1Fallback"] = {
		["id"] = 1,
		["title"] = L["Top Icon Fallback"],
		["name"] = prefix.."1Fallback",
		["parent"] = parent,
		["point"] = "LEFT",
		["relativeTo"] = prefix.."1Type",
		["relativePoint"] = "RIGHT",
		["xOffset"] = 0,
		["yOffset"] = 0,
	},
	["2Type"] = {
		["id"] = 2,
		["title"] = L["Bottom Icon Type"],
		["name"] = prefix.."2Type",
		["parent"] = parent,
		["point"] = "TOPLEFT",
		["relativeTo"] = prefix.."1Type",
		["relativePoint"] = "BOTTOMLEFT",
		["xOffset"] = 0,
		["yOffset"] = -20,
	},
	["2Fallback"] = {
		["id"] = 2,
		["title"] = L["Bottom Icon Fallback"],
		["name"] = prefix.."2Fallback",
		["parent"] = parent,
		["point"] = "LEFT",
		["relativeTo"] = prefix.."2Type",
		["relativePoint"] = "RIGHT",
		["xOffset"] = 0,
		["yOffset"] = 0,
	},
};