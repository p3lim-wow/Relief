
local function Update(self)
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

local Capture = CreateFrame('Frame', nil, Minimap)
Capture:RegisterEvent('ADDON_LOADED')
Capture:SetScript('OnEvent', function(self, event, name)
	if(name ~= 'Relief') then return end

	local Background = self:CreateTexture(nil, 'BORDER')
	Background:SetTexture(0, 0, 0)
	Background:SetPoint('BOTTOMLEFT')
	Background:SetPoint('BOTTOMRIGHT')
	Background:SetHeight(4)

	local Neutral = self:CreateTexture(nil, 'BORDER', nil, 1)
	Neutral:SetTexture(0.6, 0.6, 0.6)
	Neutral:SetPoint('BOTTOMLEFT')
	Neutral:SetPoint('BOTTOMRIGHT')
	Neutral:SetHeight(3)
	self.Neutral = Neutral

	local Left = self:CreateTexture(nil, 'BORDER', nil, 2)
	Left:SetTexture(0, 0.38, 0.72)
	Left:SetPoint('BOTTOMLEFT')
	Left:SetHeight(3)
	self.Left = Left

	local Right = self:CreateTexture(nil, 'BORDER', nil, 2)
	Right:SetTexture(0.65, 0.22, 0)
	Right:SetPoint('BOTTOMRIGHT')
	Right:SetHeight(3)
	self.Right = Right

	local Spark = self:CreateTexture(nil, 'BORDER', nil, 3)
	Spark:SetTexture([=[Interface\WorldStateFrame\WorldState-CaptureBar]=])
	Spark:SetTexCoord(0.77734375, 0.796875, 0, 0.28125)
	Spark:SetSize(3.5, 9)
	self.Spark = Spark

	self:Hide()
	self:SetAllPoints()
	self:RegisterEvent('UPDATE_WORLD_STATES')
	self:RegisterEvent('PLAYER_ENTERING_WORLD')
	self:SetScript('OnEvent', Update)

	Update(self)
end)
