--[[ ArenaLive Core Functions: Portrait Handler
Created by: Vadrak
Creation Date: 06.04.2014
Last Update: 17.05.2014
This file stores the function for unit portraits. It can show class icons or three dimensional portraits. 
]]--

-- ArenaLive addon Name and localisation table:
local addonName, L = ...;

--[[
**************************************************
******* GENERAL HANDLER SET UP STARTS HERE *******
**************************************************
]]--

-- Create new Handler and register for all important events:
local Portrait = ArenaLive:ConstructHandler("Portrait", true, false);
Portrait:RegisterEvent("UNIT_PORTRAIT_UPDATE");



--[[
****************************************
****** HANDLER METHODS START HERE ******
****************************************
]]--
--[[ Method: ConstructObject
	 Creates a new portrait frame.
		portrait (Frame): The frame that is going to be set up as a portrait frame.
		texture (Texture): A texture that will be used to show the class icon.
		threeDFrame (PlayerModel): A frame of the type PlayerModel that will show the three dimensional portrait.
		unitFrame (Frame): The unit frame the portrait belongs to. This is used to set the OnUpdate script. 
]]--
function Portrait:ConstructObject(portrait, background, texture, threeDFrame, unitFrame)

	ArenaLive:CheckArgs(portrait, "table", texture, "table", threeDFrame, "table", unitFrame, "Button");
	
	-- Set fram references:
	portrait.background = background;
	portrait.texture = texture;
	portrait.threeD = threeDFrame;

	-- Set OnShow script:
	-- The OnShow event is used, because some times the portrait won't update correctly for "target" otherwise
	-- TODO: The current function is a temporary fix. Need to change that in the future.
	portrait:SetScript("OnShow", function() Portrait:Update(unitFrame) end);
end

--[[ Method: Update
	 Updates new portrait frame.
		unitFrame (Frame): The unit frame that is affected by the change.
]]--
function Portrait:Update(unitFrame)
	local unit = unitFrame.unit;
	
	if ( not unit ) then
		return;
	end
	
	local portrait = unitFrame[self.name];
	local database = ArenaLive:GetDBComponent(unitFrame.addon, self.name, unitFrame.group);
	local portraitType = database.Type;
	
	if ( portraitType == "class" ) then
		local _, class;
		if ( unitFrame.test ) then
			class = ArenaLive.testModeValues[unitFrame.test]["class"];
		else
			_, class = UnitClass(unit);
		end
		
		local unitType = string.match(unit, "^([a-z]+)[0-9]+$") or unit;
		local unitNumber = tonumber(string.match(unit, "^[a-z]+([0-9]+)$"));
		local isPlayer = UnitIsPlayer(unit);

		if ( class and ( isPlayer or unitFrame.test ) ) then
		
			-- Show class icon for players:
			portrait.threeD:Hide();
			
			portrait.texture:SetTexture("Interface\\Glues\\CharacterCreate\\UI-CharacterCreate-Classes");
			portrait.texture:SetTexCoord(unpack(CLASS_ICON_TCOORDS[class]));
			portrait.texture:Show();
			
		elseif ( unitType == "arena" and unitNumber ) then
			
			-- Inside the arena we can get the class via GetArenaOpponentSpec() and GetSpecializationInfoByID() before the gates open.
			local numOpps = --[[GetNumArenaOpponentSpecs();]] nil;
			
			if ( numOpps and unitNumber and unitNumber <= numOpps ) then
				local specID = GetArenaOpponentSpec(unitNumber)
				local _, _, _, _, _, _, class = GetSpecializationInfoByID(specID)
				
				if ( class ) then
					portrait.threeD:Hide();
					
					portrait.texture:SetTexture("Interface\\Glues\\CharacterCreate\\UI-CharacterCreate-Classes");
					portrait.texture:SetTexCoord(unpack(CLASS_ICON_TCOORDS[class]));
					portrait.texture:Show();
				else
					Portrait:Reset(unitFrame);
				end
			else
				Portrait:Reset(unitFrame);
			end
			
		elseif (not isPlayer ) then
		
			-- If the unit is a NPC we fall back to 3D-Portrait.
			portrait.texture:Hide();
			
			portrait.threeD:SetUnit(unit);
			portrait.threeD:SetCamera(0);
			portrait.threeD:Show();
			
			if ( type(portrait.threeD:GetModel()) ~= "string" or portrait.threeD:GetModel() == "" ) then
				-- No model shown, probably because the unit is too far away from the player. Use the question mark icon instead:
				Portrait:Reset(unitFrame);
			end
		end	
	elseif ( portraitType == "twoD" ) then
		portrait.threeD:Hide();
		portrait.texture:SetTexCoord(0, 1, 0, 1);
		
		if ( unitFrame.test ) then
			SetPortraitTexture(portrait.texture, "player");
		else
			SetPortraitTexture(portrait.texture, unit);
		end
		
		portrait.texture:Show();
	elseif ( portraitType == "threeD" ) then

		portrait.texture:Hide();
		portrait.threeD:Show();
		
		if ( unitFrame.test ) then
			-- Show player when in test mode, because player model is always visible.
			portrait.threeD:SetUnit("player");
		else
			portrait.threeD:SetUnit(unit);
		end
		portrait.threeD:SetCamera(0);	
		
		-- No model shown, probably because the unit is too far away from the player. Use the question mark icon instead:
		if ( type(portrait.threeD:GetModel()) ~= "string" or portrait.threeD:GetModel() == "" ) then
			Portrait:Reset(unitFrame);
		end
	else
		Portrait:Reset(unitFrame);
	end

end

function Portrait:Reset(unitFrame)
	local portrait = unitFrame[self.name];
	portrait.threeD:Hide();
	
	portrait.texture:SetTexCoord(0, 1, 0, 1);
	portrait.texture:SetTexture("Interface\\Icons\\INV_Misc_QuestionMark");
	portrait.texture:Show();
end

function Portrait:OnEvent(event, ...)
	local unit = ...;
	if ( ArenaLive:IsUnitInUnitFrameCache(unit) ) then
		for id in ArenaLive:GetAffectedUnitFramesByUnit(unit) do
			local unitFrame = ArenaLive:GetUnitFrameByID(id);
			if ( unitFrame[self.name] ) then
				Portrait:Update(unitFrame);
			end
		end
	end
end

Portrait.optionSets = {
	["Type"] = {
		["type"] = "DropDown",
		["width"] = 100,
		["title"] = L["Portrait Type"],
		["emptyText"] = L["Choose the portrait type for the unit frame's character portrait."],
		["infoTable"] = {
			[1] = {
				["value"] = "class",
				["text"] = L["Class Icon"],
			},
			[2] = {
				["value"] = "threeD",
				["text"] = L["3D Portrait"],
			},
			[3] = {
				["value"] = "twoD",
				["text"] = L["2D Portrait"],
			},
		},
		["GetDBValue"] = function (frame) 
			local database = ArenaLive:GetDBComponent(frame.addon, frame.handler, frame.group);
			return database.Type; 
		end,
		["SetDBValue"] = function (frame, newValue)
			local database = ArenaLive:GetDBComponent(frame.addon, frame.handler, frame.group);
			database.Type = newValue;
		end,
		["postUpdate"] = function (frame, newValue, oldValue)
			for id, unitFrame in ArenaLive:GetAllUnitFrames() do 
				if ( unitFrame.addon == frame.addon and unitFrame.group == frame.group and unitFrame[frame.handler] ) then 
					Portrait:Update(unitFrame);
				end
			end 
		end,
	},
};