--[[

 Copyright (c) 2009-2010, Adrian L Lange
 All rights reserved.

 You're allowed to use this addon, free of monetary charge,
 but you are not allowed to modify, alter, or redistribute
 this addon without express, written permission of the author.

--]]

local FONT = [=[Interface\AddOns\Relief\semplice.ttf]=]
local TEXTURE = [=[Interface\ChatFrame\ChatFrameBackground]=]

local parent = CreateFrame('Button', nil, Minimap)
parent:SetScript('OnEvent', function(self, event) self[event](Minimap) end)
parent:RegisterEvent('UPDATE_INVENTORY_ALERTS')
parent:RegisterEvent('UPDATE_PENDING_MAIL')
parent:RegisterEvent('PLAYER_LOGIN')

for _, object in pairs({
	BattlegroundShine,
	GameTimeFrame,
	MinimapBorder,
	MinimapBorderTop,
	MinimapNorthTag,
	MinimapZoomIn,
	MinimapZoomOut,
	MinimapZoneTextButton,
	MiniMapBattlefieldBorder,
	MiniMapLFGFrameBorder,
	MiniMapTrackingBackground,
	MiniMapTrackingButtonBorder,
	MiniMapTrackingIconOverlay,
	MiniMapWorldMapButton,
}) do
	if(object:GetObjectType() == 'Texture') then
		object:SetTexture(nil)
	else
		object:Hide()
	end
end

function parent:UPDATE_INVENTORY_ALERTS()
	local status = 0
	for slot in pairs(INVENTORY_ALERT_STATUS_SLOTS) do
		local current = GetInventoryAlertStatus(slot)
		status = current > status and current or status
	end

	local color = INVENTORY_ALERT_COLORS[status]
	if(color) then
		self.Time:SetTextColor(color.r, color.g, color.b)
	else
		self.Time:SetTextColor(1, 1, 1)
	end
end

function parent:UPDATE_PENDING_MAIL()
	if(HasNewMail()) then
		for index = 1, GetNumTrackingTypes() do
			local name, _, active = GetTrackingInfo(index)
			if(name == MINIMAP_TRACKING_MAILBOX and not active) then
				return SetTracking(index)
			end
		end
	else
		SetTracking(nil)
	end
end

function parent:PLAYER_LOGIN()
	self:ClearAllPoints()
	self:SetParent(UIParent)
	self:SetPoint('TOPRIGHT', -20, -20)
	self:SetBackdrop({bgFile = TEXTURE, insets = {top = -2, bottom = -1, left = -2, right = -1}}) -- Stupid UIScale
	self:SetBackdropColor(0, 0, 0)
	self:SetMaskTexture(TEXTURE)
	self:SetScale(0.9)

	self:EnableMouseWheel()
	self:SetScript('OnMouseWheel', function(self, direction)
		self:SetZoom(self:GetZoom() + (self:GetZoom() == 0 and direction < 0 and 0 or direction))
	end)

	MiniMapTracking:ClearAllPoints()
	MiniMapTracking:SetParent(self)
	MiniMapTracking:SetPoint('TOPLEFT')
	MiniMapTrackingIcon:SetTexCoord(0.065, 0.935, 0.065, 0.935)
	MiniMapTrackingButton:SetHighlightTexture(nil)

	MiniMapLFGFrame:ClearAllPoints()
	MiniMapLFGFrame:SetParent(self)
	MiniMapLFGFrame:SetPoint('TOPRIGHT')
	MiniMapLFGFrame:SetHighlightTexture(nil)

	MiniMapBattlefieldFrame:ClearAllPoints()
	MiniMapBattlefieldFrame:SetParent(self)
	MiniMapBattlefieldFrame:SetPoint('TOPRIGHT')

	self.Time = parent:CreateFontString(nil, 'ARTWORK')
	self.Time:SetAllPoints(parent)
	self.Time:SetFont(FONT, 9, 'OUTLINE')

	parent:SetWidth(40)
	parent:SetHeight(10)
	parent:SetPoint('BOTTOM')
	parent:RegisterForClicks('AnyUp')
	parent:SetScript('OnClick', function(self, button)
		if(button == 'LeftButton') then
			ToggleCalendar()
		elseif(button == 'RightButton' and IsAddOnLoaded('Broker_Equipment')) then
			LibStub('LibDataBroker-1.1'):GetDataObjectByName('Broker_Equipment').OnClick(self)
		end
	end)

	parent:SetScript('OnUpdate', function()
		self.Time:SetFormattedText(TIMEMANAGER_TICKER_24HOUR, GetGameTime())
	end)

	DurabilityFrame:UnregisterAllEvents()
	MiniMapInstanceDifficulty:UnregisterAllEvents()
	MiniMapMailFrame:UnregisterAllEvents()
	MinimapCluster:EnableMouse(false)
end
