local FONT = [=[Interface\AddOns\Overhead\semplice.ttf]=]
local TEXTURE = [=[Interface\ChatFrame\ChatFrameBackground]=]

local function Update(self)
	local r, g, b = self.Health:GetStatusBarColor()
	self.Health:SetStatusBarColor(r * 2/3, g * 2/3, b * 2/3)
	self.Health:SetSize(100, 6)
	self.Health:ClearAllPoints()
	self.Health:SetPoint('CENTER', self)

	self.Name:SetText(self.title:GetText())
	self.Highlight:SetAllPoints(self.Health)
end

local function UpdateCastbar(self)
	self:SetSize(100, 6)
	self:ClearAllPoints()
	self:SetPoint('TOP', self:GetParent().Health, 'BOTTOM', 0, -4)

	if(self.shield:IsShown()) then
		self:SetStatusBarColor(1, 1/4, 1/5)
	else
		self:SetStatusBarColor(3/4, 3/4, 3/4)
	end
end

local function Initialize(self)
	local Health, Castbar = self:GetChildren()

	local offset = UIParent:GetScale() / Health:GetEffectiveScale()
	local Backdrop = Health:CreateTexture(nil, 'BACKGROUND')
	Backdrop:SetPoint('BOTTOMLEFT', -offset, -offset)
	Backdrop:SetPoint('TOPRIGHT', offset, offset)
	Backdrop:SetTexture(0, 0, 0)
	Health.Backdrop = Backdrop

	local Background = Health:CreateTexture(nil, 'BORDER')
	Background:SetAllPoints()
	Background:SetTexture(1/3, 1/3, 1/3)

	Health:SetStatusBarTexture(TEXTURE)
	self.Health = Health

	local offset = UIParent:GetScale() / Castbar:GetEffectiveScale()
	local Backdrop = Castbar:CreateTexture(nil, 'BACKGROUND')
	Backdrop:SetPoint('BOTTOMLEFT', -offset, -offset)
	Backdrop:SetPoint('TOPRIGHT', offset, offset)
	Backdrop:SetTexture(0, 0, 0)

	local Background = Castbar:CreateTexture(nil, 'BORDER')
	Background:SetAllPoints()
	Background:SetTexture(1/3, 1/3, 1/3)

	Castbar:HookScript('OnShow', UpdateCastbar)
	Castbar:HookScript('OnSizeChanged', UpdateCastbar)
	Castbar:SetStatusBarTexture(TEXTURE)

	local Name = Health:CreateFontString(nil, 'OVERLAY')
	Name:SetPoint('BOTTOMLEFT', Health, 'TOPLEFT', 0, 2)
	Name:SetPoint('BOTTOMRIGHT', Health, 'TOPRIGHT', 0, 2)
	Name:SetFont(FONT, 6, 'OUTLINEMONOCHROME')
	self.Name = Name

	local threat, overlay, Highlight, title, level, boss, RaidIcon, state = self:GetRegions()
	local __, border, shield, icon = Castbar:GetRegions()

	Highlight:SetTexture(TEXTURE)
	Highlight:SetVertexColor(1, 1, 1, 1/4)
	self.Highlight = Highlight

	RaidIcon:ClearAllPoints()
	RaidIcon:SetPoint('LEFT', Health, 'RIGHT', 2, 0)
	RaidIcon:SetSize(12, 12)

	self.title = title
	Castbar.shield = shield

	threat:SetTexture(nil)
	overlay:SetTexture(nil)
	boss:SetTexture(nil)
	state:SetTexture(nil)
	border:SetTexture(nil)
	shield:SetTexture(nil)
	icon:SetWidth(0.01)
	title:SetWidth(0.01)
	level:SetWidth(0.01)

	self:SetScript('OnShow', Update)

	Update(self)
end

local index = 1
local global = 'NamePlate'

local handler = CreateFrame('Frame')
handler:RegisterEvent('PLAYER_LOGIN')
handler:RegisterEvent('PLAYER_LOGOUT')

local animation = handler:CreateAnimationGroup()
animation:CreateAnimation():SetDuration(1/5)
animation:SetLooping('REPEAT')
animation:SetScript('OnLoop', function()
	if(t3zlcmhlywq and _G[global .. t3zlcmhlywq]) then
		index = t3zlcmhlywq
		t3zlcmhlywq = nil
	end

	while(_G[global .. index]) do
		Initialize(_G[global .. index])

		if(t3zlcmhlywq) then
			t3zlcmhlywq = nil
		end

		index = index + 1
	end
end)

handler:SetScript('OnEvent', function(self, event)
	if(event == 'PLAYER_LOGIN') then
		animation:Play()
	else
		t3zlcmhlywq = index
	end
end)
