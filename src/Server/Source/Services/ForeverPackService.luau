-- // services
local MarketplaceService = game:GetService("MarketplaceService")

-- // modules
local ForeverPack = require("@Config/ForeverPack")

local DataUtil = require("@ServerUtility/DataUtil")

local Remotes = require("@Shared/Remotes")

-- // const
local PACK_RESET_TIME = 21600

-- // init
local ForeverPackService = {}

function ForeverPackService:Start()
	Remotes.ClaimForeverPack:onRequest(function(Player: Player): any
		local Data = DataUtil:GetData(Player)
		if Data then
			local NextIndex = ForeverPack.GetNextIndex(Data.ForeverPack)

			local Cost = ForeverPack.GetPriceFromIndex(NextIndex)

			if not tonumber(Cost) then
				self:ClaimNextForeverPackReward(Player)

				return Data.ForeverPack
			else
				MarketplaceService:PromptProductPurchase(Player, Cost)
			end
		end

		return
	end)
end

function ForeverPackService:SetupPlayer(Player: Player)
	local Data = DataUtil:GetData(Player)
	if Data then
		if workspace:GetServerTimeNow() - Data.LastForeverPackReset >= PACK_RESET_TIME then
			self:RefreshForeverPack(Player)
		end

		task.spawn(function()
			while Player and Player.Parent do
				if workspace:GetServerTimeNow() - Data.LastForeverPackReset >= PACK_RESET_TIME then
					self:RefreshForeverPack(Player)
				end

				task.wait(1)
			end
		end)
	end
end

function ForeverPackService:RefreshForeverPack(Player: Player)
	local Data = DataUtil:GetData(Player)
	if Data then
		Data = table.clone(Data)
		Data.LastForeverPackReset = workspace:GetServerTimeNow()
		Data.ForeverPack = {}

		for i = 1, 5 do
			local ChosenRewardIndex = ForeverPack.PickRandomRewardIndex()

			Data.ForeverPack[tostring(i)] = {
				RewardIndex = ChosenRewardIndex,
			}
		end

		DataUtil:SetData(Player, Data)
	end
end

function ForeverPackService:ClaimNextForeverPackReward(Player: Player)
	local Data = DataUtil:GetData(Player)
	if Data then
		local NextTableIndex = ForeverPack.GetNextIndex(Data.ForeverPack)
		--print("Server: ", Profile.Data.ForeverPack, NextTableIndex)
		local RewardIndex = Data.ForeverPack[tostring(NextTableIndex)].RewardIndex

		task.spawn(function()
			ForeverPack.Rewards[RewardIndex].ClaimFunction(Player)
		end)

		Data.ForeverPack[tostring(NextTableIndex)] = nil

		local ChosenRewardIndex = ForeverPack.PickRandomRewardIndex()

		Data.ForeverPack[tostring(NextTableIndex + 5)] = {
			RewardIndex = ChosenRewardIndex,
		}

		DataUtil:SetData(Player, Data)

		Remotes.ShowNotification:fire(Player, "Reward Claimed!", Color3.fromRGB(38, 255, 45), "CashCollect")
	end
end

return ForeverPackService
