local addonName = ...;
local HealthBar = ArenaLive:GetHandler("HealthBar");
local PowerBar = ArenaLive:GetHandler("PowerBar");

local function OnUpdate(self, elapsed)
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

local function OnShow(frame)
	frame:UpdateGUID(frame.unit);
	frame:Update();
end

local function UpdateElementPositions(frame)
	ArenaLiveUnitFrames:SetFramePositions(frame);
end

function ArenaLiveUnitFrames:UpdateTargetFrameDisplay(frame)
	local database = ArenaLive:GetDBComponent(frame.addon, "UnitFrame", frame.group);
	if ( frame and database ) then
		if ( database.LargerFrame ) then
			frame:SetSize(148, 69);

			frame.Background:SetSize(148, 52);
			frame.Background:ClearAllPoints();
			frame.Background:SetPoint("TOPLEFT", frame, "TOPLEFT", 0, -10);
			
			frame.Border:SetSize(155, 60);
			frame.Border:SetTexture("Interface\\AddOns\\ArenaLiveUnitFrames3\\Textures\\PetFrame");
			frame.Border:ClearAllPoints();
			frame.Border:SetPoint("TOPLEFT", frame, "TOPLEFT", -2, -8);
			frame.Border:SetTexCoord(0.1953125, 0.8125, 0.0625, 0.984375);
			
			frame.NameText:SetSize(154, 10);
			frame.NameText:ClearAllPoints();
			frame.NameText:SetPoint("TOPLEFT", frame, "TOPLEFT", 5, 0);
			
			frame.Portrait:SetSize(48, 48);
			frame.Portrait:ClearAllPoints();
			frame.Portrait:SetPoint("TOPLEFT", frame, "TOPLEFT", 2, -12);

			frame.HealthBar:SetSize(96, 32);
			frame.HealthBar:ClearAllPoints();
			frame.HealthBar:SetPoint("TOPLEFT", frame.Portrait, "TOPRIGHT", 0, 0);

			frame.PowerBar:SetSize(96, 16);
			frame.PowerBar:ClearAllPoints();
			frame.PowerBar:SetPoint("TOP", frame.HealthBar, "BOTTOM", 0, 0);
		else
			frame:SetSize(32, 56);
			
			frame.Background:SetSize(34, 50);
			frame.Background:ClearAllPoints();
			frame.Background:SetPoint("CENTER", frame, "CENTER", 0, -6);		
			
			frame.Border:SetSize(34, 50);
			frame.Border:SetTexture("Interface\\AddOns\\ArenaLiveUnitFrames3\\Textures\\TargetOfTargetFrame");
			frame.Border:ClearAllPoints();
			frame.Border:SetPoint("TOP", frame, "TOP", 0, -8);
			frame.Border:SetTexCoord(0.234375, 0.75, 0.09375, 0.90625);
			
			frame.NameText:SetSize(32, 8);
			frame.NameText:ClearAllPoints();
			frame.NameText:SetPoint("TOPLEFT", frame, "TOPLEFT", 0, 0);
			
			frame.Portrait:SetSize(32, 32);
			frame.Portrait:ClearAllPoints();
			frame.Portrait:SetPoint("TOP", frame, "TOP", 0, -8);
			
			frame.HealthBar:SetSize(32, 8);
			frame.HealthBar:ClearAllPoints();
			frame.HealthBar:SetPoint("TOP", frame.Portrait, "BOTTOM", 0, 0);

			frame.PowerBar:SetSize(32, 8);
			frame.PowerBar:ClearAllPoints();
			frame.PowerBar:SetPoint("TOP", frame.HealthBar, "BOTTOM", 0, 0);			
		end
	end
end

function ALUF_TargetTargetFrame:Initialise()
		local prefix = self:GetName();
		ArenaLive:ConstructHandlerObject(self, "UnitFrame", addonName, "TargetTargetFrame", "target", "togglemenu");
		
		-- Register Frame constituents:
		self:RegisterHandler(_G[prefix.."Border"], "Border");
		self:RegisterHandler(_G[prefix.."HealthBar"], "HealthBar", nil, nil, nil, nil, nil, nil, nil, addonName, "TargetTargetFrame");
		self:RegisterHandler(_G[prefix.."PowerBar"], "PowerBar", nil, addonName, "TargetTargetFrame");
		self:RegisterHandler(_G[prefix.."Portrait"], "Portrait", nil, _G[prefix.."PortraitBackground"], _G[prefix.."PortraitTexture"],  _G[prefix.."PortraitThreeD"], self);
		self:RegisterHandler(_G[prefix.."Name"], "NameText", nil, self);
		
		ArenaLiveUnitFrames:UpdateTargetFrameDisplay(self);
		
		-- Update Constituent positions:
		self.UpdateElementPositions = UpdateElementPositions;
		self:UpdateElementPositions();
		
		-- Set OnUpdate script:
		self:SetScript("OnShow", OnShow);
		self:SetScript("OnUpdate", OnUpdate);
end

function ALUF_TargetTargetFrame:OnEnable()
	self:UpdateUnit("targettarget");
end

function ALUF_FocusTargetFrame:Initialise()
		local prefix = self:GetName();
		ArenaLive:ConstructHandlerObject(self, "UnitFrame", addonName, "FocusTargetFrame", "target", "togglemenu");
		
		-- Register Frame constituents:
		self:RegisterHandler(_G[prefix.."Border"], "Border");
		self:RegisterHandler(_G[prefix.."HealthBar"], "HealthBar", nil, nil, nil, nil, nil, nil, nil, addonName, "FocusTargetFrame");
		self:RegisterHandler(_G[prefix.."PowerBar"], "PowerBar", nil, addonName, "FocusTargetFrame");
		self:RegisterHandler(_G[prefix.."Portrait"], "Portrait", nil, _G[prefix.."PortraitBackground"], _G[prefix.."PortraitTexture"],  _G[prefix.."PortraitThreeD"], self);
		self:RegisterHandler(_G[prefix.."Name"], "NameText", nil, self);
		
		ArenaLiveUnitFrames:UpdateTargetFrameDisplay(self);
		
		-- Update Constituent positions:
		self.UpdateElementPositions = UpdateElementPositions;
		self:UpdateElementPositions();
		
		-- Set OnUpdate script:
		self:SetScript("OnShow", OnShow);
		self:SetScript("OnUpdate", OnUpdate);
end

function ALUF_FocusTargetFrame:OnEnable()
	self:UpdateUnit("focus-target");
end