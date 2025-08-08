-- // Services
local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local SoundService = game:GetService("SoundService")

-- // Obj
local CratesFolder: Folder = ReplicatedStorage.Crates
local CurrentLuck = ReplicatedStorage:WaitForChild("Luck"):WaitForChild("LuckAmount")

-- // packages
local Signal = require("@Packages/Signal")
local t = require("@Packages/t")

-- // Utils
local Remotes = require("@Shared/Remotes")

local Log = require("@Utility/Log")
--local TweenModel = require("@Utility/TweenModel")

local GetRandomDictionaryIndex = require("@Utility/GetRandomDictionaryIndex")
local GetRarity = require("@Utility/GetRarity")

local DataUtil = require("@ServerUtility/DataUtil")

local Types = require("@Shared/Types")

local Spring = require("@Utility/Spring")

local CrateConfig = require("@Config/Crates")
local LabubuConfig = require("@Config/Labubus")
local SizeConfig = require("@Config/Sizes")
local ToolConfig = require("@Config/Tools")
local UpgradesConfig = require("@Config/Upgrades")

local Labubu = require("@ServerClasses/Labubu")

local GetNextOpenSlot = require("@Utility/GetNextOpenSlot")
local GetPlayerPlot = require("@Utility/GetPlayerPlot")

-- // Const
local SCALE_VALUES = {
	Up = {
		[1] = 1.15,
		[2] = 1.1,
		[3] = 1.05,
		[4] = 1.2,
	},
	Down = {
		[1] = 0.9,
		[2] = 0.85,
		[3] = 0.77,
		[4] = 0.95,
	},
}

-- // Init
local Crate = {}
Crate.__index = Crate

type CrateData = {
	Name: string,
	Owner: Player,
	Config: Types.CrateConfig,
	MaxHealth: number,
	Model: Model,
	Primary: Part,
	Destroying: typeof(Signal.new()),

	StartingScale: number,

	_junk: { RBXScriptConnection },
}
export type Crate = typeof(setmetatable({} :: CrateData, Crate))

local crateCheck = t.tuple(t.string, t.Vector3, t.Instance)
function Crate.new(Name: string, SpawnLocation: Vector3, Owner: Player): Crate
	assert(crateCheck(Name, SpawnLocation, Owner))

	local self = setmetatable({}, Crate) :: Crate
	self.Name = Name
	self.Owner = Owner
	self.Destroying = Signal.new()
	self._junk = {}

	if CrateConfig[Name] then
		self.Config = table.clone(CrateConfig[Name]) :: Types.CrateConfig
		self.MaxHealth = self.Config.Health
	else
		Log.Error(`No configuration found for crate: {Name}`)
	end

	local Model = CratesFolder:FindFirstChild(Name) :: Model
	if Model then
		self.Model = Model:Clone()
		if self.Model.PrimaryPart then
			self.Primary = self.Model.PrimaryPart :: Part

			self.Model.Parent = workspace

			for _, d in self.Model:GetDescendants() do
				if d:IsA("BasePart") then
					d.Transparency = 1
				end
			end
		else
			Log.Error(`No primary part found for crate {Model:GetFullName()}`)
		end
	else
		Log.Error(`No crate with name {Name} was found within CratesFolder.`)
	end

	self.StartingScale = self.Model:GetScale()

	self.Model:SetAttribute("Crate", true)

	task.delay(0.1, function()
		self:Init(SpawnLocation)
	end)
	--task.delay(3, function()
	--self:TakeDamage(100)
	--end)

	return self
end

function Crate.Init(self: Crate, SpawnLocation: Vector3)
	local IgnoreParts = { "HitEffect", "Primary", "Smoke" }
	for _, d in self.Model:GetDescendants() do
		if d:IsA("BasePart") then
			if table.find(IgnoreParts, d.Name) then
				continue
			end
			d.Transparency = 0
		end
	end

	task.wait(0.1)
	self:Spawn(SpawnLocation)
	self:SetupAttachment()
end

function Crate.SetupAttachment(self: Crate)
	local Attachment = self.Primary:WaitForChild("Attachment") :: Attachment

	if Attachment then
		local PercentageLabel = Attachment:WaitForChild("BillboardGui")
			:WaitForChild("Main")
			:WaitForChild("ProgressBar")
			:WaitForChild("Amount")
			:WaitForChild("Percentage") :: TextLabel
		PercentageLabel.Text = self.Name

		local ProgressBar = Attachment:WaitForChild("BillboardGui")
			:WaitForChild("Main")
			:WaitForChild("ProgressBar")
			:WaitForChild("Progress") :: Frame

		local _Spring = Spring.new(Vector3.zero)
		_Spring.Damping = 1
		_Spring.Speed = 15

		table.insert(self._junk, (RunService.Heartbeat:Connect(function()
			local EndXValue = 1 * (math.abs(self.Config.Health) / self.MaxHealth)
			if self.Config.Health < 0 or self.Config.Health == 0 then
				_Spring.Speed = 500
				EndXValue = 0
			end
			_Spring.Target = Vector3.new(EndXValue, 0, 0)

			ProgressBar.Size = UDim2.new(_Spring.Position.X, 0, 1, 0)
			_Spring.Speed = 15
		end)))
	end
end

-- outdated method; this was using tweens, i switched to springs;
-- springs actually perform similarly to tweens tbh and theyre cooler
-- so it tohught y not use thos einstead ofo tweens
--[[
function Crate.UpdateAttachment(self: Crate)
	local Attachment = self.Primary:WaitForChild("Attachment") :: Attachment
	if Attachment then
		local ProgressBar = Attachment:WaitForChild("BillboardGui")
			:WaitForChild("Main")
			:WaitForChild("ProgressBar")
			:WaitForChild("Progress")

		local EndXValue = 1 * (self.Config.Health / self.MaxHealth)
		TweenService:Create(ProgressBar, TweenInfo.new(0.2), { Size = UDim2.new(EndXValue, 0, 1, 0) }):Play()
	end
end
]]

function Crate.TakeDamage(self: Crate, Amount: number)
	local HitSound = SoundService:WaitForChild("HitBox"):Clone() :: Sound
	HitSound.Parent = self.Primary
	HitSound:Play()

	HitSound.Ended:Connect(function()
		HitSound:Destroy()
	end)

	self.Config.Health -= Amount

	--self:UpdateAttachment()

	-- Do the hit effect
	do
		local HitEffect = self.Model:FindFirstChild("HitEffect") :: Part
		if HitEffect then
			local Attachment = HitEffect:FindFirstChildOfClass("Attachment")
			if Attachment then
				for _, child in Attachment:GetChildren() do
					if child:IsA("ParticleEmitter") then
						child = child :: ParticleEmitter
						child.Enabled = true

						task.delay(0.25, function()
							child.Enabled = false
						end)
					end
				end
			end
		end
	end

	-- Do the model tween
	do
		local EndScale: number

		local RandomNumber = math.random(1, 2)
		if RandomNumber == 1 then -- scale up
			local UpValues = SCALE_VALUES.Up
			EndScale = UpValues[math.random(1, #UpValues)]
			--EndScale = 1.15
		else -- scale down
			local DownValues = SCALE_VALUES.Down
			EndScale = DownValues[math.random(1, #DownValues)]
			--EndScale = 0.85
		end

		EndScale = self.StartingScale * EndScale

		local Info = { 0.05, Enum.EasingStyle.Sine, Enum.EasingDirection.Out } :: { any }

		Remotes.TweenModelScale:fireAll(self.Model, 1, EndScale, Info)

		task.delay(0.075, function()
			self.Model:ScaleTo(EndScale)

			Remotes.TweenModelScale:fireAll(self.Model, EndScale, self.StartingScale, Info)

			task.delay(0.075, function()
				self.Model:ScaleTo(self.StartingScale)

				-- kill myself if im at 0 health
				if self.Config.Health <= 0 then
					self:CleanupConnections()
					task.wait(0.3)
					Remotes.TweenModelScale:fireAll(self.Model, 1, 0.00001, { 0.4 })
					task.delay(0.5, function()
						self.Model:ScaleTo(0.00001)
						local ChosenRarity: Types.Rarity = GetRarity(self.Config.Chances) :: Types.Rarity
						if ChosenRarity then
							local SubDictionary = LabubuConfig[ChosenRarity]

							if SubDictionary then
								local RandomLabubuName, _ = GetRandomDictionaryIndex(SubDictionary.Labubus)
								if RandomLabubuName then
									local PlayerData = DataUtil:GetData(self.Owner)

									local Luck = 1
									if PlayerData then
										local OwnerLuck = self.Owner:GetAttribute("Luck") or 1
										Luck = (
											1 * UpgradesConfig.Luck[PlayerData.Upgrades.Luck].NewValue
											+ PlayerData.Luck
											+ CurrentLuck.Value
										) * OwnerLuck
										print(Luck)
									end

									local Size = GetRarity(SizeConfig, function(Name: string)
										local Value = SizeConfig[Name]

										if Value.SpawnChance <= 10 then
											return true
										else
											return false
										end
									end, Luck)

									local _Labubu = Labubu.new(RandomLabubuName, self.Owner, nil, nil, Size)
									local BrokenSound = SoundService:WaitForChild("BrokenCrate"):Clone() :: Sound
									BrokenSound.Parent = _Labubu.RootPart
									BrokenSound:Play()

									BrokenSound.Ended:Connect(function()
										BrokenSound:Destroy()
									end)
									task.wait(0.1)
									_Labubu:Spawn()

									PlayerData = DataUtil:GetData(self.Owner)
									if PlayerData then
										PlayerData = table.clone(PlayerData)

										PlayerData.Unboxes += 1

										DataUtil:SetData(self.Owner, PlayerData)
									end

									task.delay(2.25, function()
										self:Destroy()
									end)

									local Base = GetPlayerPlot(self.Owner)
									if Base then
										local Slots = Base:WaitForChild("Components"):WaitForChild("Slots") :: Folder
										local OpenSlot = GetNextOpenSlot(Slots)
										if not OpenSlot then
											PlayerData = DataUtil:GetData(self.Owner)
											if PlayerData then
												PlayerData.Backpack[HttpService:GenerateGUID(false)] = {
													Name = RandomLabubuName,
													Size = Size,
												}

												DataUtil:SetData(self.Owner, PlayerData)
											end

											task.delay(1.7, function()
												_Labubu.Model:Destroy()
											end)

											return Remotes.ShowNotification:fire(
												self.Owner,
												`The {RandomLabubuName} Labubu has been added to your backpack`,
												Color3.fromRGB(0, 255, 0)
											)
										end
									end
								end
							end
						end
					end)
				end
			end)
		end)
	end
end

function Crate.SetupConnections(self: Crate)
	table.insert(
		self._junk,
		self.Primary.Touched:Connect(function(Hit: BasePart)
			if Hit.Parent and Hit:FindFirstAncestorOfClass("Tool") then
				local Tool = Hit:FindFirstAncestorOfClass("Tool") :: Tool
				local Character = Tool.Parent :: Model?
				if Character then
					if Character.Name == self.Owner.Name then
						-- only have it do dmg if its attack lmfao
						if Tool:GetAttribute("Attacking") then
							Tool:SetAttribute("Attacking", nil)

							local Name = tonumber(Tool.Name)
							if Name then
								local ToolInfo: Types.ToolInfo = ToolConfig[Name]
								if ToolInfo then
									self:TakeDamage(ToolInfo.Damage)
								end
							end
						end
					end
				end
			end
		end)
	)
end

function Crate.Spawn(self: Crate, Location: Vector3)
	self.Model.Parent = workspace
	self.Model:PivotTo(CFrame.new(Location + Vector3.new(-3, 6, 4)) * CFrame.Angles(0, math.rad(35), math.rad(15)))

	local EndPosition = CFrame.new(Location + Vector3.new(0, -0.8, 0)) * CFrame.Angles(0, 0, 0)

	local Smoke = self.Model:FindFirstChild("Smoke") :: Part

	Remotes.TweenModelPosition:fireAll(self.Model, EndPosition, { 1, Enum.EasingStyle.Exponential })
	task.delay(1.1, function()
		self.Model:PivotTo(EndPosition)
		if Smoke then
			local Attachment = Smoke:WaitForChild("Attachment") :: Attachment
			for _, child in Attachment:GetChildren() do
				if child:IsA("ParticleEmitter") then
					child = child :: ParticleEmitter

					child.Enabled = true

					task.delay(0.5, function()
						child.Enabled = false
					end)
				end
			end
		end

		--self:SetupConnections()
	end)
end

function Crate.CleanupConnections(self: Crate)
	for _, v in self._junk do
		if v.Connected then
			v:Disconnect()
		end
	end
	table.clear(self._junk)
end

function Crate.Destroy(self: Crate)
	self:CleanupConnections()

	self.Destroying:Fire()
	self.Model:Destroy()
end

return Crate
