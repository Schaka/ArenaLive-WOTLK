--[[ ArenaLive Core Functions: Cooldown Handler
Created by: Vadrak
Creation Date: 05.04.2014
Last Update: "
These functions are used to set up cooldown display, so cooldowns can show a text with the remaining time.
]]--

-- ArenaLive addon Name and localisation table:
local addonName, L = ...;

--[[
**************************************************
******* GENERAL HANDLER SET UP STARTS HERE *******
**************************************************
]]--
-- Create new Handler and a cache storing all cooldown frames:
local Cooldown = ArenaLive:ConstructHandler("Cooldown", true, true);
local Cooldowns = {};

Cooldown:RegisterEvent("CVAR_UPDATE");

Cooldown.optionSets = {
	["ShowText"] = {
		["type"] = "CheckButton",
		["title"] = L["Show Cooldown Text"],
		["tooltip"] = L["Shows a timer text for cooldowns. Disable this to enable support for cooldown count addons."],
		["GetDBValue"] = function (frame) local database = ArenaLive:GetDBComponent(frame.addon, "Cooldown"); return database.ShowText; end,
		["SetDBValue"] = function (frame, newValue) local database = ArenaLive:GetDBComponent(frame.addon, "Cooldown"); database.ShowText = newValue; end,
		["postUpdate"] = function (frame, newValue, oldValue) for cooldown in pairs(Cooldowns) do if ( cooldown.addon == frame.addon ) then Cooldown:SetTextMode(cooldown); end end end,
	},
};
--[[
****************************************
******* CLASS METHODS START HERE *******
****************************************
]]--
-- Create base class for Cooldowns:
local CooldownClass = {};
--[[ Method: Set
	 Start a cooldown.
		cooldown (frame [Cooldown]): Affected cooldown frame.
]]--
function CooldownClass:Set (startTime, duration)
	local remaining = duration - (GetTime() - startTime);
	self.remaining = remaining;
	self.elapsed = 0;
	self:SetCooldown(startTime, duration);
	self:Update();	
	Cooldown.activeCDs[self] = true;
	self:Show();
end

--[[ Method: Update
	 Update cooldown text, if there is one.
		cooldown (frame [Cooldown]): Affected cooldown frame.
]]--
function CooldownClass:Update()

	if ( not self.text ) then
		return;
	end
	
	if ( self.remaining > 0 and self.showText ) then
		self.text:Show();
		self.text:SetText(Cooldown:FormatText(self.remaining));
	else
		self.text:Hide();
	end

end

--[[ Method: Reset
	 Reset cooldown and cooldown text, if there is one.
		cooldown (frame [Cooldown]): Affected cooldown frame.
]]--
function CooldownClass:Reset ()
	Cooldown.activeCDs[self] = nil;
	self.remaining = 0;
	self.elapsed = 0;
	--self:SetCooldown(0, 0);
	self:Hide();
	
	if ( self.text ) then
		self.text:SetText("");
	end
end

--[[
****************************************
****** HANDLER METHODS START HERE ******
****************************************
]]--
--[[ Method: ConstructObject
	 Creates a new frame of the type cooldown.
		ARGUMENTS:
			cooldown (frame [Cooldown]): The frame that is going to be set up as a cooldown.
			addonName (string): Name of the addon the cooldown belongs. This is needed in order to retrieve cooldown settings from the addon's database.
			parent (frame [optional]): The frame to which the cooldown belongs to. (e.g. an aura icon etc.)
			cooldownText (fontString [optional]): FontString that'll show the remaing cooldown time.
			textSize (number [optional]): It is possible to set a static size for the cooldown text that will always be used regardless of other settings in the saved variables.
]]--
function Cooldown:ConstructObject(cooldown, addonName, parent, cooldownText, textSize)

	ArenaLive:CheckArgs(cooldown, "Cooldown", addonName, "string");
	
	-- If this is the first cooldown object constructed, start OnUpdate script for the Cooldown handler:
	if ( not Cooldown:GetScript("OnUpdate") ) then
		Cooldown:SetScript("OnUpdate", Cooldown.OnUpdate);
	end
	
	-- Create a reference for the cooldown in parent frame:
	if ( parent ) then
		parent.cooldown = cooldown;
	end
	
	--[[ Check if cooldownText exists, because the reference can also be set via parentKey="" in the xml template.
		 This way we don't overwrite it with nil.
	]]
	if ( cooldownText ) then
		cooldown.text = cooldownText;
	end
		
	-- Set basic values:
	cooldown.addon = addonName;
	cooldown.remaining = 0;
	cooldown.textSize = textSize;
	
	-- Set up methods:
	ArenaLive:CopyClassMethods(CooldownClass, cooldown);
	
	-- Update Size if size of the cooldown element.
	local width, height = cooldown:GetSize();
	if ( width == 0 and height == 0 and parent ) then
		-- BUFIX: If size and height is 0, try to use parent's size, because it seems like setAllPoints doesn't work for LUA created cooldown frames for some reason (at least for me):
		width, height = parent:GetSize();
		cooldown:SetSize(width, height);
	end	
	
	-- Initially set font size and text mode according to saved variables:
	Cooldown:SetTextMode(cooldown);
	Cooldown:UpdateTextSize(cooldown);
	
	-- Add to Cooldowns table:
	Cooldowns[cooldown] = true;
end

--[[ Method: SetTextMode
	 Changes the text mode for the cooldown, i.e. shows or hides the cooldown text depending on an database entry..
		cooldown (frame [Cooldown]): The affected cooldown frame.
]]--
function Cooldown:SetTextMode(cooldown)
	local database = ArenaLive:GetDBComponent(cooldown.addon, self.name);
	if ( database.ShowText ) then
		-- Block cooldown count addons and Blizzard's cooldown count from showing their cooldown text, ArenaLive's is enbaled.
		--cooldown:SetHideCountdownNumbers(true);
		cooldown.noCooldownCount = 1;
	else
		--cooldown:SetHideCountdownNumbers(false);
		cooldown.noCooldownCount = nil;
	end
	
	if ( cooldown.text ) then
		cooldown.showText = database.ShowText;
		cooldown:Update();
	else
		cooldown.showText = nil;
		cooldown.noCooldownCount = nil;
	end	
end

--[[ Method: UpdateTextSize
	 Changes the text size for the cooldown depending on saved variables or cooldown height.
		cooldown (frame [Cooldown]): The affected cooldown frame.
]]--
function Cooldown:UpdateTextSize(cooldown)
	
	if ( cooldown.text ) then
		local size;
		local database = ArenaLive:GetDBComponent(cooldown.addon, self.name);
		local staticSize = database.StaticSize;
		local textSize = database.TextSize;
	
		if ( cooldown.textSize ) then
			size = cooldown.textSize;
		elseif ( staticSize ) then
			size = textSize;
		else
			local width, height = cooldown:GetSize();
			if ( width < height ) then
				size = width;
			else
				size = height;
			end

			size = math.floor(size / 2 );
			
			-- BUGFIX: In case size is 0 we use the static text size instead:
			if ( size == 0 ) then
				size = textSize;
			end
		end
		
		--local filename, _, flags = cooldown.text:GetFont();
		cooldown.text:SetFont("Fonts\\FRIZQT__.TTF", size);	
	end

end

--[[ Method: FormatText
	 This function formats the cooldown time based on cooldown length.
		cooldownTime (number): The remaining cooldown time.
	 RETURNS:
		cooldownTimeText (string): The formated cooldown text.
]]--
function Cooldown:FormatText(cooldownTime)

	if ( not cooldownTime ) then
		return;
	end

	local cooldownTimeText;
	local timeType = "seconds";
	local decimal;
	
	-- Minutes
	if ( cooldownTime > 59 ) then
	
		cooldownTime = cooldownTime / 60;
		timeType = "minutes"
		
		-- Hours
		if ( cooldownTime > 60 ) then
			cooldownTime = cooldownTime / 60;
			timeType = "hours"
		end
		
		-- We need to round up or down correctly on this one.
		decimal = math.floor(cooldownTime * 10);
		decimal =  tonumber(string.sub(decimal, -1));
		
		if ( decimal < 5 ) then
			cooldownTime = math.floor(cooldownTime);
		else
			cooldownTime = math.ceil(cooldownTime);
		end

	else
		if (cooldownTime < 10 and math.floor(cooldownTime) > 0 ) then
			decimal = (math.floor(cooldownTime*10));
			cooldownTime = string.sub(decimal, 1, -2);
			cooldownTime = cooldownTime..".";
			cooldownTime = cooldownTime..string.sub(decimal, -1);
			return cooldownTime;
		end
			
		if (math.floor(cooldownTime) == 0 ) then
			cooldownTime = string.sub(cooldownTime, 1, 3);
		else
			cooldownTime = math.floor(cooldownTime)
		end
	end
	
	if ( timeType == "hours" ) then
		cooldownTimeText = cooldownTime..L["HOUR_ABBR"];
	elseif ( timeType == "minutes" ) then 
		cooldownTimeText = cooldownTime..L["MINUTE_ABBR"];
	else
		if ( tonumber(cooldownTime) <= 0 ) then
			cooldownTimeText = "";
		else
			cooldownTimeText = cooldownTime;
		end
	end
	
	return cooldownTimeText;

end

function Cooldown:OnEvent(event, ...)
	local filter = ...;
	if ( event == "CVAR_UPDATE" and filter == "COUNTDOWN_FOR_COOLDOWNS_TEXT" ) then
		for cooldown in pairs(Cooldowns) do
			Cooldown:SetTextMode(cooldown);
		end
	end
end

--[[ Method: OnUpdate
	 OnUpdate script for all active cooldowns. This script is throttled to update once every 0.1 sec to reduce needed performance.
		elapsed: Time elapsed since the frame was drawn for the last time.
]]--
Cooldown.activeCDs = {};
Cooldown.elapsed = 0;
function Cooldown:OnUpdate (elapsed)

	Cooldown.elapsed = Cooldown.elapsed + elapsed;
	
	if ( Cooldown.elapsed > 0.1 ) then
		local elapsed = Cooldown.elapsed;
		Cooldown.elapsed = 0;
		
		for cooldown in pairs(Cooldown.activeCDs) do
			cooldown.remaining = cooldown.remaining - elapsed;
			
			
			-- If duration is 0 the cooldown has finished. If the frame is not visible it means that the cooldown isn't needed anymore (e.g. wenn CC is dispelled and PortraitOverlay therefore hidden). 
			if ( ( cooldown.remaining <= 0 ) ) then 
				cooldown:Reset();

			else
				if (cooldown.text and cooldown.showText) then
					cooldown:Update()
				end	
			end
		end
	end
end
