--[[ ArenaLive Core Functions: Frame Mover Handler
Created by: Vadrak
Creation Date: 05.06.2014
Last Update: "
This handler is used to set scripts for frames so that they can be moved. It also stores the new position in the Saved Variables.
NOTE: Every frame that should be movable needs a unique frame name, as we store frame positions by the frame's name.
]]--

-- ArenaLive addon Name and localisation table:
local addonName, L = ...;

--[[
**************************************************
******* GENERAL HANDLER SET UP STARTS HERE *******
**************************************************
]]--
-- Construct Custom Events:
ArenaLive:ConstructEvent("ARENALIVE_UPDATE_MOVABILITY_BY_ADDON");
ArenaLive:ConstructEvent("ARENALIVE_UPDATE_POSITION_BY_NAME");
ArenaLive:ConstructEvent("ARENALIVE_FRAME_MOVER_ON_DRAG_STOP");

-- Create new Handler and register for all important events:
local FrameMover = ArenaLive:ConstructHandler("FrameMover", true);
FrameMover:RegisterEvent("PLAYER_REGEN_ENABLED");
FrameMover:RegisterEvent("ARENALIVE_UPDATE_MOVABILITY_BY_ADDON");
FrameMover:RegisterEvent("ARENALIVE_UPDATE_POSITION_BY_NAME");

local pointsInfo = {
	[1] = {
		["text"] = L["TOPLEFT"],
		["value"] = "TOPLEFT",
	},
	[2] = {
		["text"] = L["TOP"],
		["value"] = "TOP",
	},
	[3] = {
		["text"] = L["TOPRIGHT"],
		["value"] = "TOPRIGHT",
	},
	[4] = {
		["text"] = L["LEFT"],
		["value"] = "LEFT",
	},
	[5] = {
		["text"] = L["CENTER"],
		["value"] = "CENTER",
	},
	[6] = {
		["text"] = L["RIGHT"],
		["value"] = "RIGHT",
	},
	[7] = {
		["text"] = L["BOTTOMLEFT"],
		["value"] = "BOTTOMLEFT",
	},
	[8] = {
		["text"] = L["BOTTOM"],
		["value"] = "BOTTOM",
	},
	[9] = {
		["text"] = L["BOTTOMRIGHT"],
		["value"] = "BOTTOMRIGHT",
	},
};

-- Option frame set ups:
-- Note that you need to set frame.group as the Name of the affected frame as it is returned by frame:GetFrameName();
FrameMover.optionSets = {
	["FrameLock"] = {
		["type"] = "CheckButton",
		["title"] = L["Frame Lock"],
		["tooltip"] = L["Locks all movable frames of the addon."],
		["GetDBValue"] = function (frame) local database = ArenaLive:GetDBComponent(frame.addon, "FrameMover"); return database.FrameLock; end,
		["SetDBValue"] = function (frame, newValue) local database = ArenaLive:GetDBComponent(frame.addon, "FrameMover"); database.FrameLock = newValue; end,
		["postUpdate"] = function (frame, newValue, oldValue) ArenaLive:TriggerEvent("ARENALIVE_UPDATE_MOVABILITY_BY_ADDON", frame.addon) end,
	},
	["Point"] = {
		["type"] = "DropDown",
		["title"] = L["Point"],
		["tooltip"] = L["Choose the frame's anchor point. It will be attached to the relative frame at this point."],
		["width"] = 100,
		["infoTable"] = pointsInfo,
		["GetDBValue"] = function (frame) local database = ArenaLive:GetDBComponent(frame.addon, "FrameMover"); return database[frame.group]["Point"]; end,
		["SetDBValue"] = function (frame, newValue) local database = ArenaLive:GetDBComponent(frame.addon, "FrameMover"); database[frame.group]["Point"] = newValue; end,
		["postUpdate"] = function (frame, newValue, oldValue) ArenaLive:TriggerEvent("ARENALIVE_UPDATE_POSITION_BY_NAME", frame.group) end,
	},
	["RelativeTo"] = {
		["type"] = "EditBox",
		["width"] = 100,
		["height"] = 20,
		["title"] = L["Relative Frame"],
		["tooltip"] = L["The relative frame the frame will be anchored to. Leave this blank to anchor it to the global interface frame."],
		["GetDBValue"] = function (frame) local database = ArenaLive:GetDBComponent(frame.addon, "FrameMover"); return database[frame.group]["RelativeTo"] or ""; end,
		["SetDBValue"] = function (frame, newValue) if ( newValue == "" ) then newValue = nil; end local database = ArenaLive:GetDBComponent(frame.addon, "FrameMover"); database[frame.group]["RelativeTo"] = newValue; end,
		["postUpdate"] = function (frame, newValue, oldValue) ArenaLive:TriggerEvent("ARENALIVE_UPDATE_POSITION_BY_NAME", frame.group) end,
	},
	["RelativePoint"] = {
		["type"] = "DropDown",
		["title"] = L["Relative Point"],
		["tooltip"] = L["Choose the relative frame's anchor point. The frame will be anchored to this point of the relative frame."],
		["width"] = 100,
		["infoTable"] = pointsInfo,
		["GetDBValue"] = function (frame) local database = ArenaLive:GetDBComponent(frame.addon, "FrameMover"); return database[frame.group]["RelativePoint"]; end,
		["SetDBValue"] = function (frame, newValue) local database = ArenaLive:GetDBComponent(frame.addon, "FrameMover"); database[frame.group]["RelativePoint"] = newValue; end,
		["postUpdate"] = function (frame, newValue, oldValue) ArenaLive:TriggerEvent("ARENALIVE_UPDATE_POSITION_BY_NAME", frame.group) end,
	},
	["XOffset"] = {
		["type"] = "EditBox",
		["width"] = 75,
		["height"] = 20,
		["inputType"] = "DECIMAL",
		["title"] = L["X Offset"],
		["tooltip"] = L["The horizontal offset to the relative frame's anchor point."],
		["GetDBValue"] = function (frame) local database = ArenaLive:GetDBComponent(frame.addon, "FrameMover"); return database[frame.group]["XOffset"]; end,
		["SetDBValue"] = function (frame, newValue) if ( newValue == "" ) then newValue = nil; end local database = ArenaLive:GetDBComponent(frame.addon, "FrameMover"); database[frame.group]["XOffset"] = newValue; end,
		["postUpdate"] = function (frame, newValue, oldValue) ArenaLive:TriggerEvent("ARENALIVE_UPDATE_POSITION_BY_NAME", frame.group) end,
	},
	["YOffset"] = {
		["type"] = "EditBox",
		["width"] = 75,
		["height"] = 20,
		["inputType"] = "DECIMAL",
		["title"] = L["Y Offset"],
		["tooltip"] = L["The vertical offset to the relative frame's anchor point."],
		["GetDBValue"] = function (frame) local database = ArenaLive:GetDBComponent(frame.addon, "FrameMover"); return database[frame.group]["YOffset"]; end,
		["SetDBValue"] = function (frame, newValue) if ( newValue == "" ) then newValue = nil; end local database = ArenaLive:GetDBComponent(frame.addon, "FrameMover"); database[frame.group]["YOffset"] = newValue; end,
		["postUpdate"] = function (frame, newValue, oldValue) ArenaLive:TriggerEvent("ARENALIVE_UPDATE_POSITION_BY_NAME", frame.group) end,
	},
};

-- Table to store all movable frames in:
local movableFrames = {};

-- Table to store frames that were blocked from updating by combat lockdown:
local framesToUpdate = {};

local function OnDragStart (frame)
	if ( not frame.locked ) then
		frame:StartMoving();
		frame:SetClampedToScreen(true);
	end
end

local function OnDragStop (frame)
	if ( not frame.locked ) then
		frame:StopMovingOrSizing();
		
		-- Prevent Blizzard's layout cache from saving the frame positions, otherwise it can interfere with our own positioning system:
		frame:SetUserPlaced(false);
		
		local database = ArenaLive:GetDBComponent(frame.addon, "FrameMover");
		local name = frame:GetName();
		local point, relativeTo, relativePoint, xOffset, yOffset = frame:GetPoint();
		
		-- Save name of the relativeTo object so it won't be nil later on in the saved variables:
		if ( relativeTo ) then
			relativeTo = relativeTo:GetName();
		end
			
		-- Set database values accordingly:
		database[name]["Point"] = point;
		database[name]["RelativeTo"] = relativeTo;
		database[name]["RelativePoint"] = relativePoint;
		database[name]["XOffset"] = xOffset;
		database[name]["YOffset"] = yOffset;
		
		ArenaLive:TriggerEvent("ARENALIVE_FRAME_MOVER_ON_DRAG_STOP", frame.addon, name);
	end
end

--[[
****************************************
****** HANDLER METHODS START HERE ******
****************************************
]]--
function FrameMover:AddFrame(frame)
	
	ArenaLive:CheckArgs(frame, "table", frame.GetName, "function");
	
	local name = frame:GetName();
	
	if ( not name ) then
		ArenaLive:Message(L["Couldn't create moving functionality for frame, because the given frame does not have an unique name!"], "error");
		return;
	end
	
	-- Set basic info according to saved variables:
	FrameMover:ToggleMovability(frame);
	FrameMover:SetPosition(frame);
	
	-- Set scripts, make frame movable and register for drag:
	frame:SetScript("OnDragStart", OnDragStart);
	frame:SetScript("OnDragStop", OnDragStop);
	frame:SetMovable(true);
	frame:RegisterForDrag("LeftButton");
	
	-- Add to movable frames table:
	movableFrames[frame] = true;
end

function FrameMover:SetPosition(frame)
	local database = ArenaLive:GetDBComponent(frame.addon, self.name);
	local name = frame:GetName();
	
	if ( not name ) then
		ArenaLive:Message(L["Couldn't set position for frame, because the given frame is not registered for ArenaLive's frame mover!"], "error");
		return;
	end
	
	if ( not database[name] or not database[name]["Point"] ) then
		database[name] = {};
		
		-- This is the first time the frame is registered, so save the current position as a default value: 
		local point, relativeTo, relativePoint, xOffset, yOffset = frame:GetPoint();
		
		-- Save name of the relativeTo object instead of the object itself, so it won't be nil later on in the saved variables:
		if ( relativeTo ) then
			relativeTo = relativeTo:GetName();
		end
		
		-- Set database values accordingly:
		database[name]["Point"] = point;
		database[name]["RelativeTo"] = relativeTo;
		database[name]["RelativePoint"] = relativePoint;
		database[name]["XOffset"] = xOffset;
		database[name]["YOffset"] = yOffset;
	else
		if ( not InCombatLockdown() or not frame:IsProtected() ) then
			frame:ClearAllPoints();
			local relativeTo = database[name]["RelativeTo"]; 
			if ( type(relativeTo) == "string" ) then
				relativeTo = _G[relativeTo]; -- Prevent not existing frame names from triggering an error message.
				if ( not relativeTo ) then
					ArenaLive:Message(L["Tried to attach %s to an UI object that doesn't exist. Attaching it to it's parent frame instead, in order to prevent error messages..."], "message", name);
				end
			end
			frame:SetPoint(database[name]["Point"], relativeTo, database[name]["RelativePoint"], database[name]["XOffset"], database[name]["YOffset"]);
			frame.updatePosition = nil;
		else
			frame.updatePosition = true;
			framesToUpdate[frame] = true;
		end
	end
end

function FrameMover:ToggleMovability(frame)

	local database = ArenaLive:GetDBComponent(frame.addon, self.name);
	
	if ( frame.SetAttribute ) then
		if ( not InCombatLockdown() ) then
			frame:SetAttribute("al_framelock", database.FrameLock);
			frame.updateMovability = nil;
		else
			frame.updateMovability = true;
			framesToUpdate[frame] = true;
			return;
		end
	end
	
	frame.locked = database.FrameLock;
end

function FrameMover:OnEvent(event, ...)
	local filter = ...;
	if ( event == "PLAYER_REGEN_ENABLED" ) then
		for frame in pairs(framesToUpdate) do
			if ( frame.updateMovability ) then
				FrameMover:ToggleMovability(frame);
			end
			
			if ( frame.updatePosition ) then
				FrameMover:SetPosition(frame);
			end
			
			framesToUpdate[frame] = nil;
		end
	elseif ( event == "ARENALIVE_UPDATE_MOVABILITY_BY_ADDON" ) then
		for frame in pairs(movableFrames) do
			if ( filter == frame.addon  ) then
				FrameMover:ToggleMovability(frame);
			end
		end
	elseif ( event == "ARENALIVE_UPDATE_POSITION_BY_NAME" ) then
		local frame = _G[filter];
		FrameMover:SetPosition(frame);
	end
end