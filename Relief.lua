--[[

 Copyright (c) 2009-2012, Adrian L Lange
 All rights reserved.

 You're allowed to use this addon, free of monetary charge,
 but you are not allowed to modify, alter, or redistribute
 this addon without express, written permission of the author.

--]]

local Relief = CreateFrame('Frame')
Relief:SetScript('OnEvent', function(self, event) self[event](self) end)
Relief:RegisterEvent('PLAYER_LOGIN')

function Relief:PLAYER_LOGIN()
	Minimap:ClearAllPoints()
	Minimap:SetParent(UIParent)
	Minimap:SetPoint('TOPRIGHT', -20, -20)
	Minimap:SetBackdrop({bgFile = [=[Interface\ChatFrame\ChatFrameBackground]=], insets = {top = -1, bottom = -1, left = -1, right = -1}})
	Minimap:SetBackdropColor(0, 0, 0)
	Minimap:SetMaskTexture([=[Interface\ChatFrame\ChatFrameBackground]=])
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

	MinimapDurability = Minimap:CreateTexture(nil, 'BORDER')
	MinimapDurability:SetPoint('TOPRIGHT')
	MinimapDurability:SetTexture([=[Interface\Cursor\Item]=])
	MinimapDurability:SetTexCoord(1/2, 0, 0, 1/2)
	MinimapDurability:SetSize(16, 16)
	DurabilityFrame:SetAlpha(0)

	MiniMapLFGFrame:ClearAllPoints()
	MiniMapLFGFrame:SetParent(Minimap)
	MiniMapLFGFrame:SetPoint('TOPRIGHT')
	MiniMapLFGFrame:SetHighlightTexture(nil)
	MiniMapLFGFrame:SetScript('OnClick', function(self, button)
		local mode = GetLFGMode()
		if(button == 'RightButton' and (mode == 'lfgparty' or mode == 'abandonedInDungeon')) then
			LFGTeleport(IsInLFGDungeon())
		else
			MiniMapLFGFrame_OnClick(self, button)
		end
	end)

	MiniMapBattlefieldFrame:ClearAllPoints()
	MiniMapBattlefieldFrame:SetParent(Minimap)
	MiniMapBattlefieldFrame:SetPoint('TOPRIGHT')

	MiniMapMailFrame:ClearAllPoints()
	MiniMapMailFrame:SetParent(Minimap)
	MiniMapMailFrame:SetPoint('TOPLEFT')
	MiniMapMailIcon:SetTexture([=[Interface\Minimap\Tracking\Mailbox]=])

	MiniMapInstanceDifficulty:UnregisterAllEvents()
	MinimapCluster:EnableMouse(false)

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
		MiniMapMailBorder,
		MiniMapTracking,
		MiniMapWorldMapButton,
		MiniMapLFGFrameGroupSize,
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
		MinimapDurability:SetVertexColor(color.r, color.g, color.b)
		MinimapDurability:Show()
	else
		MinimapDurability:Hide()
	end
end

function TimeManager_LoadUI() end

LFG_EYE_TEXTURES.unknown = LFG_EYE_TEXTURES.default
LFG_EYE_TEXTURES.raid = LFG_EYE_TEXTURES.default
LFG_EYE_TEXTURES.raid.file = [=[Interface\AddOns\Relief\eye]=]
