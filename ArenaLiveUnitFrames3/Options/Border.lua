local addonName = ...;
local L = ArenaLiveUnitFrames.L;
local Page = ALUF_UnitFrameOptions:ConstructHandlerPage("Border");
Page.title = L["Border"];
local Border = ArenaLive:GetHandler("Border");
local parent = "ALUF_UnitFrameOptionsHandlerFrame";
local prefix = "ALUF_UnitFrameOptionsHandlerFrameBorder";
local optionFrames;

function Page:Initialise()
	ArenaLive:ConstructOptionFrameByHandler(optionFrames["Enable"], addonName, "Border", "Enable", "PlayerFrame");
	Page:RegisterFrame(ALUF_UnitFrameOptionsHandlerFrameBorderEnabled);
	ArenaLive:ConstructOptionFrameByHandler(optionFrames["Colour"], addonName, "Border", "Colour", "PlayerFrame");
	Page:RegisterFrame(ALUF_UnitFrameOptionsHandlerFrameBorderColour);
	Page:Hide();
end

optionFrames = {
	["Enable"] = {
		["name"] = prefix.."Enabled",
		["parent"] = parent,
		["point"] = "TOPLEFT",
		["relativeTo"] = parent.."Title",
		["relativePoint"] = "BOTTOMLEFT",
		["xOffset"] = 5,
		["yOffset"] = -15,
		["postUpdate"] = function (frame, newValue, oldValue)
			for id, unitFrame in ArenaLive:GetAllUnitFrames() do
				if ( unitFrame.addon == frame.addon and unitFrame.group == frame.group and unitFrame[Border.name] ) then
					unitFrame:ToggleHandler(Border.name);
					ArenaLiveUnitFrames:UpdateFrameBorders(unitFrame);
				end
			end
		end,
	},
	["Colour"] = {
		["name"] = prefix.."Colour",
		["parent"] = parent,
		["point"] = "TOPLEFT",
		["relativeTo"] = prefix.."Enabled",
		["relativePoint"] = "BOTTOMLEFT",
		["xOffset"] = 3,
		["yOffset"] = -5,
		["postUpdate"] = function (frame, newValue, oldValue) 
			for id, unitFrame in ArenaLive:GetAllUnitFrames() do 
				if ( unitFrame.addon == frame.addon and unitFrame.group == frame.group and unitFrame[Border.name] ) then 
					Border:Update(unitFrame);
					ArenaLiveUnitFrames:UpdateFrameBorders(unitFrame);
				end
			end
		end,
	},
};