local addonName = ...;
local L = ArenaLiveUnitFrames.L;

function ALUF_PetFrame:Initialise()

	local prefix = self:GetName();
	ArenaLive:ConstructHandlerObject(self, "UnitFrame", addonName, "PetFrame", "target", "togglemenu");
	
	-- Register Frame constituents:
	self:RegisterHandler(_G[prefix.."Border"], "Border");
	self:RegisterHandler(_G[prefix.."Flash"], "ThreatIndicator", "target");
	self:RegisterHandler(_G[prefix.."HealthBar"], "HealthBar", nil, _G[prefix.."HealthBarHealPredictionBar"], _G[prefix.."HealthBarAbsorbBar"], _G[prefix.."HealthBarAbsorbBarOverlay"], 32, _G[prefix.."HealthBarAbsorbBarFullHPIndicator"], nil, addonName, "PetFrame");
	self:RegisterHandler(_G[prefix.."PowerBar"], "PowerBar", nil, addonName, "PetFrame");
	self:RegisterHandler(_G[prefix.."Portrait"], "Portrait", nil, _G[prefix.."PortraitBackground"], _G[prefix.."PortraitTexture"],  _G[prefix.."PortraitThreeD"], self);
	self:RegisterHandler(_G[prefix.."PortraitCCIndicator"], "CCIndicator", nil, _G[prefix.."PortraitCCIndicatorTexture"], _G[prefix.."PortraitCCIndicatorCooldown"], addonName);
	self:RegisterHandler(_G[prefix.."Name"], "NameText", nil, self);
	self:RegisterHandler(_G[prefix.."HealthBarText"], "HealthBarText", nil, self);
	self:RegisterHandler(_G[prefix.."PowerBarText"], "PowerBarText", nil, self);
	self:RegisterHandler(_G[prefix.."AuraFrame"], "Aura", nil, _G[prefix.."AuraFrameBuffFrame"], _G[prefix.."AuraFrameDebuffFrame"]);
	
	-- Update Constituent positions and border colours:
	ArenaLiveUnitFrames:UpdateFrameBorders(self);
	self:UpdateElementPositions();
end

function ALUF_PetFrame:UpdateElementPositions()
	ArenaLiveUnitFrames:SetFramePositions(self);
end

function ALUF_PetFrame:OnEnable()
	self:UpdateUnit("pet");
	
	-- Disable Blizzard's PetFrame:
	PetFrame:UnregisterAllEvents();
	PetFrame:Hide();
end

function ALUF_PetFrame:OnDisable()
	-- Check if we've disabled Blizzard's PetFrame by checking for a registered event:
	if ( not PetFrame:IsEventRegistered("UNIT_PET") ) then
		-- Suggest UI Reload if we disabled Blizzard's PetFrame before, because we tainted it by disabling it and won't work correctly until the UI reload.
		StaticPopup_Show("ALUF_CONFIRM_RELOADUI");
		local onLoad = PetFrame:GetScript("OnLoad");
		onLoad(PetFrame);
	end
end