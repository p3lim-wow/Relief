local TEXTURE = [[Interface\ChatFrame\ChatFrameBackground]]
local BACKDROP = {
	bgFile = TEXTURE,
	insets = {top = -1, bottom = -1, left = -1, right = -1}
}

local Relief = CreateFrame('Frame', nil, Minimap)
Relief:SetScript('OnEvent', function(self, event, ...) self[event](self, ...) end)
Relief:RegisterEvent('PLAYER_LOGIN')

function Relief:PLAYER_LOGIN()
	Minimap:ClearAllPoints()
	Minimap:SetParent(UIParent)
	Minimap:SetPoint('TOPRIGHT', -20, -20)
	Minimap:SetBackdrop(BACKDROP)
	Minimap:SetBackdropColor(0, 0, 0)
	Minimap:SetMaskTexture(TEXTURE)
	Minimap:SetArchBlobRingScalar(0)
	Minimap:SetQuestBlobRingScalar(0)
	Minimap:SetScale(0.9)

	Minimap:SetScript('OnMouseUp', function(self, button)
		if(button == 'RightButton') then
			ToggleDropDownMenu(1, nil, MiniMapTrackingDropDown, 'cursor')
		elseif(button == 'MiddleButton') then
			ToggleCalendar()
		else
			Minimap_OnClick(self)
		end
	end)

	Minimap:SetScript('OnMouseWheel', function(self, direction)
		self:SetZoom(self:GetZoom() + (self:GetZoom() == 0 and direction < 0 and 0 or direction))
	end)

	GarrisonLandingPageMinimapButton:ClearAllPoints()
	GarrisonLandingPageMinimapButton:SetParent(Minimap)
	GarrisonLandingPageMinimapButton:SetPoint('BOTTOMLEFT')
	GarrisonLandingPageMinimapButton:SetSize(32, 32)

	QueueStatusMinimapButton:ClearAllPoints()
	QueueStatusMinimapButton:SetParent(Minimap)
	QueueStatusMinimapButton:SetPoint('TOPRIGHT')
	QueueStatusMinimapButton:SetHighlightTexture(nil)

	MiniMapMailFrame:ClearAllPoints()
	MiniMapMailFrame:SetParent(Minimap)
	MiniMapMailFrame:SetPoint('TOPLEFT')
	MiniMapMailIcon:SetTexture([[Interface\Minimap\Tracking\Mailbox]])

	MiniMapInstanceDifficulty:Hide()
	MiniMapInstanceDifficulty:UnregisterAllEvents()
	MinimapCluster:EnableMouse(false)
	DurabilityFrame:SetAlpha(0)

	for _, name in next, {
		'GameTimeFrame',
		'MinimapBorder',
		'MinimapBorderTop',
		'MinimapNorthTag',
		'MinimapZoomIn',
		'MinimapZoomOut',
		'MinimapZoneTextButton',
		'MiniMapMailBorder',
		'MiniMapTracking',
		'MiniMapWorldMapButton',
		'QueueStatusMinimapButtonBorder',
		'QueueStatusMinimapButtonGroupSize',
	} do
		local object = _G[name]
		if(object:GetObjectType() == 'Texture') then
			object:SetTexture(nil)
		else
			object.Show = object.Hide
			object:Hide()
		end
	end

	SetCVar('rotateMinimap', 0)

	self:UPDATE_INVENTORY_DURABILITY()
	self:RegisterEvent('UPDATE_INVENTORY_DURABILITY')
	self:RegisterEvent('UPDATE_PENDING_MAIL')

	local LDB = LibStub('LibDataBroker-1.1')
	if(not LDB --[[or not IsAddOnLoaded('BugSack')]]) then
		return
	end

	local data = LDB:GetDataObjectByName('BugSack')
	if(data) then
		local Button = CreateFrame('Button', nil, Minimap)
		Button:SetPoint('BOTTOMRIGHT', -5, 5)
		Button:SetSize(20, 20)
		Button:SetScript('OnClick', data.OnClick)
		Button:SetScript('OnLeave', GameTooltip_Hide)
		Button:SetScript('OnEnter', function(self)
			GameTooltip:SetOwner(self, 'ANCHOR_LEFT')
			GameTooltip:SetClampedToScreen(true)
			pcall(data.OnTooltipShow, GameTooltip)
			GameTooltip:Show()
		end)

		if(not string.find(data.icon, 'red')) then
			Button:SetAlpha(0)
		end

		local Icon = Button:CreateTexture(nil, 'OVERLAY')
		Icon:SetTexture([[Interface\CharacterFrame\UI-Player-PlayTimeUnhealthy]])
		Icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
		Icon:SetAllPoints()

		LDB.RegisterCallback(Button, 'LibDataBroker_AttributeChanged_BugSack', function()
			if(string.find(data.icon, 'red')) then
				Button:SetAlpha(1)
			else
				Button:SetAlpha(0)
			end
		end)
	end
end

function Relief:UPDATE_INVENTORY_DURABILITY()
	local alert = 0
	for index in next, INVENTORY_ALERT_STATUS_SLOTS do
		local status = GetInventoryAlertStatus(index)
		if(status > alert) then
			alert = status
		end
	end

	local color = INVENTORY_ALERT_COLORS[alert]
	if(color) then
		Minimap:SetBackdropColor(color.r * 2/3 , color.g * 2/3 , color.b * 2/3 )
	else
		Minimap:SetBackdropColor(0, 0, 0)
	end

	for index = 1, GetNumTrackingTypes() do
		local name, _, active = GetTrackingInfo(index)
		if(name == MINIMAP_TRACKING_REPAIR) then
			return SetTracking(index, alert > 0)
		end
	end
end

function Relief:UPDATE_PENDING_MAIL()
	if(GetRestrictedAccountData() > 0) then
		return MiniMapMailFrame:Hide()
	end

	for index = 1, GetNumTrackingTypes() do
		local name, _, active = GetTrackingInfo(index)
		if(name == MINIMAP_TRACKING_MAILBOX) then
			return SetTracking(index, HasNewMail() and not active)
		end
	end
end

function TimeManager_LoadUI() end
