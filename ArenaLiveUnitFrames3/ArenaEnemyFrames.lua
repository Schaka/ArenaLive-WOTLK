local addonName = ...;

local function frameInitFunc(frame)
	local prefix = frame:GetName();
	local id = frame:GetID();
	
	-- Initialise unit frame:
	frame:RegisterHandler(_G[prefix.."Name"], "NameText", nil, frame);
	frame:RegisterHandler(_G[prefix.."Border"], "Border");
	frame:RegisterHandler(_G[prefix.."HealthBar"], "HealthBar", nil, _G[prefix.."HealthBarHealPredictionBar"], _G[prefix.."HealthBarAbsorbBar"], _G[prefix.."HealthBarAbsorbBarOverlay"], 32, _G[prefix.."HealthBarAbsorbBarFullHPIndicator"], nil, addonName, "ArenaEnemyFrames");
		frame:RegisterHandler(_G[prefix.."HealthBarText"], "HealthBarText", nil, frame);
	frame:RegisterHandler(_G[prefix.."PowerBar"], "PowerBar", nil, addonName, "ArenaEnemyFrames");
		frame:RegisterHandler(_G[prefix.."PowerBarText"], "PowerBarText", nil, frame);	
	frame:RegisterHandler(_G[prefix.."Icon1"], "Icon", 1, _G[prefix.."Icon1Texture"],_G[prefix.."Icon1Cooldown"], addonName);
	frame:RegisterHandler(_G[prefix.."Icon2"], "Icon", 2, _G[prefix.."Icon2Texture"], _G[prefix.."Icon2Cooldown"], addonName);
	frame:RegisterHandler(_G[prefix.."Icon3"], "Icon", 3, _G[prefix.."Icon3Texture"], _G[prefix.."Icon3Cooldown"], addonName);
	frame:RegisterHandler(_G[prefix.."Portrait"], "Portrait", _G[prefix.."PortraitBackground"], nil, _G[prefix.."PortraitTexture"],  _G[prefix.."PortraitThreeD"], frame);
	frame:RegisterHandler(_G[prefix.."PortraitCCIndicator"], "CCIndicator", nil, _G[prefix.."PortraitCCIndicatorTexture"], _G[prefix.."PortraitCCIndicatorCooldown"], addonName);
	frame:RegisterHandler(_G[prefix.."CastBar"], "CastBar", nil, _G[prefix.."CastBarIcon"], _G[prefix.."CastBarText"], _G[prefix.."CastBarBorderShieldGlow"], _G[prefix.."CastBarAnimation"], _G[prefix.."CastBarAnimationFadeOut"], true, addonName, "ArenaEnemyFrames");
	frame:RegisterHandler(_G[prefix.."DRTracker"], "DRTracker", nil, addonName, "ArenaEnemyFrames");
	frame:RegisterHandler(_G[prefix.."TargetIndicator"], "TargetIndicator");
	
	ArenaLiveUnitFrames:UpdateCastBarDisplay(frame);
	
	ArenaLiveUnitFrames:UpdateFrameBorders(frame);
end

function ALUF_ArenaEnemyFrames:Initialise()
	ArenaLive:ConstructHandlerObject(self, "ArenaHeader", "ALUF_ArenaEnemyFrameTemplate", frameInitFunc, addonName, "ArenaEnemyFrames");
	ALUF_ArenaEnemyFrames:UpdateElementPositions();
end

function ALUF_ArenaEnemyFrames:UpdateElementPositions()
	for i = 1, 5 do
		ArenaLiveUnitFrames:SetFramePositions(self["Frame"..i]);
	end
end


-- Fix for position/attachement option menu:
ALUF_ArenaEnemyFrames.UnitFrame = true;
ALUF_ArenaEnemyFrames.CastBar = true;
ALUF_ArenaEnemyFrames.CastHistory = true;
ALUF_ArenaEnemyFrames.DRTracker = true;