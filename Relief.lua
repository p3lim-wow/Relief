--[[

 Copyright (c) 2009-2012, Adrian L Lange
 All rights reserved.

 You're allowed to use this addon, free of monetary charge,
 but you are not allowed to modify, alter, or redistribute
 this addon without express, written permission of the author.

--]]

local TEXTURE = [=[Interface\ChatFrame\ChatFrameBackground]=]

local Relief = CreateFrame('Frame', nil, Minimap)
Relief:SetScript('OnEvent', function(self, event, ...) self[event](self, ...) end)
Relief:RegisterEvent('PLAYER_LOGIN')
Relief:RegisterEvent('ADDON_LOADED')

function Relief:PLAYER_LOGIN()
	Minimap:ClearAllPoints()
	Minimap:SetParent(UIParent)
	Minimap:SetPoint('TOPRIGHT', -20, -20)
	Minimap:SetBackdrop({bgFile = TEXTURE, insets = {top = -1, bottom = -1, left = -1, right = -1}})
	Minimap:SetBackdropColor(0, 0, 0)
	Minimap:SetMaskTexture(TEXTURE)
	Minimap:SetArchBlobRingAlpha(0)
	Minimap:SetQuestBlobRingAlpha(0)
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

	QueueStatusMinimapButton:ClearAllPoints()
	QueueStatusMinimapButton:SetParent(Minimap)
	QueueStatusMinimapButton:SetPoint('TOPRIGHT')
	QueueStatusMinimapButton:SetHighlightTexture(nil)

	MiniMapMailFrame:ClearAllPoints()
	MiniMapMailFrame:SetParent(Minimap)
	MiniMapMailFrame:SetPoint('TOPLEFT')
	MiniMapMailIcon:SetTexture([=[Interface\Minimap\Tracking\Mailbox]=])

	MiniMapInstanceDifficulty:UnregisterAllEvents()
	MinimapCluster:EnableMouse(false)
	DurabilityFrame:SetAlpha(0)

	for _, object in pairs({
		BattlegroundShine,
		GameTimeFrame,
		MinimapBorder,
		MinimapBorderTop,
		MinimapNorthTag,
		MinimapZoomIn,
		MinimapZoomOut,
		MinimapZoneTextButton,
		MiniMapMailBorder,
		MiniMapTracking,
		MiniMapWorldMapButton,
		QueueStatusMinimapButtonBorder,
		QueueStatusMinimapButtonGroupSize,
	}) do
		if(object:GetObjectType() == 'Texture') then
			object:SetTexture(nil)
		else
			object.Show = object.Hide
			object:Hide()
		end
	end

	self:RegisterEvent('UPDATE_INVENTORY_DURABILITY')
end

function Relief:ADDON_LOADED(name)
	if(name ~= 'Relief') then return end

	local Neutral = self:CreateTexture(nil, 'BORDER', nil, 1)
	Neutral:SetTexture(0.6, 0.6, 0.6)
	Neutral:SetPoint('BOTTOMLEFT')
	Neutral:SetPoint('BOTTOMRIGHT')
	Neutral:SetHeight(4)
	self.Neutral = Neutral

	local Left = self:CreateTexture(nil, 'BORDER', nil, 2)
	Left:SetTexture(0, 0.38, 0.72)
	Left:SetPoint('BOTTOMLEFT')
	Left:SetHeight(4)
	self.Left = Left

	local Right = self:CreateTexture(nil, 'BORDER', nil, 2)
	Right:SetTexture(0.65, 0.22, 0)
	Right:SetPoint('BOTTOMRIGHT')
	Right:SetHeight(4)
	self.Right = Right

	local Spark = self:CreateTexture(nil, 'BORDER', nil, 3)
	Spark:SetTexture([=[Interface\WorldStateFrame\WorldState-CaptureBar]=])
	Spark:SetTexCoord(0.77734375, 0.796875, 0, 0.28125)
	Spark:SetSize(3.5, 9)
	self.Spark = Spark

	self:Hide()
	self:SetHeight(5)
	self:SetPoint('BOTTOMLEFT', 0, -9)
	self:SetPoint('BOTTOMRIGHT', 0, -9)

	self:SetBackdrop({bgFile = TEXTURE, insets = {top = -1, bottom = -1, left = -1, right = -1}})
	self:SetBackdropColor(0, 0, 0)

	self:RegisterEvent('UPDATE_WORLD_STATES')
	self:RegisterEvent('PLAYER_ENTERING_WORLD')
	self.PLAYER_ENTERING_WORLD = self.UPDATE_WORLD_STATES
	self:UPDATE_WORLD_STATES()
end

function Relief:UPDATE_INVENTORY_DURABILITY()
	local alert = 0
	for index in pairs(INVENTORY_ALERT_STATUS_SLOTS) do
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
end

function Relief:UPDATE_WORLD_STATES()
	for index = 1, NUM_EXTENDED_UI_FRAMES do
		local frame = _G['WorldStateCaptureBar' .. index]
		if(frame and frame:IsShown()) then
			frame:Hide()
			frame.Show = function() end
		end
	end

	for index = 1, GetNumWorldStateUI() do
		local _, shown, _, _, _, _, _, _, extended, pointer, spacing = GetWorldStateUIInfo(index)
		if(extended == 'CAPTUREPOINT') then
			if(shown == 1) then
				local totalWidth = math.floor(self:GetWidth())

				local width = (totalWidth - (totalWidth * (spacing / 100))) / 2
				self.Left:SetWidth(width)
				self.Right:SetWidth(width)

				self.Spark:SetPoint('RIGHT', self.Neutral, - (pointer * ((totalWidth - 2) / 100)), 0)

				self:Show()
			else
				self:Hide()
			end
		end
	end
end

function TimeManager_LoadUI() end

LFG_EYE_TEXTURES.unknown.file = nil
LFG_EYE_TEXTURES.raid = {
	file = [=[Interface\AddOns\Relief\eye]=], frames = 29,
	delay = 0.1, iconSize = 64, height = 256, width = 512,
}
