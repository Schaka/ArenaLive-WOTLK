--[[ ArenaLive Core Functions: IndicatorIcon
Created by: Vadrak
Creation Date: 17.05.2014
Last Update: 18.05.2014
This handler basically is a base class for all handlers that show an icon that indicates information about a unit. (e.g. role, pvp status etc.)
]]--

-- ArenaLive addon Name and localisation table:
local addonName, L = ...;

--[[
**************************************************
******* GENERAL HANDLER SET UP STARTS HERE *******
**************************************************
]]--
local IndicatorIcon = ArenaLive:ConstructHandler("IndicatorIcon");
local IconGroupHeader =  ArenaLive:GetHandler("IconGroupHeader");


--[[
****************************************
****** HANDLER METHODS START HERE ******
****************************************
]]--
function IndicatorIcon:ConstructObject(icon, groupName, groupIndex, addonName, frameType, ...)
	
	if ( groupName ) then
		IconGroupHeader:AddIconToGroup(groupName, icon, groupIndex);
	end
	
	if ( self.Constructor ) then
		self:Constructor(icon, ...);
	end
	
	self:UpdateSettings(icon, addonName, frameType);	
end

function IndicatorIcon:Update(unitFrame)
	
	local icon = unitFrame[self.name];
	
	-- Update icon texture:
	local texture, coordLeft, coordRight, coordTop, coordBottom = self:GetTexture(unitFrame);
	if ( icon.texture ) then
		icon.texture:SetTexture(texture);
		icon.texture:SetTexCoord(coordLeft, coordRight, coordTop, coordBottom);
	else
		icon:SetTexture(texture);
		icon:SetTexCoord(coordLeft, coordRight, coordTop, coordBottom);
	end
	
	-- Update icon visibility:
	local isShown = self:GetShown(unitFrame);
	if ( isShown ) then
		icon:Show(isShown);
	else
		icon:Hide();
	end
	
	-- Update the icons group, if there is one:
	if ( icon.group ) then
		IconGroupHeader:Update(icon.group);
	end

end

function IndicatorIcon:Reset(unitFrame)
	local icon = unitFrame[self.name];
	icon:Hide();
	
	-- Update the icons group, if there is one:
	if ( icon.group ) then
		IconGroupHeader:Update(icon.group);
	end	
end

function IndicatorIcon:UpdateSettings (icon, addonName, frameType)
	local database = ArenaLive:GetDBComponent(addonName, self.name, frameType);
	local size = database.Size;
	icon:SetSize(size, size);
end