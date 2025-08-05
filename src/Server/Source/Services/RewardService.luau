-- // modules
local Remotes = require("@Shared/Remotes")

local DataUtil = require("@ServerUtility/DataUtil")

local GetNextOpenSlot = require("@Utility/GetNextOpenSlot")
local GetPlayerPlot = require("@Utility/GetPlayerPlot")

local Labubu = require("@ServerClasses/Labubu")

-- // init
local RewardService = {}

function RewardService:Start()
	Remotes.ClaimFreeReward:connect(function(Player: Player)
		local PlayerData = DataUtil:GetData(Player)
		if PlayerData then
			PlayerData = table.clone(PlayerData)
			if PlayerData.ClaimedFreeReward == true then
				return Remotes.ShowNotification:fire(
					Player,
					"You have already claimed your free reward!",
					Color3.fromRGB(255, 0, 0),
					"Error"
				)
			else
				local Base = GetPlayerPlot(Player)
				if Base then
					local Slots = Base:WaitForChild("Components"):WaitForChild("Slots") :: Folder
					local OpenSlot = GetNextOpenSlot(Slots)
					if not OpenSlot then
						return Remotes.ShowNotification:fire(
							Player,
							"You have no open slots!",
							Color3.fromRGB(255, 0, 0),
							"Error"
						)
					else
						local _Labubu = Labubu.new("Ninja", Player, OpenSlot)
						_Labubu:AddToSlot()
						Remotes.ShowNotification:fire(
							Player,
							"You have claimed your free reward!",
							Color3.fromRGB(0, 255, 0),
							"CashCollect"
						)

						PlayerData.ClaimedFreeReward = true
						DataUtil:SetData(Player, PlayerData)
					end
				end
			end
		end
	end)
end

return RewardService
