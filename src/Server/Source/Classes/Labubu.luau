-- // Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- //  Objects
local LabubuFolder = ReplicatedStorage.Labubus :: Folder
local NameGradients = ReplicatedStorage.Gradients

-- // Packages
local t = require("@Packages/t")

-- // Utils/Modules/shit
local Types = require("@Shared/Types")

local GetLabubuInfo = require("@Utility/GetLabubuInfo")
local GetPlayerPlot = require("@Utility/GetPlayerPlot")
local Log = require("@Utility/Log")

local SizeConfig = require("@Config/Sizes")

local DataUtil = require("@ServerUtility/DataUtil")

local SlotClass = require("@ServerClasses/Slot")

local GetNextOpenSlot = require("@Utility/GetNextOpenSlot")

local Remotes = require("@Shared/Remotes")

-- // Init
local Labubu = {}
Labubu.__index = Labubu

type LabubuData = {
	Name: string,
	Owner: Player,
	Config: Types.LabubuInfo,
	Slot: string,
	Rarity: Types.Rarity,
	RootPart: Part,
	Model: Model,
	OfflineEarnings: number?,
	SizeConfig: Types.SizeConfig?,
	SizeName: string?,
}

export type Labubu = typeof(setmetatable({} :: LabubuData, Labubu))

local labubuCheck = t.tuple(t.string, t.Instance, t.optional(t.string), t.optional(t.number), t.optional(t.number))
function Labubu.new(Name: string, Owner: Player, Slot: string?, OfflineEarings: number?, Size: string?): Labubu
	assert(labubuCheck(Name, Owner, Slot))

	local self = setmetatable({}, Labubu) :: Labubu
	self.Name = Name
	self.Owner = Owner
	self.OfflineEarnings = OfflineEarings

	if Slot then
		self.Slot = Slot
	end

	local Rarity, Info = GetLabubuInfo(Name)
	if Rarity and Info then
		self.Config = Info :: Types.LabubuInfo
		self.Rarity = Rarity :: Types.Rarity
	else
		Log.Error(`No configuration found for labubu: {Name}`)
	end

	local LabubuModel = LabubuFolder:FindFirstChild(Name) :: Model
	if LabubuModel then
		self.Model = LabubuModel:Clone()
		self.Model.Parent = workspace
		local HumanoidRootPart = self.Model:FindFirstChild("HumanoidRootPart") :: Part
		if HumanoidRootPart then
			self.RootPart = HumanoidRootPart
		else
			if typeof(self.Model.PrimaryPart) == "Part" then
				self.RootPart = self.Model.PrimaryPart
			end
		end
	else
		Log.Error(`No model found for labubu: {Name}`)
	end

	if Size then
		local Config = SizeConfig[Size]
		self.SizeConfig = Config
		self.SizeName = Size
		self.Model:ScaleTo(Config.Scale)
	end

	for _, d in self.Model:GetDescendants() do
		if d:IsA("BasePart") then
			d.CanCollide = false
		end
	end

	self:SetupDisplayInfo()

	Owner:GetPropertyChangedSignal("Parent"):Connect(function()
		self.Model:Destroy()
	end)
	Owner.Destroying:Connect(function()
		self.Model:Destroy()
	end)

	return self :: Labubu
end

function Labubu.SetupDisplayInfo(self: Labubu)
	local Attachment = self.RootPart:FindFirstChild("Attachment") :: Attachment
	if not Attachment then
		return
	end

	local Billboard = Attachment:WaitForChild("Billboard")
	local Main = Billboard:WaitForChild("Main")

	local NameText = Main:WaitForChild("Name") :: TextLabel
	local RarityText = Main:WaitForChild("Rarity") :: TextLabel

	NameText.Text = self.Name
	RarityText.Text = self.Rarity

	local OldGradient = RarityText:FindFirstChildOfClass("UIGradient")
	if OldGradient then
		OldGradient:Destroy()
	end

	local NewGradient = NameGradients:FindFirstChild(self.Rarity)
	if NewGradient then
		local NewClone = NewGradient:Clone()
		NewClone.Parent = RarityText
	end
end

function Labubu.Spawn(self: Labubu)
	local Plot = GetPlayerPlot(self.Owner) :: Model
	if not Plot then
		return
	end

	local Components = Plot:FindFirstChild("Components") :: Folder
	if not Components then
		return
	end

	local CrateSpawn = Components:FindFirstChild("CrateSpawn") :: Part
	if not CrateSpawn then
		return
	end

	local ExtraOffset = CFrame.new(0, 0, 0)
	if self.SizeConfig then
		ExtraOffset = self.SizeConfig.Offset
	end

	self.Model:PivotTo(CrateSpawn.CFrame * CFrame.new(0, -5, 0) * CFrame.Angles(0, math.rad(180), 0))

	Remotes.TweenModelPosition:fireAll(self.Model, CrateSpawn.CFrame * CFrame.new(0, 2, 0) * ExtraOffset, { 0.75 })

	task.delay(1, function()
		self.Model:PivotTo(CrateSpawn.CFrame * CFrame.new(0, 2, 0) * ExtraOffset)
		local Slots = Components:WaitForChild("Slots") :: Folder
		local OpenSlotName = GetNextOpenSlot(Slots)

		if OpenSlotName then
			local OpenSlot = Slots:WaitForChild(OpenSlotName)
			local Stand = OpenSlot:WaitForChild("Stand") :: Part
			self.Slot = OpenSlotName
			task.wait(1)

			local OpenSlotCFrame = Stand.CFrame * CFrame.new(0, 5, 0) * CFrame.Angles(0, math.rad(-90), 0) * ExtraOffset
			Remotes.TweenModelPosition:fireAll(self.Model, OpenSlotCFrame, { 1.5 })
			task.delay(1.6, function()
				self.Model:PivotTo(OpenSlotCFrame)

				self:AddToSlot()
			end)
		end
	end)
end

function Labubu.AddToSlot(self: Labubu)
	local Plot = GetPlayerPlot(self.Owner) :: Model
	if not Plot then
		return
	end

	local Components = Plot:FindFirstChild("Components") :: Folder
	if not Components then
		return
	end

	local ExtraOffset = CFrame.new(0, 0, 0)
	if self.SizeConfig then
		ExtraOffset = self.SizeConfig.Offset
	end

	local Slots = Components:WaitForChild("Slots") :: Folder

	local SlotInstance = Slots:FindFirstChild(self.Slot) :: Folder
	local Stand = SlotInstance:WaitForChild("Stand") :: Part
	if SlotInstance then
		self.Model:PivotTo(Stand.CFrame * CFrame.new(0, 5, 0) * CFrame.Angles(0, math.rad(-90), 0) * ExtraOffset)
		SlotInstance:SetAttribute("Labubu", self.Name)
		SlotInstance:SetAttribute("Size", self.SizeName)

		SlotClass.new(self.Model, self.Owner, self.Config, self.Slot, self.OfflineEarnings, self.SizeConfig)
	end

	local PlayerData = DataUtil:GetData(self.Owner)
	if PlayerData then
		PlayerData = table.clone(PlayerData)

		if PlayerData.Index then
			if not table.find(PlayerData.Index, self.Name) then
				table.insert(PlayerData.Index, self.Name)
			end
		end

		DataUtil:SetData(self.Owner, PlayerData)
	end

	self:SetupPickupConnection()
end

function Labubu.SetupPickupConnection(self: Labubu)
	local Prompt = Instance.new("ProximityPrompt")
	Prompt.Parent = self.RootPart
	Prompt.ActionText = "Pick Up"
	Prompt.RequiresLineOfSight = false
	Prompt.HoldDuration = 1.5

	Prompt.Triggered:Connect(function(Player: Player)
		if Player == self.Owner then
			local PlayerData = DataUtil:GetData(self.Owner)
			if PlayerData then
				PlayerData = table.clone(PlayerData)

				if PlayerData.Backpack then
					table.insert(PlayerData.Backpack, self.Name)
				end

				DataUtil:SetData(self.Owner, PlayerData)
			end

			local Plot = GetPlayerPlot(self.Owner) :: Model
			if not Plot then
				return
			end

			local Components = Plot:FindFirstChild("Components") :: Folder
			if not Components then
				return
			end

			local Slots = Components:WaitForChild("Slots") :: Folder

			local SlotInstance = Slots:FindFirstChild(self.Slot) :: Folder

			if SlotInstance then
				SlotInstance:SetAttribute("Labubu", nil)
				SlotInstance:SetAttribute("Size", nil)
			end
			self.Model:Destroy()
		end
	end)
end

return Labubu
