-- // Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SoundService = game:GetService("SoundService")

-- // Obj
local CratesFolder: Folder = ReplicatedStorage.Crates
local PlotsFolder = workspace.Plots

-- // packages
local Signal = require("@Packages/Signal")
local t = require("@Packages/t")

-- // Utils
local Log = require("@Utility/Log")
local TweenModel = require("@Utility/TweenModel")

local GetRandomDictionaryIndex = require("@Utility/GetRandomDictionaryIndex")
local GetRarity = require("@Utility/GetRarity")

local Types = require("@Shared/Types")

local CrateConfig = require("@Config/Crates")
local LabubuConfig = require("@Config/Labubus")
local ToolConfig = require("@Config/Tools")

local Labubu = require("@ServerClasses/Labubu")

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

-- // local functions
local function GetPlayerPlot(Player: Player): Instance?
	for _, Plot in PlotsFolder:GetChildren() do
		if Plot:GetAttribute("Owner") and Plot:GetAttribute("Owner") == Player.Name then
			return Plot
		end
	end

	return
end

local function GetNextOpenSlot(Slots: Folder): string?
	for i = 1, #Slots:GetChildren() do
		local CurrentSlot = Slots:FindFirstChild("Slot" .. i)
		if CurrentSlot then
			if CurrentSlot:GetAttribute("Labubu") == nil then
				return CurrentSlot.Name
			end
		end
	end

	return
end

-- // Init
local Crate = {}
Crate.__index = Crate

type CrateData = {
	Name: string,
	Owner: Player,
	Config: Types.CrateConfig,
	Model: Model,
	Primary: Part,
	Destroying: typeof(Signal.new()),

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
	else
		Log.Error(`No configuration found for crate: {Name}`)
	end

	local Model = CratesFolder:FindFirstChild(Name) :: Model
	if Model then
		self.Model = Model:Clone()
		if self.Model.PrimaryPart then
			self.Primary = self.Model.PrimaryPart :: Part
		else
			Log.Error(`No primary part found for crate {Model:GetFullName()}`)
		end
	else
		Log.Error(`No crate with name {Name} was found within CratesFolder.`)
	end

	self:Init(SpawnLocation)
	--task.delay(3, function()
	--self:TakeDamage(100)
	--end)

	return self
end

function Crate.Init(self: Crate, SpawnLocation: Vector3)
	self:Spawn(SpawnLocation)
	self:SetupConnections()
end

function Crate.TakeDamage(self: Crate, Amount: number)
	local HitSound = SoundService:WaitForChild("HitBox"):Clone() :: Sound
	HitSound.Parent = self.Primary
	HitSound:Play()

	HitSound.Ended:Connect(function()
		HitSound:Destroy()
	end)

	self.Config.Health -= Amount

	-- Do the hit effect
	do
		local HitEffect = self.Model:FindFirstChild("HitEffect") :: Part
		if HitEffect then
			local Attachment = HitEffect:WaitForChild("Attachment")
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

		local Info = TweenInfo.new(0.05, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)

		TweenModel.Scale(self.Model, 1, EndScale, Info, function()
			TweenModel.Scale(self.Model, EndScale, 1, Info, function()
				-- kill myself if im at 0 health
				if self.Config.Health <= 0 then
					self:CleanupConnections()
					TweenModel.Scale(self.Model, 1, 0.00001, TweenInfo.new(0.75), function()
						local ChosenRarity: Types.Rarity = GetRarity(self.Config.Chances) :: Types.Rarity
						if ChosenRarity then
							local SubDictionary = LabubuConfig[ChosenRarity]

							if SubDictionary then
								local RandomLabubuName, _ = GetRandomDictionaryIndex(SubDictionary.Labubus)
								if RandomLabubuName then
									local _Labubu = Labubu.new(RandomLabubuName, self.Owner)
									local BrokenSound = SoundService:WaitForChild("BrokenCrate"):Clone() :: Sound
									BrokenSound.Parent = _Labubu.RootPart
									BrokenSound:Play()

									BrokenSound.Ended:Connect(function()
										BrokenSound:Destroy()
									end)
									_Labubu:Spawn()

									task.delay(2.5, function()
										self:Destroy()
									end)
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
						local Player = Players:GetPlayerFromCharacter(Character)
						if Player then
							local Base = GetPlayerPlot(Player)
							if Base then
								local Slots = Base:WaitForChild("Components"):WaitForChild("Slots") :: Folder
								local OpenSlot = GetNextOpenSlot(Slots)
								if not OpenSlot then
									return
								end
							end
						end

						-- only have it do dmg if its attack lmfao
						if Tool:GetAttribute("Attacking") then
							Tool:SetAttribute("Attacking", nil)
							-- get the configuration for the tools

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

	TweenModel.Position(self.Model, EndPosition, TweenInfo.new(1, Enum.EasingStyle.Exponential), function()
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
	end)

	--[[
	task.delay(1, function()
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

		self.Primary.Anchored = true
	end)
	]]
	--
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
