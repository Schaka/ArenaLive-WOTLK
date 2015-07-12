--[[ ArenaLive Core Functions: Icon Group Header Handler
Created by: Vadrak
Creation Date: 11.04.2014
Last Update: 27.04.2014
This handler is used to dynamically adjust anchor points for groups of elements (mainly icons like role icon etc.).
]]--

-- ArenaLive addon Name and localisation table:
local addonName, L = ...;

--[[
**************************************************
******* GENERAL HANDLER SET UP STARTS HERE *******
**************************************************
]]--
-- Create handler:
local IconGroupHeader = ArenaLive:ConstructHandler("IconGroupHeader", false, false, false);

-- Create table that stores all icon groups:
local iconGroups = {};

local X_OFFSET = 3;
local Y_OFFSET = 3;
--[[
**************************************************
******* GENERAL HANDLER SET UP STARTS HERE *******
**************************************************
]]--
function IconGroupHeader:ConstructGroup(groupName, direction, offset, point, relativeTo, relativePoint, xOffset, yOffset)
	
	ArenaLive:CheckArgs(groupName, "string");

	if ( not iconGroups[groupName] ) then
		iconGroups[groupName] = {};
		iconGroups[groupName]["direction"] = direction or "RIGHT";
		iconGroups[groupName]["offset"] = offset;
		iconGroups[groupName]["point"] = point;
		iconGroups[groupName]["relativeTo"] = relativeTo;
		iconGroups[groupName]["relativePoint"] = relativePoint;
		iconGroups[groupName]["xOffset"] = xOffset;
		iconGroups[groupName]["yOffset"] = yOffset;
	else
		ArenaLive:Message(L["Couldn't construct new icon group, because a group with the name %s already exists!"], "error", groupName);
	end
end

function IconGroupHeader:Update(groupName)
	
	local lastShownIndex;
	for index, icon in ipairs(iconGroups[groupName]) do
		if ( icon:IsShown() ) then
			local point, relativeTo, relativePoint, xOffset, yOffset;
			if ( lastShownIndex ) then	
				if ( iconGroups[groupName]["direction"] == "LEFT" ) then
					point = "RIGHT";
					relativePoint = "LEFT";
					xOffset = -iconGroups[groupName]["offset"] or -X_OFFSET;
					yOffset = 0;
				elseif ( iconGroups[groupName]["direction"] == "RIGHT" ) then
					point = "LEFT";
					relativePoint = "RIGHT";
					xOffset = iconGroups[groupName]["offset"] or X_OFFSET;
					yOffset = 0;
				elseif ( iconGroups[groupName]["direction"] == "UP" ) then
					point = "BOTTOM";
					relativePoint = "TOP";
					xOffset = 0;
					yOffset = iconGroups[groupName]["offset"] or Y_OFFSET;
				elseif ( iconGroups[groupName]["direction"] == "DOWN" ) then
					point = "TOP";
					relativePoint = "BOTTOM";
					xOffset = 0;
					yOffset = -iconGroups[groupName]["offset"] or -Y_OFFSET;
				end
					
					relativeTo = iconGroups[groupName][lastShownIndex];
			else
					-- This is the first icon of the group that is shown, so set the position the initial ones:
					point, relativeTo, relativePoint, xOffset, yOffset = iconGroups[groupName]["point"], iconGroups[groupName]["relativeTo"], iconGroups[groupName]["relativePoint"] , iconGroups[groupName]["xOffset"] , iconGroups[groupName]["yOffset"];
			end
				
			icon:ClearAllPoints();
			icon:SetPoint(point, relativeTo, relativePoint, xOffset, yOffset);
			lastShownIndex = index;
		end
	end

end

function IconGroupHeader:AddIconToGroup(groupName, icon, index)

	if ( iconGroups[groupName] ) then
		if ( index ) then
			table.insert(iconGroups[groupName], index, icon);
		else
			table.insert(iconGroups[groupName], icon);
		end
		icon.id = index or #iconGroups[groupName];
		icon.group = groupName;
		IconGroupHeader:Update(groupName);
	else
		ArenaLive:Message(L["Couldn't add icon to icon group, because a group with the name %s doesn't exist!"], "error", groupName);
	end

end

function IconGroupHeader:RemoveIconFromGroup(icon)
	local index = icon.id;
	local groupName = icon.group;
	table.remove(iconGroups[groupName], index);
end