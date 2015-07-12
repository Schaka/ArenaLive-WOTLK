local addonName = ...;
local L = ArenaLiveUnitFrames.L;
local Page = ALUF_UnitFrameOptions:ConstructHandlerPage("Portrait");
Page.title = L["Portrait"];

local parent = "ALUF_UnitFrameOptionsHandlerFrame";
local prefix = "ALUF_UnitFrameOptionsHandlerFramePortrait";
local optionFrames;

function Page:Initialise()
	ArenaLive:ConstructOptionFrameByHandler(optionFrames["Type"], addonName, "Portrait", "Type", "PlayerFrame");
	Page:RegisterFrame(ALUF_UnitFrameOptionsHandlerFramePortraitType);
	Page:Hide();
end

optionFrames = {
	["Type"] = {
		["id"] = 1,
		["title"] = L["Portrait Type"],
		["name"] = prefix.."Type",
		["parent"] = parent,
		["point"] = "TOPLEFT",
		["relativeTo"] = parent.."Title",
		["relativePoint"] = "BOTTOMLEFT",
		["xOffset"] = 5,
		["yOffset"] = -15,
	},
};