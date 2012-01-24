local FONT = [=[Fonts\FRIZQT__.TTF]=]
local TEXTURE = [=[Interface\ChatFrame\ChatFrameBackground]=]

local function Update(self)
	self.Health:SetSize(100, 6)
	self.Health:ClearAllPoints()
	self.Health:SetPoint('CENTER', self)

	self.Name:SetText(self.title:GetText())
	self.Highlight:SetAllPoints(self.Health)
end

local function UpdateThreat(self, elapsed)
	self.elapsed = (self.elapsed or 0) + elapsed

	if(self.elapsed > 0.2) then
		if(self.threat:IsShown()) then
			local r, g, b = self.threat:GetVertexColor()
			if(b > 0.7) then
				self.Health:SetStatusBarColor(2/3, 2/3, 1/4)
			else
				self.Health:SetStatusBarColor(2/3, 1/4, 1/5)
			end
		else
			self.Health:SetStatusBarColor(1/6, 1/6, 2/7)
		end
	end
end

local function UpdateCastbar(self)
	local parent = self:GetParent()
	self:SetSize(100, 6)
	self:ClearAllPoints()
	self:SetPoint('TOP', parent.Health, 'BOTTOM', 0, -5)

	if(parent.shield:IsShown()) then
		self:SetStatusBarColor(1, 1/4, 1/5)
	else
		self:SetStatusBarColor(3/4, 3/4, 3/4)
	end
end

local function InitiateFrame(self)
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
	Castbar.Backdrop = Backdrop

	local Background = Castbar:CreateTexture(nil, 'BORDER')
	Background:SetAllPoints()
	Background:SetTexture(1/3, 1/3, 1/3)

	Castbar:HookScript('OnShow', UpdateCastbar)
	Castbar:HookScript('OnSizeChanged', UpdateCastbar)
	Castbar:SetStatusBarTexture(TEXTURE)

	local Name = Health:CreateFontString(nil, 'OVERLAY')
	Name:SetPoint('BOTTOMLEFT', Health, 'TOPLEFT', 0, 2)
	Name:SetPoint('BOTTOMRIGHT', Health, 'TOPRIGHT', 0, 2)
	Name:SetFont(FONT, 8, 'OUTLINE')
	self.Name = Name

	local threat, overlay, Highlight, title, level, boss, RaidIcon, state = self:GetRegions()
	local bar, border, shield, icon = Castbar:GetRegions()

	Highlight:SetTexture(TEXTURE)
	Highlight:SetVertexColor(1, 1, 1, 1/4)
	self.Highlight = Highlight

	RaidIcon:ClearAllPoints()
	RaidIcon:SetPoint('LEFT', Health, 'RIGHT', 2, 0)
	RaidIcon:SetSize(12, 12)

	self.title = title
	self.shield = shield
	self.threat = threat

	threat:SetTexture(nil)
	overlay:SetTexture(nil)
	boss:SetTexture(nil)
	state:SetTexture(nil)
	border:SetTexture(nil)
	shield:SetTexture(nil)
	icon:SetWidth(0.01)
	title:SetWidth(0.01)
	level:SetWidth(0.01)

	self:SetScript('OnUpdate', UpdateThreat)
	self:SetScript('OnShow', Update)
	Update(self)
end

do
	local frame
	local select = select

	local function ProcessFrames(last, current)
		for index = last + 1, current do
			local frame = select(index, WorldFrame:GetChildren())

			local name = frame:GetName()
			if(name and name:find('NamePlate%d')) then
				InitiateFrame(frame)
			end
		end
	end

	local currentNum
	local numChildren = 0

	CreateFrame('Frame'):SetScript('OnUpdate', function()
		currentNum = WorldFrame:GetNumChildren()

		if(currentNum ~= numChildren) then
			ProcessFrames(numChildren, currentNum)
			numChildren = currentNum
		end
	end)
end
