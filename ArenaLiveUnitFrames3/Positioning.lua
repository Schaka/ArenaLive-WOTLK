local addonName = ...;
local L = ArenaLiveUnitFrames.L;

ArenaLiveUnitFrames.handlersToPosition = {
	["Aura"] = true,
	["CastBar"] = true,
	["CastHistory"] = true,
	["DRTracker"] = true,
	["PetFrame"] = true,
	["TargetFrame"] = true,
	["AltPowerBar"] = true,
};

local frameToUpdate = {};
local attachedToCache = {};
function ArenaLiveUnitFrames:UpdateAttachedToCache(frameGroup)
	-- Reset old info:
	table.wipe(attachedToCache);
	
	local database = ArenaLive:GetDBComponent(addonName, nil, frameGroup);
	for handlerName in pairs(ArenaLiveUnitFrames.handlersToPosition) do
		if ( database[handlerName] and database[handlerName].Position ) then
			local attachedTo = database[handlerName].Position.AttachedTo
			attachedToCache[handlerName] = attachedTo;
			--print(handlerName, attachedTo);
		end
	end
end

function ArenaLiveUnitFrames:IsHandlerDependentOnHandler(handlerName, dependentName)
	
	if ( not handlerName or not dependentName ) then -- Handle invalid queries.
		return false;
	elseif ( handlerName == dependentName ) then -- You cannot attach an element to itself.
		return true;
	end

	local returnValue;
	local dependentAttachedTo = attachedToCache[dependentName];
	local originalAttachedTo = dependentAttachedTo;
	local i = 0;
	repeat
		dependentAttachedTo = attachedToCache[dependentAttachedTo];
		if ( handlerName == dependentAttachedTo ) then
			returnValue = true;
		elseif ( not dependentAttachedTo or dependentAttachedTo == "UnitFrame" ) then
			returnValue = false;
		elseif ( dependentAttachedTo == originalAttachedTo ) then
			returnValue = true;
		end
		
		i = i + 1;
		--print(i, handlerName, dependentName, dependentAttachedTo, originalAttachedTo, returnValue);
	until ( type(returnValue) == "boolean" or i > 7 )

	return returnValue;
end


function ArenaLiveUnitFrames:SetFramePositions(frame)
	if ( not InCombatLockdown() ) then
		local database = ArenaLive:GetDBComponent(frame.addon, nil, frame.group);

		-- Clear all points first, to make sure we do not attach to elements to eachother after a change:
		for handlerName in pairs(ArenaLiveUnitFrames.handlersToPosition) do
			if ( frame[handlerName] and database[handlerName] and database[handlerName]["Position"] ) then
				frame[handlerName]:ClearAllPoints();
			end
		end
		
		-- Now set new values:
		ArenaLiveUnitFrames:UpdateAttachedToCache(frame.group);
		for handlerName in pairs(ArenaLiveUnitFrames.handlersToPosition) do
			if ( frame[handlerName] and database[handlerName] and database[handlerName].Position ) then
				local position, attachedTo, xOffset, yOffset = database[handlerName].Position.Position, database[handlerName].Position.AttachedTo, database[handlerName].Position.XOffset, database[handlerName].Position.YOffset;
				local object = frame[handlerName];
				local relativeTo = frame[attachedTo] or frame;
				
				local point, relativePoint;
				if ( position == "LEFT" ) then
					point = "TOPRIGHT"
					relativePoint = "TOPLEFT";
				elseif ( position == "RIGHT" ) then
					point = "TOPLEFT"
					relativePoint = "TOPRIGHT";
				elseif ( position == "ABOVE" ) then
					point = "BOTTOMLEFT"
					relativePoint = "TOPLEFT";
				elseif ( position == "BELOW" ) then
					point = "TOPLEFT"
					relativePoint = "BOTTOMLEFT";
				else
					-- Fallback:
					point = "TOPRIGHT"
					relativePoint = "TOPLEFT";
				end
				local isDependent = ArenaLiveUnitFrames:IsHandlerDependentOnHandler(handlerName, attachedTo);
				if ( isDependent ) then
					local frameName = frame:GetName() or tostring(frame);
					ArenaLive:Message(L["Tried to attach %s's %s to %s, although %s's positioning is dependent on %s. Please change that in ArenaLive [UnitFrames]'s option menu."], "message", frameName, L[handlerName] or handlerName, L[attachedTo] or attachedTo, L[attachedTo] or attachedTo, L[handlerName] or handlerName);
				else
					object:SetPoint(point, relativeTo, relativePoint, xOffset, yOffset);
				end
			end
		end
	else
		frameToUpdate[frame] = true;
	end
end

function ArenaLiveUnitFrames:UpdateFramePositionsAfterLockDown()
	for frame in pairs(frameToUpdate) do
		ArenaLiveUnitFrames:SetFramePositions(frame);
	end
end