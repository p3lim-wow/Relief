--[[

 Copyright (c) 2009-2010, Adrian L Lange
 All rights reserved.

 You're allowed to use this addon, free of monetary charge,
 but you are not allowed to modify, alter, or redistribute
 this addon without express, written permission of the author.

--]]

local TEXTURE = [=[Interface\ChatFrame\ChatFrameBackground]=]

local parent = CreateFrame('Frame')
parent:SetScript('OnEvent', function(self, event) self[event](Minimap) end)
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
	MiniMapTracking,
	MiniMapWorldMapButton,
}) do
	if(object:GetObjectType() == 'Texture') then
		object:SetTexture(nil)
	else
		object:Hide()
	end
end

function parent:PLAYER_LOGIN()
	self:ClearAllPoints()
	self:SetParent(UIParent)
	self:SetPoint('TOPRIGHT', -20, -20)
	self:SetBackdrop({bgFile = TEXTURE, insets = {top = -1, bottom = -1, left = -1, right = -1}})
	self:SetBackdropColor(0, 0, 0)
	self:SetMaskTexture(TEXTURE)
	self:SetScale(0.9)

	self:EnableMouseWheel()
	self:SetScript('OnMouseWheel', function(self, direction)
		self:SetZoom(self:GetZoom() + (self:GetZoom() == 0 and direction < 0 and 0 or direction))
	end)

	Minimap:SetScript('OnMouseUp', function(self, button)
		if(button == 'RightButton') then
			ToggleDropDownMenu(1, nil, MiniMapTrackingDropDown, 'cursor')
		else
			Minimap_OnClick(self)
		end
	end)

	MiniMapLFGFrame:ClearAllPoints()
	MiniMapLFGFrame:SetParent(self)
	MiniMapLFGFrame:SetPoint('TOPRIGHT')
	MiniMapLFGFrame:SetHighlightTexture(nil)

	MiniMapBattlefieldFrame:ClearAllPoints()
	MiniMapBattlefieldFrame:SetParent(self)
	MiniMapBattlefieldFrame:SetPoint('TOPRIGHT')

	MiniMapInstanceDifficulty:UnregisterAllEvents()
	MiniMapMailFrame:UnregisterAllEvents()
	MinimapCluster:EnableMouse(false)
end
