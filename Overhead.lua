local select = select

local font = [=[Interface\AddOns\Overhead\media\font.ttf]=]
local barTexture = [=[Interface\AddOns\Overhead\media\minimalist]=]
local overlayTexture = [=[Interface\TargetingFrame\UI-TargetingFrame-Flash]=]

local numChildren = -1
local frames = {}

local function updateTime(self, curValue)
	if(UnitChannelInfo('target')) then
		self.time:SetFormattedText('%.1f', curValue)
	else
		local minValue, maxValue = self:GetMinMaxValues()
		self.time:SetFormattedText('%.1f', maxValue - curValue)
	end
end

local function updateCastbar(self, shielded)
	if(shielded) then
		self:SetStatusBarColor(0.8, 1, .8)
	end
end

local function updateObjects(self)
	self:SetHeight(7.5)
	self:SetWidth(100)
	self:ClearAllPoints()
	self = self:GetParent()

	self.health:SetPoint('CENTER', self)
	self.cast:SetPoint('TOP', self.health, 'BOTTOM', 0, -6)

	self.icon:SetHeight(0.01)
	self.icon:SetWidth(0.01)

	self.level:ClearAllPoints()
	self.level:SetPoint('RIGHT', health, 'LEFT', -3, 0)

	if(self.boss:IsShown()) then
		self.level:SetText('B+')
	elseif(self.elite:IsShown()) then
		self.level:SetFormattedText('%s+', self.level:GetText())
	end
end

local function createObjects(frame)
	local health, cast = frame:GetChildren()
	local glow, healthBorder, castShield, castBorder, icon, highlight, name, level, boss, raid, elite = frame:GetRegions()

	health:SetStatusBarTexture(barTexture)
	health.bg = health:CreateTexture(nil, 'BORDER')
	health.bg:SetAllPoints(health)
	health.bg:SetTexture(0.15, 0.15, 0.15, 0.8)

	cast:SetStatusBarTexture(barTexture)
	cast.bg = cast:CreateTexture(nil, 'BORDER')
	cast.bg:SetAllPoints(cast)
	cast.bg:SetTexture(0.15, 0.15, 0.15, 0.8)

	cast.time = cast:CreateFontString(nil, 'ARTWORK')
	cast.time:SetPoint('RIGHT', cast, 'LEFT', -3, 0)
	cast.time:SetFont(font, 9, 'OUTLINE')

	cast:HookScript('OnValueChanged', updateTime)
	updateTime(cast, cast:GetValue())
	updateCastbar(cast, castShield:IsShown())

	name:ClearAllPoints()
	name:SetPoint('BOTTOM', health, 'TOP', 0, 3)
	name:SetFont(font, 11, 'OUTLINE')
	name:SetShadowOffset(0, 0)

	level:SetFont(font, 9, 'OUTLINE')
	level:SetShadowOffset(0, 0)

	raid:SetScale(0.6)
	raid:ClearAllPoints()
	raid:SetPoint('RIGHT', name, 'LEFT', -4, 0)

	healthBorder:SetTexture(nil)
	castShield:SetTexture(nil)
	castBorder:SetTexture(nil)
	highlight:SetTexture(nil)
	glow:SetTexture(nil)
	boss:SetTexture(nil)
	elite:SetTexture(nil)

	frame.level, frame.boss, frame.elite = level, boss, elite
	frame.health, frame.cast, frame.icon = health, cast, icon
end

local function hookFrames(...)
	for index = 1, select('#', ...) do
		local frame = select(index, ...)
		local region = frame:GetRegions()

		if(not frames[frame] and not frame:GetName() and region and region:GetObjectType() == 'Texture' and region:GetTexture() == overlayTexture) then
			createObjects(frame)

			local health, cast = frame:GetChildren()
			health:HookScript('OnShow', updateObjects)
			cast:HookScript('OnShow', updateObjects)

			updateObjects(health)
			updateObjects(cast)

			frames[frame] = true
		end
	end
end

CreateFrame('Frame'):SetScript('OnUpdate', function()
	if(WorldFrame:GetNumChildren() ~= numChildren) then
		numChildren = WorldFrame:GetNumChildren()
		hookFrames(WorldFrame:GetChildren())
	end
end)
