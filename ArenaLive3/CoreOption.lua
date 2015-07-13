--[[ ArenaLive Option Functions
Created by: Vadrak
Creation Date: 03.04.2014
Last Update: 08.06.2014
This file stores all functions needed for setting up option menu objects (edit boxes, drop downs etc).
]]--

function ValueToBoolean(value)
	if (value == 1) then
		return true;
	end

	return false;
end

-- Get addon name and the localisation table:
local addonName, L = ...;

-- Create a table to store ALL the option frames in it so we can disable them when combat starts:
local optionFrames = {};

-- Use this function to add custom frames to the option frame table. They will be disabled during combat lockdown this way.
function ArenaLive:AddCustomOptionFrame(frame)
	optionFrames[frame] = true;
end

-- Create a table to store templates for option types:
local optionTemplates = 
	{
		["Button"] = "OptionsButtonTemplate",
		["CheckButton"] = "OptionsCheckButtonTemplate",
		["EditBox"] = "ArenaLive_OptionsEditBoxTemplate",
		["EditBoxSmall"] = {
			["type"] = "EditBox",
			["template"] = "ArenaLive_OptionsEditBoxSmallTemplate",
		},
		["DropDown"] = {
				["type"] = "Button",
				["template"] = "ArenaLive_OptionsDropDownTemplate",
		},
		["DropDownLargeTitle"] = {
			["type"] = "Button",
			["template"] = "ArenaLive_OptionsDropDownLargeTitleTemplate",			
		},
		["ColourPicker"] = {
			["type"] = "Button",
			["template"] = "ArenaLive_ColourPickerTemplate",
		},
		["Slider"] = "ArenaLive_OptionsSliderTemplate",
		
	}

--[[ Function: UpdateDBEntryByOptionFrame
	 This function updates data base entries based on option frames. If the option frame hasn't stored the most important database information it won't try to update an entry.
	 This way it is possible to use the predefinied option frames also for other things than updating saved variables. Use the postUpdate method for this.
		checkButton (frame): the check button that is calling the function/method.
]]--
local function UpdateDBEntryByOptionFrame(frame, newValue)

	-- Get old DB entry:
	local oldValue = frame:GetDBValue();
		
	-- Set the new variable value in DB:
	frame:SetDBValue(newValue);	
	
	return oldValue;
end	



--[[
**********************************************
********* OBJECT METHODS START HERE **********
**********************************************
]]--
local OptionBaseClass = {};

function OptionBaseClass:OnEnter()

	if ( self.tooltip ) then
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
		if ( self.tooltipTitle ) then
			GameTooltip:SetText(self.tooltipTitle, nil, nil, nil, nil, 1);
			GameTooltip:AddLine(self.tooltip, 1, 1, 1, 1);
		else
			GameTooltip:SetText(self.tooltip, nil, nil, nil, nil, 1);
		end
		GameTooltip:Show();
	end
end

function OptionBaseClass:OnLeave()
	if ( self.tooltip ) then
		GameTooltip:Hide();
	end
end

function OptionBaseClass:OnShow()
	self:UpdateShownValue();
	
	-- Enable/Disable option frame according to combat lockdown:
	if ( InCombatLockdown() ) then
		if ( self:IsEnabled() ) then
			self:EnableMouse(false);
			if ( self:GetObjectType() == "Slider" ) then
				self.curBox:EnableMouse(false);
			end
			self.lockdown = true;
		end
	else
		if ( self.lockdown ) then
			self:EnableMouse(true);
			if ( self:GetObjectType() == "Slider" ) then
				self.curBox:EnableMouse(true);
			end
			self.lockdown = nil;
		end
	end
end

--[[ Function: UpdateShownValue
	 Updates the shown value in case there was a saved variable update that wasn't triggered by the option frame.
	 Also can be used to update after the .addon, .group and/or .handler values of the option frame were changed for some reason.
		ARGUMENTS:
			self (frame): the option frame that will be updated.
]]--
function OptionBaseClass:UpdateShownValue()
	-- Make update function ignore changes to frame's value to prevent corruption of database values:
	self.ignore = true;

	if ( self.type == "CheckButton" ) then
		self:SetChecked(self:GetDBValue());
	elseif ( self.type == "ColourPicker" ) then
		local red, green, blue, alpha = self:GetDBValue();
		self.colour:SetTexture(red, green, blue, alpha or 1);
	elseif ( ( self.type == "DropDown" or self.type == "DropDownLargeTitle" ) and self.info ) then
		local text;
		local value = self:GetDBValue();
		for key, infoData in ipairs(self.info) do
			if ( infoData["value"] == value and ( not self.ignoreKey or not self.ignoreKey[key] ) ) then
				text = infoData["text"];
			end
		end
		
		UIDropDownMenu_SetText(self, text or self.emptyText or "");
	elseif ( self.type == "EditBox" or self.type == "EditBoxSmall" ) then
		self:SetText(self:GetDBValue() or "");
		self:SetCursorPosition(0);
	elseif ( self.type == "Slider" ) then
		self:SetValue(self:GetDBValue());
		self.curBox:SetText(self:GetDBValue());
		self.curBox:SetCursorPosition(0);
	end
	
	self.ignore = nil;
end

-- ******** CHECKBUTTON METHODS: *********
local CheckButtonClass = {};

--[[ Function: CheckButton_OnClick
	 OnClick Method for check buttons.
		self (frame): the check button that is calling the function/method.
]]--
function CheckButtonClass:OnClick ()
	if ( not self.ignore ) then
		local newValue = ValueToBoolean(self:GetChecked());
		
		-- Hand over new value to update function to get old value:
		local oldValue = UpdateDBEntryByOptionFrame(self, newValue);
		
		-- Post update function if necessary:
		if ( type(self.postUpdate) == "function" ) then
			self:postUpdate(newValue, oldValue);
		end
	end
end

-- ********** COLOURPICKER METHODS: **********
local OPEN_COLOUR_PICKER;
local newValue = {};
local function ColourPickerButton_Update(restore)
	
	if ( restore ) then
		newValue.red, newValue.green, newValue.blue, newValue.alpha = unpack(restore);
	else
		newValue.red, newValue.green, newValue.blue = ColorPickerFrame:GetColorRGB();
		newValue.alpha = OpacitySliderFrame:GetValue();
	end
	
	OPEN_COLOUR_PICKER.colour:SetTexture(newValue.red, newValue.green, newValue.blue, newValue.alpha or 1);
	local oldValue = UpdateDBEntryByOptionFrame(OPEN_COLOUR_PICKER, newValue);
	
	if ( type(OPEN_COLOUR_PICKER.postUpdate) == "function" ) then
		OPEN_COLOUR_PICKER:postUpdate(newValue, oldValue);
	end
end

local ColourPickerClass = {};
function ColourPickerClass:OnClick()

	local red, green, blue, alpha = self:GetDBValue();
	ColorPickerFrame.previousValues = {red, green, blue, alpha};
	ColorPickerFrame:SetColorRGB(red, green, blue);
	ColorPickerFrame.func = ColourPickerButton_Update;
	ColorPickerFrame.opacityFunc = ColourPickerButton_Update;
	ColorPickerFrame.cancelFunc = ColourPickerButton_Update;
	
	OPEN_COLOUR_PICKER = self;
	ColorPickerFrame:Hide(); -- Need to run the OnShow handler.
	ColorPickerFrame:Show();
	
end

-- ********** DROPDOWN METHODS: **********
--[[ Function: DropDownButton_OnClick
	 Function  that is triggered when a button in the drop down menu was clicked. You need to add this to the info table when creating buttons for a drop down as info.func.
		button (frame(button)): The button that was clicked in the drop down. 
		arg1 (depends): arg1 as defined in info.arg1 in your refresh function for the drop down.
		arg2 (depends): arg2 as defined in info.arg2 in your refresh function for the drop down.
]]--
local DropDownClass = {};
function DropDownClass:OnClick (button, arg1, arg2)
	
	local dropDown = UIDROPDOWNMENU_OPEN_MENU;
	local valueText = self:GetText();
	local newValue = self.value;
	if ( not dropDown.ignore ) then
		-- Change Drop down text:
		UIDropDownMenu_SetText(dropDown, valueText);
		
		local oldValue = UpdateDBEntryByOptionFrame(dropDown, newValue);
		
		-- Post update function if necessary:
		if ( type(dropDown.postUpdate) == "function" ) then
			dropDown:postUpdate(newValue, oldValue, arg1, arg2);
		end
	end
end

local info = {};
function DropDownClass:Refresh(level, menuList)
	
	local dbValue = self:GetDBValue();
	for key, infoData in ipairs(self.info) do
		-- You can filter certain values for a dropdown via the self.ignoreKey table.
		if ( not self.ignoreKey or not self.ignoreKey[key] ) then
			
			-- Copy info values of this entry:
			for k, v in pairs(infoData) do
				info[k] = v;
			end
			
			-- Delete ignoreGroup table:
			info.ignoreGroup = nil;
			
			-- If the infoTabe doesn't have an OnClick func, use the standard one.
			if ( not info.func ) then
				info.func = self.OnClick;
			end
			
			if ( infoData.value == dbValue ) then
				info.checked = true;
			end
			
			info.fontObject = GameFontHighlightSmall;
			UIDropDownMenu_AddButton(info, level);
			table.wipe(info);
		end
	end
end

-- ********** EDIT BOX METHODS: **********
local EditBoxClass = {};
function EditBoxClass:OnEditFocusGained()
	self:ClearFocus();
end

function EditBoxClass:OnEditFocusLost()
	if ( self:IsEnabled() and not self.ignore ) then
		local newValue;
		
		if ( self:IsNumeric() ) then
			newValue = self:GetNumber();
			local newString = tostring(newValue);
			
			-- Update text if the number value is different from the string value.
			-- This happens e.g., if the textfield's text is "", which is transformed
			-- to 0 via the :GetNumber() method.
			if ( newString ~= self:GetText() ) then
				self:SetText(newString);
			end
		else
			newValue = self:GetText();
		end
		
		if ( self.decimal ) then
			newValue = tonumber(string.match(newValue, "-?%d+%.?%d*"));

			-- Check if we got a valid number value:
			if ( not newValue ) then
				newValue = self:GetDBValue(); -- Reset to old value
			end
			
			-- Adjust edit box value to number value:
			self:SetText(newValue);
		end
		
		local oldValue = UpdateDBEntryByOptionFrame(self, newValue)
		
		-- Post update function if necessary:
		if ( type(self.postUpdate) == "function" ) then
			self:postUpdate(newValue, oldValue);
		end
	end
end

--[[function EditBoxClass:OnChar(text)
	if ( self.decimal ) then
		local input = self:GetText();
		
		-- Turn comma into dot:
		input = string.gsub(input, ",", ".");
		
		-- Extract decimal numbers:
		-- In case no pattern was found take the last without the new text.
		-- NOTE: the tonumber prevents the input from being something like "01.12" instead of "1.12" etc.
		input = string.match(input, "-?%d+%.?%d*") or string.gsub(input, text, "");
		self:SetText(input);
	end
end]]

-- Not needed as edit box has its own enable/disable functions:
--[[function EditBoxClass:Disable()
	self.enabled = nil;
	self:SetTextColor(0.5, 0.5, 0.5);
	self:SetScript("OnEditFocusGained", self.OnEditFocusGained);
	
end

function EditBoxClass:Enable()
	self.enabled = true;
	self:SetTextColor(1, 1, 1);
	self:SetScript("OnEditFocusGained", nil);
end

function EditBoxClass:IsEnabled()
	return self.enabled;
end]]

-- *********** SLIDER METHODS: ***********
local SliderClass = {};
function SliderClass:OnEditFocusLost()

	if ( self:IsEnabled() and not self.ignore ) then
		local slider = self:GetParent();
		local newValue = self:GetNumber();
		local minValue, maxValue = slider:GetMinMaxValues();
		
		if ( newValue > maxValue ) then
			self:SetText(maxValue);
			slider:SetValue(maxValue);
		elseif ( newValue < minValue ) then
			self:SetText(minValue);
			slider:SetValue(minValue);
		elseif (not newValue or newValue == "" ) then
			self:SetText(minValue);
			slider:SetValue(minValue);
		else
			self:SetText(newValue);
			slider:SetValue(newValue);
		end
	end
end

function SliderClass:OnValueChanged()
	
	if ( self.ignore ) then
		return;
	end
	
	local newValue = self:GetValue();

	-- Slider bugfix for changed behaviour in 5.4:
	if ( newValue ~= math.floor(newValue) and not self.decimal ) then
		self:SetValue(math.floor(newValue));
		return;
	end
	
	-- Update current value edit box:
	self.curBox:SetText(newValue);
	self.curBox:SetCursorPosition(0);
	
	local oldValue = UpdateDBEntryByOptionFrame(self, newValue)
	
	-- Post update function if necessary:
	if ( type(self.postUpdate) == "function" ) then
		self:postUpdate(newValue, oldValue);
	end

end

--[[
****************************************
****** OPTION FUNCTIONS START HERE ******
****************************************
]]--
--[[ Function: CreateOptionFrame
	 Creates a basic option frame based on a specified type. This only creates the frame itself and doesn't fill it with type specific methods etc.
		ARGUMENTS:	
			frameData (table): Table that stores all needed information to set up the new frame. Needed values in the table for this function are:
				type (See optionTemplates table for available types)
				name (string [optional]): Name of the created Frame.
				parent (string [optional]): Name of the new frame's parent frame.
				
				width (number): Width of the frame in pixels.
				height (number): Height of the frame in pixels.
				
				point (string [optional]): Anchor point of the new frame. Defaults to TOPLEFT.
				relativeTo (string [optional]): Name of the frame the new frame will be anchored to. Defaults to parent
				relativePoint (string [optional]): Anchor point of the relative frame. Defaults to value of point
				xOffset (number [optional]): Anchor point of the new frame. Defaults to 0.
				yOffset (number [optional]): Anchor point of the new frame. Defaults to 0.
		RETURNS:
			frame: The newly created option frame.
]]--
local function CreateOptionFrame (frameData)
	ArenaLive:CheckArgs(frameData, "table");

	if ( not optionTemplates[frameData.type] ) then
		ArenaLive:Message (L["Couldn't create option frame, because no template for the type %s is registered!"], "error", frameData.type);
		return;
	end
	
	local frameType;
	local template;
	
	-- Get template and (if needed) frame type:
	if ( type(optionTemplates[frameData.type]) == "table" ) then
		frameType = optionTemplates[frameData.type]["type"];
		template = optionTemplates[frameData.type]["template"];
		
	else
		frameType = frameData.type;
		template = optionTemplates[frameData.type];
	end
	
	-- Create the frame:
	local frame = CreateFrame(frameType, frameData.name, _G[frameData.parent], template);
	frame.type = frameData.type;
	
	-- Add option base class methods:
	ArenaLive:CopyClassMethods(OptionBaseClass, frame);
	
	-- Set basic class scripts:
	frame:SetScript("OnShow", frame.OnShow);
	frame:SetScript("OnEnter", frame.OnEnter);
	frame:SetScript("OnLeave", frame.OnLeave);
	
	-- Set Size:
	if ( frameData.type == "DropDown" or frameData.type == "DropDownLargeTitle" ) then
		if ( frameData.width ) then
			UIDropDownMenu_SetWidth(frame, frameData.width, frameData.padding);
		end
	elseif ( frameData.width and frameData.height ) then
		frame:SetSize(frameData.width, frameData.height);
	elseif ( frameData.width ) then
		frame:SetWidth(frameData.width);
	elseif ( frameData.height ) then
		frame:SetHeight(frameData.height);
	end
	
	-- Set Point:
	local point, relativePoint, relativeTo, xOffset, yOffset;
	point = frameData.point or "TOPLEFT";
	relativePoint = frameData.relativePoint or point;
	relativeTo = frameData.relativeTo or frameData.parent;
	xOffset = frameData.xOffset or 0;
	yOffset = frameData.yOffset or 0;
	
	frame:SetPoint(point, relativeTo, relativePoint, xOffset, yOffset);
	
	--ArenaLive:Message("Created option frame. Type = %s and frame = %s", "debug", frameData.type, frame:GetName() or tostring(frame));
	return frame;
end

--[[ Function: ConstructButton
	 Creates a button with all needed methods.
		button (Button): Checkbutton that is going to be set up.
		title (string): Title text for the checkbutton.
		func (function): The function that will be run when clicking the button.
]]--
local function ConstructButton (button, title, func)
	ArenaLive:CheckArgs(button, "Button", title, "string", func, "function");
	
	-- Set Text:
	local prefix = button:GetName();
	local buttonText = _G[prefix.."Text"];
	
	-- Set Text
	button:SetText(title);

	-- Get new text width to set the size of the button correctly:
	if ( buttonText ) then
		local width = buttonText:GetWidth() + 20;
		button:SetWidth(width);
	end
	
	-- Set addonName and affected variable:
	button.func = func;
	
	button:SetScript("OnClick", button.func);

end
--[[ Function: ConstructCheckButton
	 Creates a check button with all needed methods.
		checkButton (frame): Checkbutton that is going to be set up.
		title (string): Title text for the checkbutton.
]]--
local function ConstructCheckButton (checkButton, title)
	ArenaLive:CheckArgs(checkButton, "CheckButton", title, "string");

	local prefix = checkButton:GetName();
	local fontString = _G[prefix.."Text"];
	
	-- Set title and initial value:
	fontString:SetText(title);
	checkButton:SetChecked(checkButton:GetDBValue());
	
	-- Add methods:
	ArenaLive:CopyClassMethods(CheckButtonClass, checkButton);
	
	checkButton:SetScript("OnClick", checkButton.OnClick);

end

--[[ Function: ConstructColourPicker
	 Creates a check button with all needed methods.
		colourPicker (frame [Button]): button that is going to be set up.
		title (string): Title text for the checkbutton.
]]--
local function ConstructColourPicker (colourPicker, title)
	ArenaLive:CheckArgs(colourPicker, "Button", title, "string");
	
	-- Set title:
	colourPicker.title:SetText(title);
	
	-- Set initial colour:
	local red, green, blue, alpha = colourPicker:GetDBValue();
	colourPicker.colour:SetTexture(red, green, blue, alpha or 1);
	
	-- Add methods:
	ArenaLive:CopyClassMethods(ColourPickerClass, colourPicker);
	
	colourPicker:SetScript("OnClick", colourPicker.OnClick);
end

--[[ Function: ConstructDropDown
	 Creates a drop down menu with all needed methods.
		dropDown (Button): Drop Down Button that is going to be set up.
		title (string): Title text for the drop down.
		refreshFunc (function [optional]): Function that refreshes the drop down menu's entries. Defaults to a predefined refresh function.
		NOTE: The initValue is not necessary here, as you need to set the drop down's text etc. in the refresh function anyways.
]]--
local function ConstructDropDown (dropDown, title, emptyText, infoTable, refreshFunc)
	ArenaLive:CheckArgs(dropDown, "Button", title, "string");

	-- Set Title:
	dropDown.title:SetText(title);
	
	-- Set method(s):
	ArenaLive:CopyClassMethods(DropDownClass, dropDown);

	-- Set info table to create the drop down list:
	dropDown.info = infoTable;
	
	-- Overwrite standard refresh func with individual one, if there is one:
	if ( refreshFunc ) then
		dropDown.Refresh = refreshFunc;
	end	
	
	-- Set empty text reference:
	dropDown.emptyText = emptyText;
	dropDown:UpdateShownValue();
	
	-- Initialise the dropdown using blizzard's standard functionset.
	UIDropDownMenu_Initialize(dropDown, dropDown.Refresh);
end

--[[ Function: ConstructEditBox
	 Creates a edit box with all needed methods.
		editBox (frame): ExitBox frame that is going to be set up.
		title (string): Title text for the frame.
		initText: The initial text for the edit box.
		inputType: Type of edit box "NORMAL" for all characters allowed, "NUMERIC" for only numbers being allowed and "DECIMAL" for decimal numbers
		maxLetters: Number of letters the edit box can hold.
]]--
local function ConstructEditBox (editBox, title, inputType, maxLetters)
	ArenaLive:CheckArgs(editBox, "EditBox", title, "string");

	if ( maxLetters ) then
		editBox:SetMaxLetters(maxLetters);
	end
	
	-- Set title and initial value:
	editBox.title:SetText(title);
	editBox:SetText(editBox:GetDBValue() or "");

	-- Reset the EditBox's cursor position, so that the text is always shown correctly.
	editBox:SetCursorPosition(0);
	
	-- Add method(s):
	ArenaLive:CopyClassMethods(EditBoxClass, editBox);
	editBox:SetScript("OnEditFocusLost", editBox.OnEditFocusLost);
	
	if ( inputType == "NUMERIC" ) then
		editBox:SetNumeric(true);
	elseif ( inputType == "DECIMAL" ) then
		editBox.decimal = true;
	end
	
	-- Initial enable:
	editBox:EnableMouse(true);
end


--[[ Function: ConstructSlider
	 Creates a slider with all needed methods.
		slider (frame): Slider frame that is going to be set up.
		title (string): Title text for the frame.
		inputType (string) Valid input for slider's editbox (NUMERIC or DECIMAL).
		minValue (number): Minimal value vor the slider.
		maxValue (number): Maximal value for the slider.
		valueStep (number): Step size of the slider.
]]--
local function ConstructSlider (slider, title, inputType, minValue, maxValue, valueStep)

	ArenaLive:CheckArgs(slider, "Slider", title, "string", minValue, "number", maxValue, "number", valueStep, "number");

	-- Set Value Step size:
	slider:SetValueStep(valueStep)	
	slider.curBox:SetJustifyH("CENTER");
	-- Set Values:
	slider:SetMinMaxValues(minValue, maxValue);
	slider:SetValue(slider:GetDBValue());
	
	-- Set texts:
	slider.title:SetText(title);
	slider.minText:SetText(minValue);
	slider.maxText:SetText(maxValue);
	slider.curBox:SetText(slider:GetDBValue());
	slider.curBox:SetCursorPosition(0);
	
	-- Set edit box size:
	local length = string.len(tostring(maxValue));
	slider.curBox:SetSize(length*10, 14);
	slider.curBox:SetMaxLetters(length);
	
	if ( inputType == "NUMERIC" ) then
		slider.curBox:SetNumeric(true);
	elseif ( inputType == "DECIMAL" ) then
		slider.decimal = true;
		slider.OnChar = EditBoxClass.OnChar;
		slider.curBox.decimal = true;
		slider.curBox:SetScript("OnChar", slider.OnChar);
	end
	
	-- Set Methods and Scripts:
	ArenaLive:CopyClassMethods(SliderClass, slider);
	slider:SetScript("OnValueChanged", slider.OnValueChanged);
	slider.curBox:SetScript("OnEditFocusLost", slider.OnEditFocusLost);
	
	slider.curBox:EnableMouse(true);
end

--[[ Method: ConstructOptionFrame
	 Creates a option object of a specified type.
		frameData (table): Table that stores all frame related information.
						   Possible key entries are: 
								GENERAL: type, name, parent width, height, point, relativeTo, realtivePoint, xOffset, yOffset, title, GetDBValue, SetDBValue
								BUTTON ONLY: func
								DROPDOWN ONLY: emptyText, infoTable, refreshFunc
								EDITBOX ONLY: inputType, maxLetters
								SLIDER ONLY: inputType, min, max, step
		addonName (string [optional]): Name of the addon the option frame will be created for.
		handlerName (string [optional]): Name of the handler for the saved variable path.
		frameGroup (string [optional]): Name of a sub table in the saved variable path.	
		postUpdate (function [optional]): A function that is executed after the option object changed its value and the value in the SavedVariables.
			NOTE: Use this to change the appearance of affected frames etc.
				  Args that this function receives are: optionFrame, newValue, oldValue.
				  For drop downs there will also be transmitted "arg1" and "arg2" according to their usage in the info table in the drop down refresh function.
]]--
function ArenaLive:ConstructOptionFrame(frameData, addonName, handlerName, frameGroup)

	ArenaLive:CheckArgs(frameData, "table");

	-- Get general frame info:
	local optType = frameData.type;
	
	-- Create the frame:
	local frame = CreateOptionFrame(frameData);	

	-- Fill the frame with general info that all option frame types need:
	frame.addon = addonName;
	frame.handler = handlerName;
	frame.group = frameGroup;
	frame.id = frameData.id;
	frame.tooltipTitle = frameData.tooltipTitle;
	frame.tooltip = frameData.tooltip;
	frame.GetDBValue = frameData.GetDBValue;
	frame.SetDBValue = frameData.SetDBValue;
	frame.postUpdate = frameData.postUpdate;

	-- Add the frame to the optionFrames table:
	optionFrames[frame] = true;	
	
	-- Set frame up according to its type:
	if ( optType == "Button" ) then
		ConstructButton(frame, frameData.title, frameData.func);
	elseif ( optType == "CheckButton" ) then
		ConstructCheckButton(frame, frameData.title);
	elseif ( optType == "ColourPicker" ) then
		ConstructColourPicker (frame, frameData.title);
	elseif ( optType == "DropDown" or optType == "DropDownLargeTitle" ) then
		ConstructDropDown(frame, frameData.title, frameData.emptyText, frameData.infoTable, frameData.refreshFunc);
	elseif ( optType == "EditBox" or optType == "EditBoxSmall" ) then	
		ConstructEditBox(frame, frameData.title, frameData.inputType, frameData.maxLetters);
	elseif ( optType == "Slider" ) then
		ConstructSlider(frame, frameData.title, frameData.inputType, frameData.min, frameData.max, frameData.step);
	end
	
	-- Return the option frame for further use:
	return frame;
end

--[[ Method: ConstructOptionObjectByHandler
	 Creates a option object by using option object data from a specified handler.
		frameData (string): Table that stores all frame related information.
		handlerName (string): Name of the handler the option template is stored in.
		handlerOption (string): Name of the handlers option set entry to get frame data from.
		frameGroup (string [optional]): Name of frame group entry in the saved variables.
		subKey (string [optional]): Name of a sub table in the SavedVariables of the addon.
]]--
-- Create a variable to store a reference to the currently needed handler:
local handler;
function ArenaLive:ConstructOptionFrameByHandler(frameData, addonName, handlerName, handlerOption, frameGroup)

	ArenaLive:CheckArgs(frameData, "table", addonName, "string", handlerName, "string", handlerOption, "string");
	
	-- Get Handler and check if the specified handler option is found:
	handler = ArenaLive:GetHandler(handlerName);
	if ( not handler.optionSets or not handler.optionSets[handlerOption] ) then
		ArenaLive:Message (L["Couldn't create option frame by handler, because either no handler named %s is registered or the handler hasn't an option set named %s!"], "error", handlerName, handlerOption);
	end
	
	-- Copy handler's frame data into the frameData table:
	for k, v in pairs(handler.optionSets[handlerOption]) do
		-- Already defined values have priority over the handler's
		if ( not frameData[k] ) then
			frameData[k] = v;
		end
	end
	
	-- Construct option frame with new data:
	ArenaLive:ConstructOptionFrame(frameData, addonName, handlerName, frameGroup)
end


--[[ Method: DisableAllOptionFrames
	 Disable all option frames. Triggers when combat starts and it prevents changes from being made during combat lock down.
]]--
function ArenaLive:DisableAllOptionFrames()
	for frame in pairs(optionFrames) do
		if ( not frame.IsEnabled ) then
			--print(frame:GetName());
		end
		if ( frame:IsVisible() and frame:IsEnabled() ) then
			frame:EnableMouse(false);
			frame.lockdown = true;
			if ( frame:GetObjectType() == "Slider" ) then
				frame.curBox:EnableMouse(false);
			end
		end
	end
end

--[[ Method: DisableAllOptionFrames
	 Enables all frames again once combat is over.
]]--
function ArenaLive:EnableAllOptionFrames()
	for frame in pairs(optionFrames) do
		if ( frame:IsVisible() and frame.lockdown ) then
			frame:Enable();
			if ( frame:GetObjectType() == "Slider" ) then
				frame.curBox:EnableMouse(true);
			end
			frame.lockdown = nil;
		end
	end
end