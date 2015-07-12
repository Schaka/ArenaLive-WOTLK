local addonName, ArenaLiveUnitFrames = ...;
ArenaLiveUnitFrames.L ={};
local L = ArenaLiveUnitFrames.L;
L["ArenaLive [UnitFrames]"] = "ArenaLive [UnitFrames]";
L["Unit Frames"] = "Unit Frames";
L["ArenaLive [UnitFrames] General Options:"] = "ArenaLive [UnitFrames] General Options:";
L["ArenaLive [UnitFrames] Unit Frame Options:"] = "ArenaLive [UnitFrames] Unit Frame Options:";
L["ArenaLive [UnitFrames] Profile Options:"] = "ArenaLive [UnitFrames] Profile Options:";
L["Crowd Control Indicator Priorities:"] = "Crowd Control Indicator Priorities:";
L["Set the priorities for the different indicator types, zero deactivates them."] = "Set the priorities for the different indicator types, zero deactivates them.";
L["Hide Blizzard's Cast Bar"] = "Hide Blizzard's Cast Bar";
L["Hides Blizzard's player cast bar."] = "Hides Blizzard's player cast bar.";
L["Unit Frame"] = "Unit Frame";

-- Frame Names:
L["Player Frame"] = "Player Frame";
L["Pet Frame"] = "Pet Frame";
L["Target Frame"] = "Target Frame";
L["Target's Target Frame"] = "Target's Target Frame";
L["Focus Frame"] = "Focus Frame";
L["Focus' Target Frame"] = "Focus' Target Frame";
L["Party Frames"] = "Party Frames";
L["Arena Enemy Frames"] = "Arena Enemy Frames";
L["Boss Frames"] = "Boss Frames";
L["Unit Frame:"] = "Unit Frame:";
L["Choose a frame"] = "Choose a frame";
L["Frame Element:"] = "Frame Element:";
L["Choose a frame element"] = "Choose a frame element";

-- Handler Names:
L["UnitFrame"] = "General";
L["Aura"] = "Buffs and Debuffs";
L["Border"] = "Border";
L["CastBar"] = "Castbar";
L["CastHistory"] = "Cast History";
L["CCIndicator"] = "Crowd Control Indicator";
L["DRTracker"] = "Diminishing Return Tracker";
L["HealthBar"] = "Healthbar";
L["HealthBarText"] = "Healthbar Text";
L["Icon"] = "Dynamic Icons";
L["LeaderIcon"] = "Leader Icon";
L["LevelText"] = "Level";
L["MasterLooterIcon"] = "Master Looter Icon";
L["MultiGroupIcon"] = "Multigroup Icon";
L["NameText"] = "Name";
L["PetBattleIcon"] = "Pet Battle Icon";
L["Portrait"] = "Portrait";
L["PowerBar"] = "Powerbar";
L["PowerBarText"] = "Powerbar Text";
L["PvPIcon"] = "PvP Icon";
L["QuestIcon"] = "Quest Icon";
L["RaidIcon"] = "Raid Icon";
L["ReadyCheck"] = "Ready Check";
L["RoleIcon"] = "Role Icon";
L["StatusIcon"] = "Status Icon";
L["TargetIndicator"] = "Target Indicator";
L["ThreatIndicator"] = "Threat Indicator";
L["VoiceFrame"] = "Voice Frame";
L["TargetFrame"] = "Target Frame";
L["PetFrame"] = "Pet Frame";

-- General Options:
L["%s Position:"] = "%s Position:";
L["Larger Frame"] = "Larger Frame";
L["If checked, the unit frame's size will be increased."] = "If checked, the unit frame's size will be increased.";
L["Tried to attach %s's %s to %s, although %s's positioning is dependent on %s. Please change that in ArenaLive [UnitFrames]'s option menu."] = "Tried to attach %s's %s to %s, although %s's positioning is dependent on %s. Please change that in ArenaLive [UnitFrames]'s option menu.";

-- Castbar Options:
L["Longer Castbar"] = "Longer Castbar";
L["If checked, the unit frames will show a longer cast bar than the usual one."] = "If checked, the unit frames will show a longer cast bar than the usual one.";

-- Icon Options:
L["Top Icon Type"] = "Top Icon Type";
L["Top Icon Fallback"] = "Top Icon Fallback";
L["Bottom Icon Type"] = "Bottom Icon Type";
L["Bottom Icon Fallback"] = "Bottom Icon Fallback";

-- Frame Element Position Options:
L["Position"] = "Position";
L["Sets the position at which this frame element will be attached to another frame element."] = "Sets the position at which this frame element will be attached to another frame element.";
L["Attach to"] = "Attach to";
L["Sets the frame element to which this frame element will be attached to."] = "Sets the frame element to which this frame element will be attached to.";
L["X Offset"] = "X Offset";
L["Horizontal distance between the frame element and the element it is attached to."] = "Horizontal distance between the frame element and the element it is attached to.";
L["Y Offset"] = "Y Offset";
L["Vertical distance between the frame element and the element it is attached to."] = "Vertical distance between the frame element and the element it is attached to.";
L["Above"] = "Above";
L["Right"] = "Right";
L["Below"] = "Below";
L["Left"] = "Left";

-- Profle Options:
L["ArenaLive [UnitFrames] Profile Options:"] = "ArenaLive [UnitFrames] Profile Options:";
L["Profiles"] = "Profiles";
L["Delete Active Profile"] = "Delete Active Profile";

-- Error messages:
L["Couldn't construct handler option page for handler %s, because there is already a page for that handler!"] = "Couldn't construct handler option page for handler %s, because there is already a page for that handler!";
L["Couldn't destroy handler option page for handler %s, because there is now option page for that handler!"] = "Couldn't destroy handler option page for handler %s, because there is now option page for that handler!";
L["New option page constructed for handler %s!"] = "New option page constructed for handler %s!";

-- Static Popup Messages:
L["A change makes it necessary to reload the UI in order for the interface to work correctly. Do you wish to reload the interface now?"] = "A change makes it necessary to reload the UI in order for the interface to work correctly. Do you wish to reload the interface now?";