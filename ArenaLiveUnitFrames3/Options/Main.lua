local addonName = ...;
local L = ArenaLiveUnitFrames.L;

local prefix = "ALUF_Options";
local optionFrames;

function ALUF_Options:Initialise()
	ALUF_OptionsTitle:SetText(L["ArenaLive [UnitFrames] General Options:"]);
	ALUF_OptionsCCTitle:SetText(L["Crowd Control Indicator Priorities:"]);
	ALUF_OptionsCCDescription:SetText(L["Set the priorities for the different indicator types, zero deactivates them."]);
	ALUF_Options.name = L["ArenaLive [UnitFrames]"];
	InterfaceOptions_AddCategory(ALUF_Options);
	
	-- General Options:
	ArenaLive:ConstructOptionFrameByHandler(optionFrames["FrameLock"], addonName, "FrameMover", "FrameLock");
	ArenaLive:ConstructOptionFrameByHandler(optionFrames["ShowGrid"], "ArenaLive3", "Grid", "Shown");
	ArenaLive:ConstructOptionFrameByHandler(optionFrames["ShowCooldownText"], addonName, "Cooldown", "ShowText");
	ArenaLive:ConstructOptionFrame(optionFrames["HideBlizzardCastBar"], addonName);
	-- CC Indicator Priorities:
	ArenaLive:ConstructOptionFrameByHandler(optionFrames["CCDefCDs"], addonName, "CCIndicator", "DefCD");
	ArenaLive:ConstructOptionFrameByHandler(optionFrames["CCStuns"], addonName, "CCIndicator", "Stun");
	ArenaLive:ConstructOptionFrameByHandler(optionFrames["CCSilences"], addonName, "CCIndicator", "Silence");
	ArenaLive:ConstructOptionFrameByHandler(optionFrames["CCCrowdControls"], addonName, "CCIndicator", "CrowdControl");
	ArenaLive:ConstructOptionFrameByHandler(optionFrames["CCRoots"], addonName, "CCIndicator", "Root");
	--ArenaLive:ConstructOptionFrameByHandler(optionFrames["CCDisarms"], addonName, "CCIndicator", "Disarm");
	ArenaLive:ConstructOptionFrameByHandler(optionFrames["CCOffCDs"], addonName, "CCIndicator", "OffCD");
	ArenaLive:ConstructOptionFrameByHandler(optionFrames["CCUsefulBuffs"], addonName, "CCIndicator", "UsefulBuff");
	ArenaLive:ConstructOptionFrameByHandler(optionFrames["CCUsefulDebuffs"], addonName, "CCIndicator", "UsefulDebuff");
	
end

SLASH_ALIVE1, SLASH_ALIVE2 = "/alive", "/arenalive";
function SlashCmdList.ALIVE(msg, editbox)
	InterfaceOptionsFrame_OpenToCategory(ALUF_Options)
end


optionFrames = {
	["FrameLock"] = {
		["name"] = prefix.."FrameLock",
		["parent"] = prefix,
		["point"] = "TOPLEFT",
		["relativeTo"] = prefix.."Title",
		["relativePoint"] = "BOTTOMLEFT",
		["xOffset"] = 15,
		["yOffset"] = -15,
		["postUpdate"] = function (frame, newValue, oldValue) 
			ArenaLive:TriggerEvent("ARENALIVE_UPDATE_MOVABILITY_BY_ADDON", frame.addon);
			for id, unitFrame in ArenaLive:GetAllUnitFrames() do
				if ( unitFrame.addon == addonName ) then
					if ( newValue ) then
						unitFrame:TestMode(false);
					else
						unitFrame:TestMode(true);
					end
				end
				
				-- Fix: Party Pet and Target frames need an extra update:
				local frame;
				for i = 1, 4 do
					if ( i == 1 ) then
						frame = _G["ALUF_PartyFramesPlayerFramePetFrame"];
						frame:SetAttribute("al_framelock", newValue);
						frame = _G["ALUF_PartyFramesPlayerFrameTargetFrame"];
						frame:SetAttribute("al_framelock", newValue);
					end
					frame = _G["ALUF_PartyFramesFrame"..i.."PetFrame"];
					frame:SetAttribute("al_framelock", newValue);
					frame = _G["ALUF_PartyFramesFrame"..i.."TargetFrame"];
					frame:SetAttribute("al_framelock", newValue);
				end
			end
		end,
	},
	["ShowGrid"] = {
		["name"] = prefix.."ShowGrid",
		["parent"] = prefix,
		["point"] = "TOPLEFT",
		["relativeTo"] = prefix.."FrameLock",
		["relativePoint"] = "BOTTOMLEFT",
		["xOffset"] = 0,
		["yOffset"] = -5,
	},
	["ShowCooldownText"] = {
		["name"] = prefix.."ShowCooldownText",
		["parent"] = prefix,
		["point"] = "TOPLEFT",
		["relativeTo"] = prefix.."ShowGrid",
		["relativePoint"] = "BOTTOMLEFT",
		["xOffset"] = 0,
		["yOffset"] = -5,
	},
	["HideBlizzardCastBar"] = {
		["name"] = prefix.."HideBlizzardCastBar",
		["parent"] = prefix,
		["point"] = "TOPLEFT",
		["relativeTo"] = prefix.."ShowCooldownText",
		["relativePoint"] = "BOTTOMLEFT",
		["xOffset"] = 0,
		["yOffset"] = -5,
		["type"] = "CheckButton",
		["title"] = L["Hide Blizzard's Cast Bar"],
		["tooltip"] = L["Hides Blizzard's player cast bar."],
		["GetDBValue"] = function (frame) local database = ArenaLive:GetDBComponent(frame.addon); return database.HideBlizzCastBar; end,
		["SetDBValue"] = function (frame, newValue) local database = ArenaLive:GetDBComponent(frame.addon); database.HideBlizzCastBar = newValue; end,
		["postUpdate"] = function (frame, newValue, oldValue) ArenaLiveUnitFrames:ToggleBlizzCastBar(); end,
	},
	
	["CCDefCDs"] = {
		["name"] = prefix.."CCDefCDs",
		["parent"] = prefix,
		["point"] = "TOPLEFT",
		["relativeTo"] = prefix.."CCDescription",
		["relativePoint"] = "BOTTOMLEFT",
		["xOffset"] = 0,
		["yOffset"] = -25,
	},
	["CCStuns"] = {
		["name"] = prefix.."CCStuns",
		["parent"] = prefix,
		["point"] = "TOPLEFT",
		["relativeTo"] = prefix.."CCDefCDs",
		["relativePoint"] = "BOTTOMLEFT",
		["xOffset"] = 0,
		["yOffset"] = -35,
	},
	["CCSilences"] = {
		["name"] = prefix.."CCSilences",
		["parent"] = prefix,
		["point"] = "TOPLEFT",
		["relativeTo"] = prefix.."CCStuns",
		["relativePoint"] = "BOTTOMLEFT",
		["xOffset"] = 0,
		["yOffset"] = -35,
	},
	["CCCrowdControls"] = {
		["name"] = prefix.."CCCrowdControls",
		["parent"] = prefix,
		["point"] = "TOPLEFT",
		["relativeTo"] = prefix.."CCSilences",
		["relativePoint"] = "BOTTOMLEFT",
		["xOffset"] = 0,
		["yOffset"] = -35,
	},
	["CCRoots"] = {
		["name"] = prefix.."CCRoots",
		["parent"] = prefix,
		["point"] = "TOPLEFT",
		["relativeTo"] = prefix.."CCCrowdControls",
		["relativePoint"] = "BOTTOMLEFT",
		["xOffset"] = 0,
		["yOffset"] = -35,
	},
	--[[["CCDisarms"] = {
		["name"] = prefix.."CCDisarms",
		["parent"] = prefix,
		["point"] = "TOPLEFT",
		["relativeTo"] = prefix.."CCRoots",
		["relativePoint"] = "BOTTOMLEFT",
		["xOffset"] = 0,
		["yOffset"] = -35,
	},]]
	["CCOffCDs"] = {
		["name"] = prefix.."CCOffCDs",
		["parent"] = prefix,
		["point"] = "LEFT",
		["relativeTo"] = prefix.."CCDefCDs",
		["relativePoint"] = "RIGHT",
		["xOffset"] = 50,
		["yOffset"] = 0,
	},
	["CCUsefulBuffs"] = {
		["name"] = prefix.."CCUsefulBuffs",
		["parent"] = prefix,
		["point"] = "TOPLEFT",
		["relativeTo"] = prefix.."CCOffCDs",
		["relativePoint"] = "BOTTOMLEFT",
		["xOffset"] = 0,
		["yOffset"] = -35,
	},
	["CCUsefulDebuffs"] = {
		["name"] = prefix.."CCUsefulDebuffs",
		["parent"] = prefix,
		["point"] = "TOPLEFT",
		["relativeTo"] = prefix.."CCUsefulBuffs",
		["relativePoint"] = "BOTTOMLEFT",
		["xOffset"] = 0,
		["yOffset"] = -35,
	},
};