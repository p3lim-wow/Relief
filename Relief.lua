--[[

 Copyright (c) 2009-2010, Adrian L Lange
 All rights reserved.

 You're allowed to use this addon, free of monetary charge,
 but you are not allowed to modify, alter, or redistribute
 this addon without express, written permission of the author.

--]]

local TEXTURE = [=[Interface\ChatFrame\ChatFrameBackground]=]

local parent = CreateFrame('Frame')
parent:RegisterEvent('PLAYER_LOGIN')
parent:SetScript('OnEvent', function()
	Minimap:ClearAllPoints()
	Minimap:SetParent(UIParent)
	Minimap:SetPoint('TOPRIGHT', -20, -20)
	Minimap:SetBackdrop({bgFile = TEXTURE, insets = {top = -1, bottom = -1, left = -1, right = -1}})
	Minimap:SetBackdropColor(0, 0, 0)
	Minimap:SetMaskTexture(TEXTURE)
	Minimap:SetScale(0.9)

	Minimap:EnableMouseWheel()
	Minimap:SetScript('OnMouseWheel', function(self, direction)
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
	MiniMapLFGFrame:SetParent(Minimap)
	MiniMapLFGFrame:SetPoint('TOPRIGHT')
	MiniMapLFGFrame:SetHighlightTexture(nil)

	MiniMapBattlefieldFrame:ClearAllPoints()
	MiniMapBattlefieldFrame:SetParent(Minimap)
	MiniMapBattlefieldFrame:SetPoint('TOPRIGHT')

	MiniMapInstanceDifficulty:UnregisterAllEvents()
	MiniMapMailFrame:UnregisterAllEvents()
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
		MiniMapTracking,
		MiniMapWorldMapButton,
	}) do
		if(object:GetObjectType() == 'Texture') then
			object:SetTexture(nil)
		else
			object:Hide()
		end
	end
end
