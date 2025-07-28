-- // Services
local Players = game:GetService("Players")

-- // Utils
local DataUtil = require("@ServerUtility/DataUtil")
local PlotUtil = require("@ServerUtility/PlotUtil")

local HammerTool = require("@ServerClasses/HammerTool")
local Labubu = require("@ServerClasses/Labubu")

local Replica = require("@Packages/Replica") :: any

-- // Init
local PlayerService = {
	SetupCharacters = {},
}

function PlayerService:Start()
	Players.PlayerAdded:Connect(function(Player: Player)
		task.spawn(DataUtil.New, Player)
		PlotUtil:AssignPlot(Player)

		task.delay(1, function()
			local Data = DataUtil:GetData(Player)
			if Data then
				local Labubus = Data.Labubus
				if Labubus then
					for _, LabubuData in Labubus do
						local _Labubu = Labubu.new(LabubuData.Name, Player, LabubuData.Slot)
						_Labubu:AddToSlot()
					end
				end
			end
		end)

		if Player.Character then
			self:_CharacterAdded(Player, Player.Character)
		end
		Player.CharacterAdded:Connect(function(Character: Model)
			self:_CharacterAdded(Player, Character)
		end)

		task.delay(5, function()
			if Player.Character then
				self:_CharacterAdded(Player, Player.Character)
			end
		end)
	end)

	Replica.NewReadyPlayer:Connect(function(Player: Player)
		DataUtil:SetupReplica(Player)
	end)

	Players.PlayerRemoving:Connect(function(Player: Player)
		DataUtil:CleanupProfile(Player)

		local Plot = PlotUtil:GetPlayerPlot(Player)
		if Plot then
			PlotUtil:ResetPlot(Plot)
		end
	end)
end

function PlayerService:_CharacterAdded(Player: Player, Character: Model)
	if table.find(self.SetupCharacters, Player.Name) then
		return
	end

	table.insert(self.SetupCharacters, Player.Name)

	PlotUtil:TeleportPlayerToPlot(Player)

	HammerTool.new(Player)

	local Humanoid = Character:WaitForChild("Humanoid") :: Humanoid

	Humanoid.Died:Connect(function()
		table.remove(self.SetupCharacters, table.find(self.SetupCharacters, Player.Name))
		self:_CharacterAdded(Player, Character)
	end)
end

return PlayerService
