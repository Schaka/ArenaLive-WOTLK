--[[ ArenaLive Core Functions: Positioning Grid
Created by: Vadrak
Creation Date: 05.06.2014
Last Update: 06.06.2014
This handler is used to set up a horizontal and a vertical line in order to make it easier to position frames.
NOTE: The frames for both lines are defined in the ArenaLive.xml as children of ArenaLive frame.
]]--

-- Get addon name and the localisation table:
local addonName, L = ...;

local Grid = ArenaLive:ConstructHandler("Grid", true, true);
Grid:RegisterEvent("UI_SCALE_CHANGED");
Grid:RegisterEvent("DISPLAY_SIZE_CHANGED");

-- Option frame set ups:
Grid.optionSets = {
	["Shown"] = {
		["type"] = "CheckButton",
		["title"] = L["Show Grid"],
		["tooltip"] = L["Shows a vertical and a horizontal line that can both be moved. This makes it easier to position frames accurately."],
		["GetDBValue"] = function (frame) local database = ArenaLive:GetDBComponent(addonName, "Grid"); return database.Shown;  end,
		["SetDBValue"] = function (frame, newValue) local database = ArenaLive:GetDBComponent(addonName, "Grid"); database.Shown = newValue;  end,
		["postUpdate"] = function (frame, newValue, oldValue) Grid:ToggleGridVisibility(); end,
	},
};

local CURRENT_DRAGGED;
local function OnDragStart (line)
	line:StartMoving();
	CURRENT_DRAGGED = line;
	GameTooltip:Show();
	Grid:Show();
end

local function OnDragStop (line)
	line:StopMovingOrSizing();
	line:SetUserPlaced(false);
	Grid:Hide();
	GameTooltip:Hide();
	CURRENT_DRAGGED = nil;
end

function ArenaLive:InitializeGrid()
	
	ArenaLiveVerticalLine.direction = "VERTICAL";
	ArenaLiveVerticalLine:RegisterForDrag("LeftButton");
	ArenaLiveVerticalLine:SetMovable(true);
	ArenaLiveVerticalLine:SetClampedToScreen(true);
	ArenaLiveVerticalLine:SetScript("OnDragStart", OnDragStart);
	ArenaLiveVerticalLine:SetScript("OnDragStop", OnDragStop);
	
	ArenaLiveHorizontalLine.direction = "HORIZONTAL";
	
	ArenaLiveHorizontalLine:RegisterForDrag("LeftButton");
	ArenaLiveHorizontalLine:SetMovable(true);
	ArenaLiveHorizontalLine:SetClampedToScreen(true);
	ArenaLiveHorizontalLine:SetScript("OnDragStart", OnDragStart);
	ArenaLiveHorizontalLine:SetScript("OnDragStop", OnDragStop);
	Grid:ToggleGridVisibility();
end

function Grid:UpdateSizes()
	local width, height = UIParent:GetSize();
	ArenaLiveVerticalLine:SetHeight(height);
	ArenaLiveHorizontalLine:SetWidth(width);
	Grid:ResetGridPosition();
end

function Grid:ToggleGridVisibility()
	local database = ArenaLive:GetDBComponent(addonName, self.name);
	
	if ( database.Shown ) then
		ArenaLiveVerticalLine:Show();
		ArenaLiveHorizontalLine:Show();	
	else
		ArenaLiveVerticalLine:Hide();
		ArenaLiveHorizontalLine:Hide();
	end
end

function Grid:ResetGridPosition()
	ArenaLiveHorizontalLine:ClearAllPoints();
	ArenaLiveHorizontalLine:SetPoint("CENTER");
	ArenaLiveVerticalLine:ClearAllPoints();
	ArenaLiveVerticalLine:SetPoint("CENTER");
end

function Grid:OnEvent(event, ...)
	Grid:UpdateSizes();
end

function Grid:OnUpdate(elapsed)
	if ( CURRENT_DRAGGED ) then
		local axis, point, left, bottom;
		left = CURRENT_DRAGGED:GetLeft();
		bottom = CURRENT_DRAGGED:GetBottom();
		if ( CURRENT_DRAGGED.direction == "VERTICAL" ) then
			axis = "x";
			point = left;
			CURRENT_DRAGGED:ClearAllPoints();
			CURRENT_DRAGGED:SetPoint("BOTTOMLEFT", nil, "BOTTOMLEFT", left, 0);
		elseif ( CURRENT_DRAGGED.direction == "HORIZONTAL" ) then
			axis = "y";
			point = bottom;
			CURRENT_DRAGGED:ClearAllPoints();
			CURRENT_DRAGGED:SetPoint("BOTTOMLEFT", nil, "BOTTOMLEFT", 0, bottom);			
		end
		point = math.ceil(point);
		GameTooltip:SetOwner(self, "ANCHOR_CURSOR");
		GameTooltip:SetText(string.format(L["%s = %s"], axis, point));
	end
end
Grid:Hide();
Grid:SetScript("OnUpdate", Grid.OnUpdate);