-- // Objects
local Plots = workspace.Plots :: Folder

-- // Modules
local Types = require("@Shared/Types")

local Crate = require("@ServerClasses/Crate")

local DataUtil = require("@ServerUtility/DataUtil")

local Cache = require("@ServerUtility/Cache")

local GetRarity = require("@Utility/GetRarity")

local CrateConfig = require("@Config/Crates")

type PlotUtil = {
	Plots: { [string]: Types.PlotData },

	Setup: (self: PlotUtil) -> (),
	GetEmptyPlot: (self: PlotUtil) -> string?,
	GetPlayerPlot: (self: PlotUtil, Player: Player) -> string?,
	AssignPlot: (self: PlotUtil, Player: Player) -> (),
	ResetPlot: (self: PlotUtil, Plot: string) -> (),
	TeleportPlayerToPlot: (self: PlotUtil, Player: Player, Plot: string?) -> (),
	SetupSpawner: (self: PlotUtil, Plot: string) -> (),
	SetupSkipPrompt: (self: PlotUtil, Plot: string) -> (),
}
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

type PlotModel = Model & {
	Components: Folder & {
		Teleport: Part,
		CrateSpawn: Part,
		Slots: Folder & { SlotModel },
		ExtraSlots: Folder,
		Skip: Model & {
			Main: Part & {
				ProximityPrompt: ProximityPrompt,
			},
		},
	},
}

-- // Module
local PlotUtil = {
	Plots = {} :: { [string]: Types.PlotData },
} :: PlotUtil

function PlotUtil.Setup(self: PlotUtil)
	for _, PlotModel in Plots:GetChildren() do
		self.Plots[PlotModel.Name] = {
			Owner = nil,
		}
		self:ResetPlot(PlotModel.Name)
		self:SetupSkipPrompt(PlotModel.Name)
	end
end

function PlotUtil.SetupSkipPrompt(self: PlotUtil, Plot: string)
	local PlotModel = Plots:FindFirstChild(Plot) :: PlotModel

	PlotModel.Components.Skip.Main.ProximityPrompt.Triggered:Connect(function(Player: Player)
		if self.Plots[Plot].CurrentCrate then
			if self.Plots[Plot].Owner == Player then
				local _Crate = self.Plots[Plot].CurrentCrate :: Crate.Crate
				_Crate:Destroy()
			end
		end
	end)
end

function PlotUtil.GetEmptyPlot(self: PlotUtil): string?
	for Name, PlotData: Types.PlotData in self.Plots do
		if PlotData.Owner == nil then
			return Name
		end
	end
	return nil
end

function PlotUtil.GetPlayerPlot(self: PlotUtil, Player: Player): string?
	for Name, PlotData: Types.PlotData in self.Plots do
		if PlotData.Owner == Player then
			return Name
		end
	end
	return nil
end

function PlotUtil.TeleportPlayerToPlot(self: PlotUtil, Player: Player, Plot: string?)
	local PlayerPlot = Plot or self:GetPlayerPlot(Player)
	if PlayerPlot then
		local PlotModel = Plots:FindFirstChild(PlayerPlot) :: PlotModel

		if PlotModel then
			local Components = PlotModel.Components

			local Character = Player.Character or Player.CharacterAdded:Wait()
			Character:PivotTo(Components.Teleport:GetPivot())
		end
	end
end

function PlotUtil.SetupSpawner(self: PlotUtil, Plot: string)
	local PlotModel = Plots:FindFirstChild(Plot) :: PlotModel
	if PlotModel then
		local Owner = self.Plots[Plot].Owner
		if Owner then
			self.Plots[Plot].Spawner = task.spawn(function()
				while true do
					local RandomCrate = GetRarity(CrateConfig)

					local ChosenCrate = RandomCrate or "Crate"

					if Cache.PlayerCrates[Owner] and #Cache.PlayerCrates[Owner] > 0 then
						ChosenCrate = Cache.PlayerCrates[Owner][1]
						table.remove(Cache.PlayerCrates[Owner], 1)
					end

					local _Crate = Crate.new(ChosenCrate, PlotModel.Components.CrateSpawn.Position, Owner)
					self.Plots[Plot].CurrentCrate = _Crate :: Crate.Crate

					_Crate.Destroying:Wait()
				end
			end)
		end
	end
end

function PlotUtil.AssignPlot(self: PlotUtil, Player: Player)
	local PlotName = self:GetEmptyPlot()
	if PlotName then
		self.Plots[PlotName].Owner = Player

		local PlotModel = Plots:FindFirstChild(PlotName) :: PlotModel
		if PlotModel then
			PlotModel:SetAttribute("Owner", Player.Name)
		end

		local PlayerData = DataUtil:GetData(Player)
		if PlayerData then
			local ExtraSlots = PlayerData.ExtraSlots

			if ExtraSlots then
				local ExtraSlotsFolder = PlotModel.Components.ExtraSlots

				for _, Slot in ExtraSlots do
					local ExtraSlotModel = ExtraSlotsFolder:FindFirstChild("Slot" .. Slot) :: SlotModel
					if ExtraSlotModel then
						ExtraSlotModel.Parent = PlotModel.Components.Slots
					end
				end
			end
		end

		self:TeleportPlayerToPlot(Player)
		self:SetupSpawner(PlotName)
	end
end

function PlotUtil.ResetPlot(self: PlotUtil, Plot: string)
	local PlotData: Types.PlotData = self.Plots[Plot]
	local PlotModel = Plots:FindFirstChild(Plot) :: PlotModel

	if PlotData then
		if PlotModel then
			for _, Slot in PlotModel.Components.Slots:GetChildren() do
				local SlotModel = Slot :: SlotModel
				SlotModel.Collect.Attachment.Billboard.Frame.amount.Text = "$0"
				SlotModel.Collect.Attachment.Billboard.Frame.income.Text = "$0/s"

				SlotModel.Collect.OfflineAttachment.Billboard.Enabled = false
			end

			local ExtraSlots
			if PlotModel.Components:FindFirstChild("ExtraSlots") then
				ExtraSlots = PlotModel.Components:FindFirstChild("ExtraSlots") :: Folder
			else
				ExtraSlots = Instance.new("Folder")
				ExtraSlots.Parent = PlotModel.Components
				ExtraSlots.Name = "ExtraSlots"
			end

			local Slot11 = PlotModel.Components.Slots:FindFirstChild("Slot11")
			if Slot11 then
				Slot11.Parent = ExtraSlots
			end

			local Slot12 = PlotModel.Components.Slots:FindFirstChild("Slot12")
			if Slot12 then
				Slot12.Parent = ExtraSlots
			end

			if PlotData.Owner then
				PlotModel:SetAttribute("Owner", nil)
			end
		end

		PlotData.Owner = nil
	end

	if self.Plots[Plot].Spawner then
		task.cancel(self.Plots[Plot].Spawner :: thread)
		self.Plots[Plot].Spawner = nil

		if self.Plots[Plot].CurrentCrate then
			local CurrentCrate = self.Plots[Plot].CurrentCrate :: Crate.Crate
			CurrentCrate:Destroy()

			self.Plots[Plot].CurrentCrate = nil
		end
	end
end

return PlotUtil
