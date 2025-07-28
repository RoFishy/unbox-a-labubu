-- // Services
local Players = game:GetService("Players")
local SoundService = game:GetService("SoundService")

-- // packages
local t = require("@Packages/t")

local Types = require("@Shared/Types")

local GetPlayerPlot = require("@Utility/GetPlayerPlot")

-- // Functions
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

-- // Types
type SlotModel = Folder & {
	Stand: Part,
	Collect: Part & {
		Attachment: Attachment & {
			Billboard: BillboardGui & {
				Frame: Frame & {
					amount: TextLabel,
					income: TextLabel,
				},
			},
		},
		OfflineAttachment: Attachment & {
			Billboard: BillboardGui & {
				Frame: Frame & {
					offline: TextLabel,
				},
			},
		},
	},
}

-- // Init
local Slot = {}
Slot.__index = Slot

type SlotData = {
	LabubuModel: Model,
	Owner: Player,
	SlotModel: SlotModel,
	Config: Types.LabubuInfo,

	CurrentEarned: number,

	Connections: { RBXScriptConnection },
	Threads: { thread },
}

export type Slot = typeof(setmetatable({} :: SlotData, Slot))

function Slot.new(LabubuModel: Model, Player: Player, Config: Types.LabubuInfo, SlotName: string?): Slot?
	assert(t.tuple(t.Instance, t.Instance, t.optional(t.string)))

	local self = setmetatable({}, Slot) :: Slot

	self.LabubuModel = LabubuModel
	self.Owner = Player
	self.Config = Config

	self.CurrentEarned = 0

	self.Threads = {}
	self.Connections = {}

	local Plot = GetPlayerPlot(self.Owner) :: Model
	if not Plot then
		return
	end

	local Components = Plot:FindFirstChild("Components") :: Folder
	if not Components then
		return
	end

	local Slots = Components:WaitForChild("Slots") :: Folder

	LabubuModel:GetPropertyChangedSignal("Parent"):Connect(function()
		self:Destroy()
	end)

	LabubuModel.Destroying:Connect(function()
		self:Destroy()
	end)

	if SlotName then
		self.SlotModel = Slots:FindFirstChild(SlotName) :: SlotModel
	else
		local OpenSlotName = GetNextOpenSlot(Slots)
		if OpenSlotName then
			local OpenSlot = Slots:WaitForChild(OpenSlotName) :: SlotModel
			self.SlotModel = OpenSlot
		end
	end

	local Stand = self.SlotModel:WaitForChild("Stand") :: Part
	self.LabubuModel:PivotTo(Stand.CFrame * CFrame.new(0, 5, 0) * CFrame.Angles(0, math.rad(-90), 0))

	self:Setup()

	return self
end

function Slot.Setup(self: Slot)
	self.SlotModel.Collect.Attachment.Billboard.Frame.income.Text = `${self.Config.Income}/s`

	table.insert(
		self.Threads,
		task.spawn(function()
			while task.wait(1) do
				self.CurrentEarned += self.Config.Income

				self.SlotModel.Collect.Attachment.Billboard.Frame.amount.Text = `${self.CurrentEarned}`
			end
		end)
	)

	table.insert(
		self.Connections,
		self.SlotModel.Collect.Touched:Connect(function(hit)
			local Player = Players:GetPlayerFromCharacter(hit.Parent)
			if Player then
				if Player == self.Owner then
					local CashSound = SoundService:FindFirstChild("CashCollect") :: Sound
					if CashSound then
						CashSound = CashSound:Clone()
						CashSound.Parent = self.LabubuModel.PrimaryPart
						CashSound:Play()

						CashSound.Ended:Connect(function()
							CashSound:Destroy()
						end)
					end

					local DataUtil = require("@ServerUtility/DataUtil")

					local PlayerData = DataUtil:GetData(Player)
					if PlayerData then
						PlayerData = table.clone(PlayerData)
						PlayerData.Cash += self.CurrentEarned
						DataUtil:SetData(Player, PlayerData)
					end

					self.CurrentEarned = 0

					self.SlotModel.Collect.Attachment.Billboard.Frame.amount.Text = `${self.CurrentEarned}`
				end
			end
		end)
	)
end

function Slot.Destroy(self: Slot)
	for _, Connection in self.Connections do
		if Connection.Connected then
			Connection:Disconnect()
		end
	end
	table.clear(self.Connections)

	for _, Thread in self.Threads do
		if Thread then
			task.cancel(Thread)
		end
	end
	table.clear(self.Threads)

	self.CurrentEarned = 0
	self.SlotModel.Collect.Attachment.Billboard.Frame.amount.Text = `$0`
	self.SlotModel.Collect.Attachment.Billboard.Frame.income.Text = `$0/s`
end

return Slot
