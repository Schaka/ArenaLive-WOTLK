local addonName = ...;
local L = ArenaLiveUnitFrames.L;
local Page = ALUF_UnitFrameOptions:ConstructHandlerPage("CastBar");
Page.title = L["CastBar"];

local parent = "ALUF_UnitFrameOptionsHandlerFrame";
local prefix = "ALUF_UnitFrameOptionsHandlerFrameCastBar";
local optionFrames;

function Page:Initialise()
	ArenaLive:ConstructOptionFrameByHandler(optionFrames["Enable"], addonName, "CastBar", "Enable", "PlayerFrame");
	ArenaLive:ConstructOptionFrameByHandler(optionFrames["ReverseFill"], addonName, "CastBar", "ReverseFill", "PlayerFrame");
	ArenaLive:ConstructOptionFrame(optionFrames["LongCastBar"], addonName, "CastBar", "PlayerFrame");
	Page:RegisterFrame(ALUF_UnitFrameOptionsHandlerFrameCastBarEnabled);
	Page:RegisterFrame(ALUF_UnitFrameOptionsHandlerFrameCastBarReverseFill);
	Page:RegisterFrame(ALUF_UnitFrameOptionsHandlerFrameCastBarLongCastBar);
	Page:Hide();
end


function Page:Show()
	ALUF_UnitFrameOptionsHandlerFrameCastBarEnabled:Show();
	ALUF_UnitFrameOptionsHandlerFrameCastBarReverseFill:Show();
	
	local frameGroup = self:GetActiveFrameGroup();
	if ( frameGroup == "PartyFrames" or frameGroup == "ArenaEnemyFrames" ) then
		ALUF_UnitFrameOptionsHandlerFrameCastBarLongCastBar:Show();
	else
		ALUF_UnitFrameOptionsHandlerFrameCastBarLongCastBar:Hide();
	end
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
	},
	["ReverseFill"] = {
		["name"] = prefix.."ReverseFill",
		["parent"] = parent,
		["point"] = "TOPLEFT",
		["relativeTo"] = prefix.."Enabled",
		["relativePoint"] = "BOTTOMLEFT",
		["xOffset"] = 0,
		["yOffset"] = -10,
	},
	["LongCastBar"] = {
		["type"] = "CheckButton",
		["name"] = prefix.."LongCastBar",
		["parent"] = parent,
		["point"] = "TOPLEFT",
		["relativeTo"] = prefix.."ReverseFill",
		["relativePoint"] = "BOTTOMLEFT",
		["xOffset"] = 0,
		["yOffset"] = -10,
		["title"] = L["Longer Castbar"],
		["tooltip"] = L["If checked, the unit frames will show a longer cast bar than the usual one."],
		["GetDBValue"] = function (frame) local database = ArenaLive:GetDBComponent(frame.addon, frame.handler, frame.group); return database.LongCastBar; end,
		["SetDBValue"] = function (frame, newValue) local database = ArenaLive:GetDBComponent(frame.addon, frame.handler, frame.group); database.LongCastBar = newValue; end,
		["postUpdate"] = function(frame, newValue, OldValue)
			if ( frame.group == "ArenaEnemyFrames" ) then
				for i = 1, 5 do
					ArenaLiveUnitFrames:UpdateCastBarDisplay(_G["ALUF_ArenaEnemyFramesArenaEnemyFrame"..i]);
				end
			elseif ( frame.group == "PartyFrames" ) then
				ArenaLiveUnitFrames:UpdateCastBarDisplay(_G["ALUF_PartyFramesPlayerFrame"]);
				for i = 1, 4 do
					ArenaLiveUnitFrames:UpdateCastBarDisplay(_G["ALUF_PartyFramesFrame"..i]);
				end
			end
		end,
	},
};