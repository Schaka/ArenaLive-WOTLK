--[[ ArenaLive Core Functions: Master Looter Icon Handler
Created by: Vadrak
Creation Date: 01.05.2014
Last Update: "
This file contains all relevant functions for multi group icons.
Unfortunately the structure of this icon is too complex for the IndicatorIcon class.
]]--

-- ArenaLive addon Name and localisation table:
local addonName, L = ...;

--[[
**************************************************
******* GENERAL HANDLER SET UP STARTS HERE *******
**************************************************
]]--
local MultiGroupIcon = ArenaLive:ConstructHandler("MultiGroupIcon", true, false, false);
local IconGroupHeader =  ArenaLive:GetHandler("IconGroupHeader");

-- Register the handler for all needed events:
MultiGroupIcon:RegisterEvent("GROUP_ROSTER_UPDATE");
MultiGroupIcon:RegisterEvent("UPDATE_CHAT_COLOR");



--[[
****************************************
****** OBJECT METHODS START HERE ******
****************************************
]]--
local function OnEnter(multiGroupIcon)
	GameTooltip_SetDefaultAnchor(GameTooltip, multiGroupIcon);
	multiGroupIcon.homePlayers = GetHomePartyInfo(multiGroupIcon.homePlayers);

	if ( IsInRaid(LE_PARTY_CATEGORY_HOME) ) then
		GameTooltip:SetText(PLAYER_IN_MULTI_GROUP_RAID_MESSAGE, nil, nil, nil, nil, true);
		GameTooltip:AddLine(format(MEMBER_COUNT_IN_RAID_LIST, #multiGroupIcon.homePlayers + 1), 1, 1, 1, true);
	else
		GameTooltip:AddLine(PLAYER_IN_MULTI_GROUP_PARTY_MESSAGE, 1, 1, 1, true);
		local playerList = multiGroupIcon.homePlayers[1] or "";
		for i=2, #multiGroupIcon.homePlayers do
			playerList = playerList..PLAYER_LIST_DELIMITER..multiGroupIcon.homePlayers[i];
		end
		GameTooltip:AddLine(format(MEMBERS_IN_PARTY_LIST, playerList));
	end
	
	GameTooltip:Show();
end

local function OnLeave(multiGroupIcon)
	GameTooltip:Hide();
end



--[[
****************************************
****** HANDLER METHODS START HERE ******
****************************************
]]--
function MultiGroupIcon:ConstructObject (multiGroupIcon, homePartyIcon, instancePartyIcon, groupName, groupIndex)
	ArenaLive:CheckArgs(multiGroupIcon, "Button", homePartyIcon, "Texture", instancePartyIcon, "Texture");
	
	if ( groupName ) then
		IconGroupHeader:AddIconToGroup(groupName, multiGroupIcon, groupIndex);
	end

	-- Set references for textures.
	multiGroupIcon.homePartyIcon = homePartyIcon;
	multiGroupIcon.instancePartyIcon = instancePartyIcon;	
	
	-- Set Scripts:
	multiGroupIcon:SetScript("OnEnter", OnEnter);
	multiGroupIcon:SetScript("OnLeave", OnLeave);
end

function MultiGroupIcon:Update(unitFrame)
	
	local multiGroupIcon = unitFrame[self.name];
	if ( 1 ~= 1 ) then
		MultiGroupIcon:UpdateColour(multiGroupIcon);
		multiGroupIcon:Show();
	else
		multiGroupIcon:Hide();
	end
end

local public, private;
function MultiGroupIcon:UpdateColour(multiGroupIcon)
	public = ChatTypeInfo["RAID"];
	private = ChatTypeInfo["PARTY"];
	multiGroupIcon.homePartyIcon:SetVertexColor(private.r, private.g, private.b);
	multiGroupIcon.instancePartyIcon:SetVertexColor(public.r, public.g, public.b);
end

function MultiGroupIcon:Reset(multiGroupIcon)
	multiGroupIcon:Hide();
end

function MultiGroupIcon:OnEvent(event, ...)
	if ( event == "GROUP_ROSTER_UPDATE" ) then
		for id, unitFrame in ArenaLive:GetAllUnitFrames() do
			if ( unitFrame[self.name] ) then
				MultiGroupIcon:Update(unitFrame);
			end
		end	
	elseif ( event == "UPDATE_CHAT_COLOR" ) then
		for id, unitFrame in ArenaLive:GetAllUnitFrames() do
			if ( unitFrame[self.name] ) then
				MultiGroupIcon:UpdateColour(unitFrame[self.name]);
			end
		end	
	end
end