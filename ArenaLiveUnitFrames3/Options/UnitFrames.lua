local addonName = ...;
local L = ArenaLiveUnitFrames.L;

local prefix = "ALUF_UnitFrameOptions";
local optionFrames;
local handlerOptionPages = {};
local frameGroupsToHandlers;
local CURRENT_FRAME_GROUP, CURRENT_SHOWN_HANDLER;
local PageClass = {};

local info = {};
local function frameGroupDropDown_OnClick(button)
	local dropDown = UIDROPDOWNMENU_OPEN_MENU;
	UIDropDownMenu_SetText(dropDown, button:GetText());
	UIDropDownMenu_SetText(ALUF_UnitFrameOptionsHandlerDropDown, L["UnitFrame"]);
	ALUF_UnitFrameOptions:UpdateActiveFrameGroup(button.value);
	ALUF_UnitFrameOptions:UpdateActiveHandler("UnitFrame");
	
end

local function frameGroupDropDown_Refresh(dropDown, level, menuList)
	for value, text in pairs(ArenaLiveUnitFrames.frameGroups) do
		info.value = value;
		info.text = text;
		info.func = frameGroupDropDown_OnClick;
		if ( value == CURRENT_FRAME_GROUP ) then
			info.checked = true;
		end		
		UIDropDownMenu_AddButton(info, level);
		table.wipe(info);
	end
end

local function handlerDropDown_OnClick(button)
	local dropDown = UIDROPDOWNMENU_OPEN_MENU;
	UIDropDownMenu_SetText(dropDown, button:GetText());
	
	ALUF_UnitFrameOptions:UpdateActiveHandler(button.value);
end

local function handlerDropDown_Refresh(dropDown, level, menuList)
	if ( CURRENT_FRAME_GROUP ) then
		local database = ArenaLive:GetDBComponent(addonName, nil, CURRENT_FRAME_GROUP);
		
		for handlerName in pairs(database) do
			if ( handlerOptionPages[handlerName] ) then
				info.value = handlerName;
				info.text = L[handlerName] or handlerName;
				info.func = handlerDropDown_OnClick;
				if ( handlerName == CURRENT_SHOWN_HANDLER ) then
					info.checked = true;
				end
				UIDropDownMenu_AddButton(info, level);
				table.wipe(info);
			end
		end
	end
end

function ALUF_UnitFrameOptions:Initialise()
	ALUF_UnitFrameOptionsTitle:SetText(L["ArenaLive [UnitFrames] Unit Frame Options:"]);
	ALUF_UnitFrameOptions.name = L["Unit Frames"];
	ALUF_UnitFrameOptions.parent = L["ArenaLive [UnitFrames]"];
	InterfaceOptions_AddCategory(ALUF_UnitFrameOptions);
	
	-- Initialise Frame Group DropDown:
	ALUF_UnitFrameOptionsFrameGroupDropDown.title:SetText(L["Unit Frame:"]);
	UIDropDownMenu_SetText(ALUF_UnitFrameOptionsFrameGroupDropDown, L["Choose a frame"]);
	UIDropDownMenu_Initialize(ALUF_UnitFrameOptionsFrameGroupDropDown, frameGroupDropDown_Refresh);
	UIDropDownMenu_SetWidth(ALUF_UnitFrameOptionsFrameGroupDropDown, 250);
	
	-- Initialise Handler DropDown:
	ALUF_UnitFrameOptionsHandlerDropDown.title:SetText(L["Frame Element:"]);
	UIDropDownMenu_SetText(ALUF_UnitFrameOptionsHandlerDropDown, L["Choose a frame element"]);
	UIDropDownMenu_Initialize(ALUF_UnitFrameOptionsHandlerDropDown, handlerDropDown_Refresh);
	UIDropDownMenu_SetWidth(ALUF_UnitFrameOptionsHandlerDropDown, 250);
	
	-- Initialise all registered option pages:
	for handlerName, page in pairs(handlerOptionPages) do
		if ( type(page.Initialise) == "function" ) then
			page:Initialise();
		end
	end
	
	-- Initialise frame element positioning frames:
	ALUF_UnitFrameOptions:InitialisePositioning();
end

function ALUF_UnitFrameOptions:UpdateActiveFrameGroup(newFrameGroup)
	CURRENT_FRAME_GROUP = newFrameGroup;
	
	-- Update all option pages to the new frameGroup:
	local database = ArenaLive:GetDBComponent(addonName, nil, CURRENT_FRAME_GROUP);
	for handlerName, page in pairs(handlerOptionPages) do
		page:UpdateFrameGroup(CURRENT_FRAME_GROUP);
	end
	
	-- Update frame group of positioning menu parts:
	local database = ArenaLive:GetDBComponent(addonName, CURRENT_SHOWN_HANDLER, CURRENT_FRAME_GROUP);
	if ( database and database.Position ) then
		ALUF_UnitFrameOptions:UpdatePositioningGroup(CURRENT_FRAME_GROUP);
		ALUF_UnitFrameOptions:UpdatePositioningHandler(CURRENT_SHOWN_HANDLER);
		ALUF_UnitFrameOptionsHandlerFramePositionText:Show();
		ALUF_UnitFrameOptionsHandlerFramePositionText:SetText(string.format(L["%s Position:"], L[CURRENT_SHOWN_HANDLER]));
		ALUF_UnitFrameOptions:ShowPositioningHandler();
	else
		ALUF_UnitFrameOptions:HidePositioningHandler();
	end
end

function ALUF_UnitFrameOptions:UpdateActiveHandler(newHandlerName)
	
	-- Hide last shown handler:
	local page;
	if ( CURRENT_SHOWN_HANDLER ) then
		page = handlerOptionPages[CURRENT_SHOWN_HANDLER];
		page:Hide();
	end
	
	-- Show New Page:
	CURRENT_SHOWN_HANDLER = newHandlerName;
	page = handlerOptionPages[CURRENT_SHOWN_HANDLER];
	ALUF_UnitFrameOptionsHandlerFrameTitle:SetText(page.title);
	page:Show();
	
	
	-- Frame positioning menu items:
	if ( CURRENT_SHOWN_HANDLER == "UnitFrame" ) then
		ALUF_UnitFrameOptionsHandlerFramePositionText:Show();
		ALUF_UnitFrameOptionsHandlerFramePositionText:SetText(string.format(L["%s Position:"], L["Unit Frame"]));
	else
		ALUF_UnitFrameOptionsHandlerFramePositionText:Hide();
	end
	
	local database = ArenaLive:GetDBComponent(addonName, CURRENT_SHOWN_HANDLER, CURRENT_FRAME_GROUP);
	if ( database.Position ) then
		ALUF_UnitFrameOptions:UpdatePositioningGroup(CURRENT_FRAME_GROUP);
		ALUF_UnitFrameOptions:UpdatePositioningHandler(CURRENT_SHOWN_HANDLER);
		ALUF_UnitFrameOptionsHandlerFramePositionText:Show();
		ALUF_UnitFrameOptionsHandlerFramePositionText:SetText(string.format(L["%s Position:"], L[CURRENT_SHOWN_HANDLER]));
		ALUF_UnitFrameOptions:ShowPositioningHandler();
	else
		ALUF_UnitFrameOptions:HidePositioningHandler();
	end
end

local mt = { __index = PageClass };
function ALUF_UnitFrameOptions:ConstructHandlerPage(handlerName)
	if ( handlerOptionPages[handlerName] ) then
		ArenaLive:Message(L["Couldn't construct handler option page for handler %s, because there is already a page for that handler!"], "error", handlerName);
		return;
	end
		
	local page = {};
	page.frames = {};
	handlerOptionPages[handlerName] = page;
	page.name = handlerName;
	setmetatable(page, mt);

	--ArenaLive:Message(L["New option page constructed for handler %s!"], "debug", handlerName);
	return page;
end

function ALUF_UnitFrameOptions:DestroyHandlerPage(handlerName)
	if ( not handlerOptionPages[handlerName] ) then
		ArenaLive:Message(L["Couldn't destroy handler option page for handler %s, because there is now option page for that handler!"], "error", handlerName);
		return;
	end
	
	table.wipe(handlerOptionPages[handlerName]["frames"]);
	handlerOptionPages[handlerName]["frames"] = nil;
	table.wipe(handlerOptionPages[handlerName]);
	handlerOptionPages[handlerName] = nil;
end


--[[
*************************************************
********* PAGE CLASS METHODS START HERE *********
*************************************************
]]--
function PageClass:GetActiveFrameGroup()
	return CURRENT_FRAME_GROUP;
end

function PageClass:Show()
	for frame in pairs(self.frames) do
		frame:Show();
	end
end

function PageClass:Hide()
	for frame in pairs(self.frames) do
		frame:Hide();
	end
end

function PageClass:UpdateFrameGroup()
	
	local database = ArenaLive:GetDBComponent(addonName, nil, CURRENT_FRAME_GROUP);
	for frame in pairs(self.frames) do
		if ( frame.handler == "FrameMover" ) then
			frame.group = ArenaLiveUnitFrames.frameGroupToFrame[CURRENT_FRAME_GROUP];
			frame:UpdateShownValue();
		elseif ( database[frame.handler] ) then
				local frameName = frame:GetName();
				if ( self.name ~= "TargetFrame" and self.name ~= "PetFrame" ) then
					frame.group = CURRENT_FRAME_GROUP;
				end
				frame:UpdateShownValue();
		end
	end
end

function PageClass:RegisterFrame(frame)
	self.frames[frame] = true;
end

function PageClass:UnregisterFrame(frame)
	self.frames[frame] = nil;
end