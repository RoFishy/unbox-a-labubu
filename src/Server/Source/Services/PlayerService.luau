-- // Services
local Players = game:GetService("Players")

-- // Utils
local DataUtil = require("@ServerUtility/DataUtil")
local PlotUtil = require("@ServerUtility/PlotUtil")

local HammerTool = require("@ServerClasses/HammerTool")
local Labubu = require("@ServerClasses/Labubu")

local CrateShopService = require("@Services/CrateShopService")
local ForeverPackService = require("@Services/ForeverPackService")
local PurchaseService = require("@Services/PurchaseService")

local Replica = require("@Packages/Replica") :: any

-- // Init
local PlayerService = {
	SetupCharacters = {},
}

function PlayerService:Start()
	Players.PlayerAdded:Connect(function(Player: Player)
		task.spawn(function()
			DataUtil.New(Player)
			PlotUtil:AssignPlot(Player)
			PurchaseService:SetupPlayerGamepasses(Player)
			ForeverPackService:SetupPlayer(Player)
		end)

		task.delay(1, function()
			local Data = DataUtil:GetData(Player)
			if Data then
				local Labubus = Data.Labubus
				if Labubus then
					for _, LabubuData in Labubus do
						local OfflineEarnings = DataUtil:CalculateOfflineEarnings(Player, LabubuData.Name)

						local _Labubu =
							Labubu.new(LabubuData.Name, Player, LabubuData.Slot, OfflineEarnings, LabubuData.Size)
						_Labubu:AddToSlot()
					end
				end
			else
				repeat
					task.wait()
					Data = DataUtil:GetData(Player)
				until Data or not Player.Parent

				if Data then
					local Labubus = Data.Labubus
					if Labubus then
						for _, LabubuData in Labubus do
							local OfflineEarnings = DataUtil:CalculateOfflineEarnings(Player, LabubuData.Name)

							local _Labubu =
								Labubu.new(LabubuData.Name, Player, LabubuData.Slot, OfflineEarnings, LabubuData.Size)
							_Labubu:AddToSlot()
						end
					end
				end
			end
		end)

		if Player.Character then
			self:_CharacterAdded(Player, Player.Character)
		end
		task.delay(2, function()
			Player.CharacterAdded:Connect(function(Character: Model)
				self:_CharacterAdded(Player, Character)
			end)
		end)

		task.delay(5, function()
			if Player.Character then
				if table.find(self.SetupCharacters, Player.Name) then
					return
				end
				self:_CharacterAdded(Player, Player.Character)
			end
		end)

		task.delay(7, function()
			if Player.Character then
				if
					not Player.Character:FindFirstChildOfClass("Tool")
					and not Player.Backpack:FindFirstChildOfClass("Tool")
				then
					self:_CharacterAdded(Player, Player.Character)
				end
			end
		end)
	end)

	Replica.NewReadyPlayer:Connect(function(Player: Player)
		CrateShopService:SetPlayerInfo(Player)
		DataUtil:SetupReplica(Player)
	end)

	Players.PlayerRemoving:Connect(function(Player: Player)
		DataUtil:CleanupProfile(Player)

		task.delay(1, function()
			local Plot = PlotUtil:GetPlayerPlot(Player)
			if Plot then
				PlotUtil:ResetPlot(Plot)
			end
		end)
	end)
end

function PlayerService:_CharacterAdded(Player: Player, _: Model)
	table.insert(self.SetupCharacters, Player.Name)

	PlotUtil:TeleportPlayerToPlot(Player)

	HammerTool.new(Player)
end

return PlayerService
