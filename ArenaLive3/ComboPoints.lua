--[[ ArenaLive Core Functions: Combo Point Handler
Created by: Vadrak
Creation Date: 02.05.2014
Last Update: 17.05.2014
This file contains all relevant functions for combo point indicators.
]]--

-- ArenaLive addon Name and localisation table:
local addonName, L = ...;

--[[
**************************************************
******* GENERAL HANDLER SET UP STARTS HERE *******
**************************************************
]]--
-- Create new Handler and register for all important events:
local ComboPoints = ArenaLive:ConstructHandler("ComboPoints", true, false);

-- Register the handler for all needed events:
ComboPoints:RegisterEvent("PLAYER_TARGET_CHANGED");
ComboPoints:RegisterEvent("UNIT_COMBO_POINTS");
ComboPoints:RegisterEvent("PLAYER_COMBO_POINTS");



--[[
****************************************
****** HANDLER METHODS START HERE ******
****************************************
]]--