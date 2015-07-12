local addonName = ...;
local L = ArenaLiveUnitFrames.L;
local parent = "ALUF_UnitFrameOptionsHandlerFrame";
local optionFrames;

function ALUF_UnitFrameOptions:InitialisePositioning()
	ArenaLive:ConstructOptionFrame(optionFrames["Position"], addonName, "Aura", "PlayerFrame");
	ArenaLive:ConstructOptionFrame(optionFrames["AttachedTo"], addonName, "Aura", "PlayerFrame");
	ArenaLive:ConstructOptionFrame(optionFrames["XOffset"], addonName, "Aura", "PlayerFrame");
	ArenaLive:ConstructOptionFrame(optionFrames["YOffset"], addonName, "Aura", "PlayerFrame");
	
	ALUF_UnitFrameOptionsHandlerFrameElementPosition:Hide();
	ALUF_UnitFrameOptionsHandlerFrameElementAttachedTo:Hide();
	ALUF_UnitFrameOptionsHandlerFrameElementXOffset:Hide();
	ALUF_UnitFrameOptionsHandlerFrameElementYOffset:Hide();
end

function ALUF_UnitFrameOptions:UpdatePositioningGroup(group)
	ALUF_UnitFrameOptionsHandlerFrameElementPosition.group = group;
	ALUF_UnitFrameOptionsHandlerFrameElementAttachedTo.group = group;
	ALUF_UnitFrameOptionsHandlerFrameElementXOffset.group = group;	
	ALUF_UnitFrameOptionsHandlerFrameElementYOffset.group = group;
end

function ALUF_UnitFrameOptions:UpdatePositioningHandler(handler)
	ALUF_UnitFrameOptionsHandlerFrameElementPosition.handler = handler;	
	ALUF_UnitFrameOptionsHandlerFrameElementAttachedTo.handler = handler;
	ALUF_UnitFrameOptionsHandlerFrameElementXOffset.handler = handler;
	ALUF_UnitFrameOptionsHandlerFrameElementYOffset.handler = handler;	
end

function ALUF_UnitFrameOptions:ShowPositioningHandler()
	ALUF_UnitFrameOptionsHandlerFrameElementPosition:Show();
	ALUF_UnitFrameOptionsHandlerFrameElementAttachedTo:Show();
	ALUF_UnitFrameOptionsHandlerFrameElementXOffset:Show();
	ALUF_UnitFrameOptionsHandlerFrameElementYOffset:Show();
	
	ALUF_UnitFrameOptionsHandlerFrameElementPosition:UpdateShownValue();
	ALUF_UnitFrameOptionsHandlerFrameElementAttachedTo:UpdateShownValue();
	ALUF_UnitFrameOptionsHandlerFrameElementXOffset:UpdateShownValue();
	ALUF_UnitFrameOptionsHandlerFrameElementYOffset:UpdateShownValue();
end

function ALUF_UnitFrameOptions:HidePositioningHandler()
	ALUF_UnitFrameOptionsHandlerFrameElementPosition:Hide();
	ALUF_UnitFrameOptionsHandlerFrameElementAttachedTo:Hide();
	ALUF_UnitFrameOptionsHandlerFrameElementXOffset:Hide();
	ALUF_UnitFrameOptionsHandlerFrameElementYOffset:Hide();
end

local info = {};

optionFrames = {
	["Position"] = {
		["type"] = "DropDown",
		["name"] = parent.."ElementPosition",
		["parent"] = parent,
		["width"] = 125,
		["point"] = "TOPLEFT",
		["relativeTo"] = parent.."PositionText",
		["relativePoint"] = "BOTTOMLEFT",
		["xOffset"] = -10,
		["yOffset"] = -15,
		["title"] = L["Position"],
		["tooltip"] = L["Sets the position at which this frame element will be attached to another frame element."],
		["infoTable"] = {
			[1] = {
				["value"] = "ABOVE",
				["text"] = L["Above"],
			},
			[2] = {
				["value"] = "RIGHT",
				["text"] = L["Right"],
			},
			[3] = {
				["value"] = "BELOW",
				["text"] = L["Below"],
			},
			[4] = {
				["value"] = "LEFT",
				["text"] = L["Left"],
			},
		},
		["GetDBValue"] = function (frame) local database = ArenaLive:GetDBComponent(frame.addon, frame.handler, frame.group); return database.Position.Position; end,
		["SetDBValue"] = function (frame, newValue)  local database = ArenaLive:GetDBComponent(frame.addon, frame.handler, frame.group); database.Position.Position = newValue; end,
		["postUpdate"] = function (frame, newValue, oldValue) local frame = _G[ArenaLiveUnitFrames.frameGroupToFrame[frame.group]]; frame:UpdateElementPositions(); end,
	},
	["AttachedTo"] = {
		["type"] = "DropDown",
		["name"] = parent.."ElementAttachedTo",
		["parent"] = parent,
		["width"] = 150,
		["point"] = "LEFT",
		["relativeTo"] = parent.."ElementPosition",
		["relativePoint"] = "RIGHT",
		["xOffset"] = -25,
		["yOffset"] = 0,
		["title"] = L["Attach to"],
		["tooltip"] = L["Sets the frame element to which this frame element will be attached to."],
		["infoTable"] = {
			[1] = {
				["value"] = "UnitFrame",
				["text"] = L["Unit Frame"],
			},
			[2] = {
				["value"] = "Aura",
				["text"] = L["Aura"],
			},
			[3] = {
				["value"] = "CastBar",
				["text"] = L["CastBar"],
			},
			[4] = {
				["value"] = "CastHistory",
				["text"] = L["CastHistory"],
			},
			[5] = {
				["value"] = "DRTracker",
				["text"] = L["DRTracker"],
			},
			[6] = {
				["value"] = "PetFrame",
				["text"] = L["PetFrame"],
			},
			[7] = {
				["value"] = "TargetFrame",
				["text"] = L["TargetFrame"],
			},
		},
		["refreshFunc"] = function (dropDown)
			local dbValue = dropDown:GetDBValue();
			local database = ArenaLive:GetDBComponent(dropDown.addon, nil, dropDown.group);

			ArenaLiveUnitFrames:UpdateAttachedToCache(dropDown.group);
			local frame = _G[ArenaLiveUnitFrames.frameGroupToFrame[dropDown.group]]
			for key, infoData in ipairs(dropDown.info) do
				local proceed = true;
				if ( frame[infoData.value] and infoData.value ~= dropDown.handler ) then
					local valueAttachedTo = database[infoData.value].Position.AttachedTo;
					if ( valueAttachedTo == dropDown.handler ) then
						proceed = false;
					else
						-- Prevent frame element attachment dependency error.
						
						proceed = not ArenaLiveUnitFrames:IsHandlerDependentOnHandler(dropDown.handler, infoData.value);
					end
				elseif ( infoData.value ~= "UnitFrame" ) then
					proceed = false;
				end
				
				if ( proceed ) then
					info.text = infoData.text;
					info.value = infoData.value;
					info.func = dropDown.OnClick;
					if ( info.value == dbValue ) then
						info.checked = true;
					else
						info.checked = nil;
					end
					UIDropDownMenu_AddButton(info, level);
					table.wipe(info);
				end
			end
		end,
		["GetDBValue"] = function (frame) local database = ArenaLive:GetDBComponent(frame.addon, frame.handler, frame.group); return database.Position.AttachedTo; end,
		["SetDBValue"] = function (frame, newValue) local database = ArenaLive:GetDBComponent(frame.addon, frame.handler, frame.group); database.Position.AttachedTo = newValue; end,
		["postUpdate"] = function (frame, newValue, oldValue) local frame = _G[ArenaLiveUnitFrames.frameGroupToFrame[frame.group]]; frame:UpdateElementPositions(); end,
	},
	["XOffset"] = {
		["type"] = "EditBox",
		["width"] = 75,
		["height"] = 20,
		["name"] = parent.."ElementXOffset",
		["parent"] = parent,
		["point"] = "LEFT",
		["relativeTo"] = parent.."ElementAttachedTo",
		["relativePoint"] = "RIGHT",
		["xOffset"] = -10,
		["yOffset"] = 2,
		["inputType"] = "DECIMAL",
		["title"] = L["X Offset"],
		["tooltip"] = L["Horizontal distance between the frame element and the element it is attached to."],
		["GetDBValue"] = function (frame) local database = ArenaLive:GetDBComponent(frame.addon, frame.handler, frame.group); return database.Position.XOffset; end,
		["SetDBValue"] = function (frame, newValue) local database = ArenaLive:GetDBComponent(frame.addon, frame.handler, frame.group); database.Position.XOffset = newValue; end,
		["postUpdate"] = function (frame, newValue, oldValue) local frame = _G[ArenaLiveUnitFrames.frameGroupToFrame[frame.group]]; frame:UpdateElementPositions(); end,
	},
	["YOffset"] = {
		["type"] = "EditBox",
		["width"] = 75,
		["height"] = 20,
		["name"] = parent.."ElementYOffset",
		["parent"] = parent,
		["point"] = "LEFT",
		["relativeTo"] = parent.."ElementXOffset",
		["relativePoint"] = "RIGHT",
		["xOffset"] = 5,
		["yOffset"] = 0,
		["inputType"] = "DECIMAL",
		["title"] = L["Y Offset"],
		["tooltip"] = L["Vertical distance between the frame element and the element it is attached to."],
		["GetDBValue"] = function (frame) local database = ArenaLive:GetDBComponent(frame.addon, frame.handler, frame.group); return database.Position.YOffset; end,
		["SetDBValue"] = function (frame, newValue) local database = ArenaLive:GetDBComponent(frame.addon, frame.handler, frame.group); database.Position.YOffset = newValue; end,
		["postUpdate"] = function (frame, newValue, oldValue) local frame = _G[ArenaLiveUnitFrames.frameGroupToFrame[frame.group]]; frame:UpdateElementPositions(); end,
	},
};