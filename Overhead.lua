local FONT = [=[Interface\AddOns\Overhead\semplice.ttf]=]
local TEXTURE = [=[Interface\ChatFrame\ChatFrameBackground]=]

local isTank
local format = string.format

local function UpdateFrame(self)
	local levelString
	if(self.Boss:IsShown()) then
		levelString = '|cffff0000??|r'
	else
		local elite = ''
		if(self.Elite:IsShown()) then
			elite = '+'
		end

		local r, g, b = self.Level:GetTextColor()
		levelString = format('|cff%02x%02x%02x%s%s|r', r * 255, g * 255, b * 255, self.Level:GetText(), elite)
	end

	local r, g, b = self.ProtoHealth:GetStatusBarColor()
	nameString = format('|cff%02x%02x%02x%s|r', r * 255, g * 255, b * 255, self.Name:GetText())

	self.Health.Name:SetFormattedText('%s %s', levelString, nameString)
end

local function UpdateCast(self)
	local Cast = self.Clone
	if(self.Shield:IsShown()) then
		Cast:SetStatusBarColor(1/6, 1/6, 2/7)
	else
		Cast:SetStatusBarColor(1, 1/4, 1/5)
	end

	Cast.Icon:SetTexture(self.Icon:GetTexture())
	Cast.Name:SetText(self.Name:GetText())
end

local function UpdateThreat(self, elapsed)
	if(self.totalElapsed > 1/3) then
		if(self.Threat:IsShown()) then
			local r, g, b = self.Threat:GetVertexColor()

			local hasThreat = (g + b) < 0.1
			if(isTank) then
				if(hasThreat) then
					self.Health:SetStatusBarColor(1/6, 1/6, 2/7)
				else
					self.Health:SetStatusBarColor(1, 1/4, 1/5)
				end
			else
				if(hasThreat) then
					self.Health:SetStatusBarColor(1, 1/4, 1/5)
				else
					self.Health:SetStatusBarColor(1/6, 1/6, 2/7)
				end
			end
		else
			if(isTank) then
				self.Health:SetStatusBarColor(1, 1/4, 1/5)
			else
				self.Health:SetStatusBarColor(1/6, 1/6, 2/7)
			end
		end

		self.totalElapsed = 0
	else
		self.totalElapsed = self.totalElapsed + elapsed
	end
end

local function UpdateBar(self)
	local min, max = self:GetMinMaxValues()
	self.Clone:SetMinMaxValues(min, max)
	self.Clone:SetValue(self:GetValue())
	self.Clone:Show()
end

local function HideBar(self)
	self.Clone:Hide()
end

local function CreateStatusBar(self, proto, width, height, offset)
	local Bar = CreateFrame('StatusBar', nil, self)
	Bar:SetSize(width, height)
	Bar:SetStatusBarTexture(TEXTURE)
	Bar:SetStatusBarColor(1/6, 1/6, 2/7)

	local Backdrop = Bar:CreateTexture(nil, 'BACKGROUND')
	Backdrop:SetPoint('BOTTOMLEFT', -offset, -offset)
	Backdrop:SetPoint('TOPRIGHT', offset, offset)
	Backdrop:SetTexture(0, 0, 0)

	local Background = Bar:CreateTexture(nil, 'BORDER')
	Background:SetAllPoints()
	Background:SetTexture(1/3, 1/3, 1/3)

	local Name = Bar:CreateFontString(nil, 'OVERLAY')
	Name:SetPoint('LEFT', 3, 0)
	Name:SetPoint('RIGHT', -3, 0)
	Name:SetFont(FONT, 6, 'OUTLINEMONOCHROME')
	Name:SetJustifyH('LEFT')
	Bar.Name = Name

	proto.Clone = Bar
	proto:HookScript('OnValueChanged', UpdateBar)
	proto:HookScript('OnShow', UpdateBar)
	proto:HookScript('OnHide', HideBar)

	return Bar
end

local function Initialize(self)
	self:SetScale(1)
	local offset = 0.71111112833023 -- UIParent:GetScale() / self:GetEffectiveScale()

	local Cluster, Region = self:GetChildren()
	local ProtoHealth, ProtoCast = Cluster:GetChildren()

	local Health = CreateStatusBar(self, ProtoHealth, 140, 12, offset)
	Health:SetPoint('CENTER')

	local Cast = CreateStatusBar(self, ProtoCast, 140, 10, offset)
	Cast:SetPoint('TOPLEFT', Health, 'BOTTOMLEFT', 0, -4)
	Cast:Hide()

	ProtoHealth:SetScale(0.01)
	ProtoCast:SetScale(0.01)

	do
		local Icon = Cast:CreateTexture(nil, 'ARTWORK')
		Icon:SetPoint('BOTTOMLEFT', Cast, 'BOTTOMRIGHT', 4, 0)
		Icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
		Icon:SetSize(26, 26)
		Cast.Icon = Icon

		local Backdrop = Cast:CreateTexture(nil, 'BACKGROUND')
		Backdrop:SetPoint('BOTTOMLEFT', Icon, -offset, -offset)
		Backdrop:SetPoint('TOPRIGHT', Icon, offset, offset)
		Backdrop:SetTexture(0, 0, 0)

		local _, _, Shield, Icon, Name = ProtoCast:GetRegions()
		ProtoCast.Name = Name
		ProtoCast.Icon = Icon
		ProtoCast.Shield = Shield
	end

	do
		local Threat, Border, Glow, Level, Boss, RaidIcon, Elite = Cluster:GetRegions()
		Threat:SetTexture(nil)
		Border:SetTexture(nil)
		Elite:SetTexture(nil)
		Boss:SetTexture(nil)

		local Name = Region:GetRegions()
		Name:SetSize(0.01, 0.01)
		Level:SetSize(0.01, 0.01)

		RaidIcon:SetSize(18, 18)
		RaidIcon:ClearAllPoints()
		RaidIcon:SetPoint('TOPRIGHT', Health, 'TOPLEFT', -4, 0)

		self.Name = Name
		self.Boss = Boss
		self.Elite = Elite
		self.Level = Level
		self.Threat = Threat
		self.ProtoHealth = ProtoHealth
		self.Health = Health
		self.totalElapsed = 0
	end

	ProtoCast:HookScript('OnShow', UpdateCast)
	self:HookScript('OnShow', UpdateFrame)
	self:HookScript('OnUpdate', UpdateThreat)
	UpdateFrame(self)
end

local Handler = CreateFrame('Frame')
Handler:RegisterEvent('PLAYER_LOGIN')
Handler:RegisterEvent('ACTIVE_TALENT_GROUP_CHANGED')
Handler:SetScript('OnEvent', function()
	local _, _, _, _, _, role = GetSpecializationInfo(GetSpecialization())
	isTank = role == 'TANK'
end)

do
	local find = string.find
	local select = select

	local namePattern = 'NamePlate%d'

	local frame
	local currentNumChildren
	local lastNumChildren = 0

	local totalElapsed = 1
	Handler:SetScript('OnUpdate', function(self, elapsed)
		if(totalElapsed > 0.1) then
			currentNumChildren = WorldFrame:GetNumChildren()

			if(currentNumChildren ~= lastNumChildren) then
				for index = lastNumChildren + 1, currentNumChildren do
					frame = select(index, WorldFrame:GetChildren())

					local name = frame:GetName()
					if(name and find(name, namePattern)) then
						Initialize(frame)
					end
				end

				lastNumChildren = currentNumChildren
			end

			totalElapsed = 0
		else
			totalElapsed = totalElapsed + elapsed
		end
	end)
end
