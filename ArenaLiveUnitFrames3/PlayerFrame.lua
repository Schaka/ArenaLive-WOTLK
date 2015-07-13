local addonName = ...;
local L = ArenaLiveUnitFrames.L;

function ALUF_PlayerFrame:Initialise()

		local prefix = self:GetName();
		ArenaLive:ConstructHandlerObject(self, "UnitFrame", addonName, "PlayerFrame", "target", "menu");
		
		-- Register Frame constituents:
		self:RegisterHandler(_G[prefix.."Border"], "Border");
		self:RegisterHandler(_G[prefix.."HealthBar"], "HealthBar", nil, _G[prefix.."HealthBarHealPredictionBar"], _G[prefix.."HealthBarAbsorbBar"], _G[prefix.."HealthBarAbsorbBarOverlay"], 32, _G[prefix.."HealthBarAbsorbBarFullHPIndicator"], nil, addonName, "PlayerFrame");
		self:RegisterHandler(_G[prefix.."PowerBar"], "PowerBar", nil, addonName, "PlayerFrame");
		self:RegisterHandler(_G[prefix.."Icon1"], "Icon", 1, _G[prefix.."Icon1Texture"],_G[prefix.."Icon1Cooldown"], addonName);
		self:RegisterHandler(_G[prefix.."Icon2"], "Icon", 2, _G[prefix.."Icon2Texture"], _G[prefix.."Icon2Cooldown"], addonName);
		self:RegisterHandler(_G[prefix.."Portrait"], "Portrait", nil, _G[prefix.."PortraitBackground"], _G[prefix.."PortraitTexture"],  _G[prefix.."PortraitThreeD"], self);
		self:RegisterHandler(_G[prefix.."CCIndicator"], "CCIndicator", nil, _G[prefix.."CCIndicatorTexture"], _G[prefix.."CCIndicatorCooldown"], addonName);
		self:RegisterHandler(_G[prefix.."Name"], "NameText", nil, self);
		self:RegisterHandler(_G[prefix.."HealthBarText"], "HealthBarText", nil, self);
		self:RegisterHandler(_G[prefix.."PowerBarText"], "PowerBarText", nil, self);
		self:RegisterHandler(_G[prefix.."CastBar"], "CastBar", nil, _G[prefix.."CastBarIcon"], _G[prefix.."CastBarText"], _G[prefix.."CastBarBorderShieldGlow"], _G[prefix.."CastBarAnimation"], _G[prefix.."CastBarAnimationFadeOut"], true, addonName, "PlayerFrame");
		self:RegisterHandler(_G[prefix.."AuraFrame"], "Aura", nil, _G[prefix.."AuraFrameBuffFrame"], _G[prefix.."AuraFrameDebuffFrame"]);
		self:RegisterHandler(_G[prefix.."LevelText"], "LevelText", nil , nil, "(%s)");
		self:RegisterHandler(_G[prefix.."ReadyCheck"], "ReadyCheck");
		self:RegisterHandler(_G[prefix.."DRTracker"], "DRTracker", nil, addonName, "PlayerFrame");
		
		local IconGroupHeader =  ArenaLive:GetHandler("IconGroupHeader");
		IconGroupHeader:ConstructGroup("ALUF_PlayerFrameIconGroup", "RIGHT", 0, "TOPLEFT", _G[prefix.."LevelText"], "TOPRIGHT", 1, 2);
		self:RegisterHandler(_G[prefix.."StatusIcon"], "StatusIcon", nil, "ALUF_PlayerFrameIconGroup", nil, addonName, "PlayerFrame");	 
		self:RegisterHandler(_G[prefix.."LeaderIcon"], "LeaderIcon", nil, "ALUF_PlayerFrameIconGroup", nil, addonName, "PlayerFrame");
		self:RegisterHandler(_G[prefix.."MasterLooterIcon"], "MasterLooterIcon", nil, "ALUF_PlayerFrameIconGroup", nil, addonName, "PlayerFrame");
		self:RegisterHandler(_G[prefix.."RoleIcon"], "RoleIcon", nil, "ALUF_PlayerFrameIconGroup", nil, addonName, "PlayerFrame");

		self:RegisterHandler(_G[prefix.."MultiGroupFrame"], "MultiGroupIcon", nil, _G[prefix.."MultiGroupFrameHomePartyIcon"], _G[prefix.."MultiGroupFrameInstancePartyIcon"]);
		self:RegisterHandler(_G[prefix.."PvPIcon"], "PvPIcon", nil, nil, nil, addonName, "PlayerFrame", _G[prefix.."PvPIconTexture"], _G[prefix.."PvPIconText"]);
		
		self:UpdateUnit("player");
		
		-- Update Constituent positions and border colours:
		ArenaLiveUnitFrames:UpdateFrameBorders(self);
		self:UpdateElementPositions();
end

function ALUF_PlayerFrame:UpdateElementPositions()
	ArenaLiveUnitFrames:SetFramePositions(self);
end

local function UpdateTotemFramePosition()
	local _, class = UnitClass("player");
	if ( class == "DRUID" ) then
		-- Resto Druid Mushroom Display
		TotemFrame:ClearAllPoints();
		TotemFrame:SetPoint("TOPLEFT", ALUF_PlayerFrame, "BOTTOMLEFT", 0, 0 );
	end
end

function ALUF_PlayerFrame:OnEnable()
	self:UpdateUnit("player");
	PlayerFrame:Hide();
	
	-- For now we use the Blizzard AltPowerBars and attach them to AL's PlayerFrame:
	local _, class = UnitClass("player");	
	if ( class == "WARLOCK" ) then
		--[[WarlockPowerFrame:SetParent(ALUF_PlayerFrame);
		WarlockPowerFrame:ClearAllPoints();
		WarlockPowerFrame:SetPoint("TOP", ALUF_PlayerFrame, "BOTTOM", 48, -2 );]]
	elseif ( class == "SHAMAN" ) then
		TotemFrame:SetParent(ALUF_PlayerFrame);
		TotemFrame:ClearAllPoints();
		TotemFrame:SetPoint("TOP", ALUF_PlayerFrame, "BOTTOM", 0, 4 );
	elseif ( class == "DRUID" ) then
		--[[EclipseBarFrame:SetParent(ALUF_PlayerFrame);
		EclipseBarFrame:ClearAllPoints();
		EclipseBarFrame:SetPoint("TOP", ALUF_PlayerFrame, "BOTTOM", 50, 3 );
		-- Resto Druid Mushroom Display
		TotemFrame:SetParent(ALUF_PlayerFrame);
		TotemFrame:ClearAllPoints();
		TotemFrame:SetPoint("TOPLEFT", ALUF_PlayerFrame, "BOTTOMLEFT", 0, 0 );
		hooksecurefunc("TotemFrame_Update", UpdateTotemFramePosition);]] 
	elseif ( class == "PALADIN" ) then
		--[[PaladinPowerBar:SetParent(ALUF_PlayerFrame);
		PaladinPowerBar:ClearAllPoints();
		PaladinPowerBar:SetPoint("TOP", ALUF_PlayerFrame, "BOTTOM", 0, 2 );]]
	elseif ( class == "DEATHKNIGHT" ) then
		RuneFrame:SetParent(ALUF_PlayerFrame);
		RuneFrame:ClearAllPoints();
		RuneFrame:SetPoint("TOP", ALUF_PlayerFrame, "BOTTOM", 52, -7 );
	elseif ( class == "PRIEST" ) then
		--[[PriestBarFrame:SetParent(ALUF_PlayerFrame);
		PriestBarFrame:ClearAllPoints();
		PriestBarFrame:SetPoint("TOP", ALUF_PlayerFrame, "BOTTOM", 50, 0 );]]
	end
end

function ALUF_PlayerFrame:OnDisable()
	if ( not PlayerFrame:IsShown() ) then
		PlayerFrame:Show();
		StaticPopup_Show("ALUF_CONFIRM_RELOADUI");
	end
end