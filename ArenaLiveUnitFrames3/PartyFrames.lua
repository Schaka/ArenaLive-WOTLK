local addonName = ...;
local HealthBar = ArenaLive:GetHandler("HealthBar");
local PowerBar = ArenaLive:GetHandler("PowerBar");

local function PartyTargetFrame_OnUpdate(self, elapsed)
	if ( self.unit ) then
		local guid = UnitGUID(self.unit);
		
		if ( guid ~= self.guid ) then
			self:UpdateGUID(self.unit);
			self:Update();
		else
			HealthBar:Update(self);
			PowerBar:Update(self);
		end
	end
end

local function  PartyTargetFrame_OnShow(frame)
	frame:Update();
end

local function ALUF_PartyFramesPlayerFrame_OnEnable(self)
	local database = ArenaLive:GetDBComponent(self.addon);
	if ( database.PartyTargetFrame.UnitFrame.Enabled ) then
		self.TargetFrame:Enable();
		self.TargetFrame:UpdateUnit("target");	
	end
	
	if ( database.PartyPetFrame.UnitFrame.Enabled ) then
		self.PetFrame:Enable();
		self.PetFrame:UpdateUnit("pet");
	end
end

local function ALUF_PartyFramesPlayerFrame_OnDisable(self)
		self.TargetFrame:Disable();
		self.PetFrame:Disable();
end

local function TargetFrame_OnEnable(self)
	local id = self:GetID();
	if ( id == 0 ) then
		self:UpdateUnit("target");
	else
		self:UpdateUnit("party"..id.."target");
	end
end

local function PetFrame_OnEnable(self)
	local id = self:GetID();
	if ( id == 0 ) then
		self:UpdateUnit("pet");
	else
		self:UpdateUnit("partypet"..id);
	end
end

local function initFunc(frame)
	local prefix = frame:GetName();
	local petFrame = _G[prefix.."PetFrame"];
	local petPrefix = petFrame:GetName();
	local targetFrame = _G[prefix.."TargetFrame"];
	local targetPrefix = targetFrame:GetName();
	local id = frame:GetID();

	frame.TargetFrame = targetFrame;
	frame.TargetFrame:SetID(id);
	frame.TargetFrame.OnEnable = TargetFrame_OnEnable;
	frame.PetFrame = petFrame;
	frame.PetFrame:SetID(id);
	frame.PetFrame.OnEnable = PetFrame_OnEnable;
	
	if ( id == 0 ) then
		frame.OnEnable = ALUF_PartyFramesPlayerFrame_OnEnable;
		frame.OnDisable = ALUF_PartyFramesPlayerFrame_OnDisable;
	end
	
	frame:RegisterHandler(_G[prefix.."Name"], "NameText", nil, frame);
	frame:RegisterHandler(_G[prefix.."Border"], "Border");
	frame:RegisterHandler(_G[prefix.."HealthBar"], "HealthBar", nil, _G[prefix.."HealthBarHealPredictionBar"], _G[prefix.."HealthBarAbsorbBar"], _G[prefix.."HealthBarAbsorbBarOverlay"], 32, _G[prefix.."HealthBarAbsorbBarFullHPIndicator"], nil, addonName, "PartyFrames");
	frame:RegisterHandler(_G[prefix.."HealthBarText"], "HealthBarText", nil, frame);
	frame:RegisterHandler(_G[prefix.."PowerBar"], "PowerBar", nil, addonName, "PartyFrames");
	frame:RegisterHandler(_G[prefix.."PowerBarText"], "PowerBarText", nil, frame);
	frame:RegisterHandler(_G[prefix.."AuraFrame"], "Aura", nil, _G[prefix.."AuraFrameBuffFrame"], _G[prefix.."AuraFrameDebuffFrame"]);
	frame:RegisterHandler(_G[prefix.."LevelText"], "LevelText", nil , nil, "(%s)");
	frame:RegisterHandler(_G[prefix.."ReadyCheck"], "ReadyCheck");
	frame:RegisterHandler(_G[prefix.."Icon1"], "Icon", 1, _G[prefix.."Icon1Texture"],_G[prefix.."Icon1Cooldown"], addonName);
	frame:RegisterHandler(_G[prefix.."Icon2"], "Icon", 2, _G[prefix.."Icon2Texture"], _G[prefix.."Icon2Cooldown"], addonName);
	frame:RegisterHandler(_G[prefix.."Portrait"], "Portrait", nil, _G[prefix.."PortraitBackground"], _G[prefix.."PortraitTexture"],  _G[prefix.."PortraitThreeD"], frame);
	frame:RegisterHandler(_G[prefix.."PortraitCCIndicator"], "CCIndicator", nil, _G[prefix.."PortraitCCIndicatorTexture"], _G[prefix.."PortraitCCIndicatorCooldown"], addonName);
	frame:RegisterHandler(_G[prefix.."CastBar"], "CastBar", nil, _G[prefix.."CastBarIcon"], _G[prefix.."CastBarText"], _G[prefix.."CastBarBorderShieldGlow"], _G[prefix.."CastBarAnimation"], _G[prefix.."CastBarAnimationFadeOut"], true, addonName, "PartyFrames");
	frame:RegisterHandler(_G[prefix.."DRTracker"], "DRTracker", nil, addonName, "PartyFrames");
	frame:RegisterHandler(_G[prefix.."TargetIndicator"], "TargetIndicator");
	
	local IconGroupHeader =  ArenaLive:GetHandler("IconGroupHeader");
	IconGroupHeader:ConstructGroup(prefix.."IconGroup", "RIGHT", 0, "TOPLEFT", _G[prefix.."LevelText"], "TOPRIGHT", 1, 2); 
	frame:RegisterHandler(_G[prefix.."LeaderIcon"], "LeaderIcon", nil, prefix.."IconGroup", nil, addonName, "PartyFrames");
	frame:RegisterHandler(_G[prefix.."MasterLooterIcon"], "MasterLooterIcon", nil, prefix.."IconGroup", nil, addonName, "PartyFrames");
	frame:RegisterHandler(_G[prefix.."RoleIcon"], "RoleIcon", nil, prefix.."IconGroup", nil, addonName, "PartyFrames");
	frame:RegisterHandler(_G[prefix.."PvPIcon"], "PvPIcon", nil, nil, nil, addonName, "PartyFrames", _G[prefix.."PvPIconTexture"]);
	
	-- Update castbar textures:
	ArenaLiveUnitFrames:UpdateCastBarDisplay(frame);
	
	-- Initialise pet frame:
	ArenaLive:ConstructHandlerObject(petFrame, "UnitFrame", addonName, "PartyPetFrame", "target", "menu");
	petFrame:RegisterHandler(_G[petPrefix.."Border"], "Border");
	petFrame:RegisterHandler(_G[petPrefix.."HealthBar"], "HealthBar", nil, nil, nil, nil, nil, nil, nil, addonName, "PartyPetFrame");
	petFrame:RegisterHandler(_G[petPrefix.."HealthBarText"], "HealthBarText", nil, petFrame);
	petFrame:RegisterHandler(_G[petPrefix.."Portrait"], "Portrait", nil, _G[petPrefix.."PortraitBackground"], _G[petPrefix.."PortraitTexture"],  _G[petPrefix.."PortraitThreeD"], petFrame);
	petFrame:RegisterHandler(_G[petPrefix.."Name"], "NameText", nil, petFrame);
	petFrame:RegisterHandler(_G[petPrefix.."TargetIndicator"], "TargetIndicator");	
	
	-- Initialise target frame:
	ArenaLive:ConstructHandlerObject(targetFrame, "UnitFrame", addonName, "PartyTargetFrame", "target", "menu");	
	targetFrame:RegisterHandler(_G[targetPrefix.."Border"], "Border");
	targetFrame:RegisterHandler(_G[targetPrefix.."HealthBar"], "HealthBar", nil, nil, nil, nil, nil, nil, nil, addonName, "PartyTargetFrame");
	targetFrame:RegisterHandler(_G[targetPrefix.."PowerBar"], "PowerBar", nil, addonName, "PartyTargetFrame");
	targetFrame:RegisterHandler(_G[targetPrefix.."Portrait"], "Portrait", nil, _G[targetPrefix.."PortraitBackground"], _G[targetPrefix.."PortraitTexture"],  _G[targetPrefix.."PortraitThreeD"], targetFrame);
	targetFrame:RegisterHandler(_G[targetPrefix.."Name"], "NameText", nil, targetFrame);
	
	targetFrame:SetScript("OnShow", PartyTargetFrame_OnShow);
	targetFrame:SetScript("OnUpdate", PartyTargetFrame_OnUpdate);
	
	ArenaLiveUnitFrames:UpdateFrameBorders(frame);
end

function ALUF_PartyFrames:OnEnable()
	local targetFrame, petFrame;
	local database = ArenaLive:GetDBComponent(self.addon);
	
	for i = 1, 4 do
		if ( i == 1 ) then
			targetFrame = self["PlayerFrame"]["TargetFrame"];
			petFrame = self["PlayerFrame"]["PetFrame"];
			if ( self:GetAttribute("showplayer") ) then
				if ( database.PartyTargetFrame.UnitFrame.Enabled ) then
					targetFrame:Enable();
					targetFrame:UpdateUnit("target");
				end
				
				if ( database.PartyPetFrame.UnitFrame.Enabled ) then
					petFrame:Enable();
					petFrame:UpdateUnit("pet");
				end

			else
				targetFrame:Disable();
				petFrame:Disable();
			end
		end
		
		
		if ( database.PartyTargetFrame.UnitFrame.Enabled ) then
			targetFrame = self["Frame"..i]["TargetFrame"];
			targetFrame:Enable();
			targetFrame:UpdateUnit("party"..i.."target");
		end
		
		if ( database.PartyPetFrame.UnitFrame.Enabled ) then
			petFrame = self["Frame"..i]["PetFrame"];
			petFrame:Enable();
			petFrame:UpdateUnit("partypet"..i);
		end
	end
end

function ALUF_PartyFrames:OnDisable()
	local targetFrame, petFrame;
	for i = 1, 4 do
		if ( i == 1 ) then
			targetFrame = self["PlayerFrame"]["TargetFrame"];
			petFrame = self["PlayerFrame"]["PetFrame"];
			targetFrame:Disable();
			petFrame:Disable();
		end
		
		targetFrame = self["Frame"..i]["TargetFrame"];
		petFrame = self["Frame"..i]["PetFrame"];
		targetFrame:Disable();
		petFrame:Disable();
	end
end

function ALUF_PartyFrames:Initialise()
	ArenaLive:ConstructHandlerObject(self, "PartyHeader", "ALUF_PartyMemberFrameTemplate", initFunc, addonName, "PartyFrames");
	ALUF_PartyFrames:UpdateElementPositions();
end

function ALUF_PartyFrames:UpdateElementPositions()
	ArenaLiveUnitFrames:SetFramePositions(self["PlayerFrame"]);
	for i = 1, 4 do
		ArenaLiveUnitFrames:SetFramePositions(self["Frame"..i]);
	end
end

-- Fix for position/attachement option menu:
ALUF_PartyFrames.UnitFrame = true;
ALUF_PartyFrames.AuraFrame = true;
ALUF_PartyFrames.CastBar = true;
ALUF_PartyFrames.CastHistory = true;
ALUF_PartyFrames.DRTracker = true;
ALUF_PartyFrames.TargetFrame = true;
ALUF_PartyFrames.PetFrame = true;