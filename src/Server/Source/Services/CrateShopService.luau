-- // Services
local Players = game:GetService("Players")

-- // Packages
local Replica = require("@Packages/Replica") :: any

-- // replica
local PlayerReplicaToken = Replica.Token("PlayerStock")
local GlobalReplicaToken = Replica.Token("Stock")

local GlobalReplica = Replica.New({ Token = GlobalReplicaToken, Data = { RestockTime = 0 } })

-- // utils
local Hash = require("@Utility/Hash")
local TimeUtils = require("@Utility/Time")

local Cache = require("@ServerUtility/Cache")
local DataUtil = require("@ServerUtility/DataUtil")

local Remotes = require("@Shared/Remotes")

local CrateConfig = require("@Config/Crates")

-- // Const
local RESTOCK_INTERVAL = 5 * 60 -- 5 minutes
local KEY = "craterestockkeyyeahhh"

-- // Var
local PlayerReplicas = {}
local PlayerStockData = {}
local CurrentStockData = {}

-- // Init
local CrateShopService = {}

function CrateShopService:Init()
	GlobalReplica:Replicate()
end

function CrateShopService:Start()
	local now = workspace:GetServerTimeNow()
	local TickTime = if TimeUtils.IsOnInterval(now, RESTOCK_INTERVAL)
		then now
		else TimeUtils.GetNextIntervalTime(now, RESTOCK_INTERVAL)

	self:Restock(TickTime)

	task.spawn(function()
		while true do
			now = workspace:GetServerTimeNow()

			local NextTime = TimeUtils.GetNextIntervalTime(now, RESTOCK_INTERVAL)
			NextTime = math.ceil(NextTime)

			for i = NextTime - now, 0, -1 do
				task.wait(1)
				GlobalReplica:Set({ "RestockTime" }, i)
			end
			self:Restock(NextTime)
		end
	end)

	Remotes.PurchaseCrate:connect(function(Player: Player, CrateName: string)
		local PlayerStock = PlayerStockData[Player]
		if not PlayerStock then
			return
		end

		local PlayerData = DataUtil:GetData(Player)
		if PlayerData then
			if PlayerStock[CrateName] and PlayerStock[CrateName] > 0 then
				PlayerData = table.clone(PlayerData)

				if PlayerData.Cash >= CrateConfig[CrateName].Price then
					PlayerData.Cash -= CrateConfig[CrateName].Price
					PlayerStock[CrateName] -= 1

					DataUtil:SetData(Player, PlayerData)

					if Cache.PlayerCrates[Player] then
						table.insert(Cache.PlayerCrates[Player], CrateName)
					else
						Cache.PlayerCrates[Player] = { CrateName }
					end

					local _Replica = PlayerReplicas[Player]
					if _Replica then
						_Replica:Set({ "CrateStock" }, PlayerStock)
					end

					Remotes.ShowNotification:fire(
						Player,
						`You have purchased the {CrateName} crate!`,
						Color3.fromRGB(0, 255, 0),
						"CashCollect"
					)
				else
					Remotes.ShowNotification:fire(
						Player,
						"You do not have enough cash to purchase this crate!",
						Color3.fromRGB(255, 0, 0),
						"Error"
					)
				end
			else
				Remotes.ShowNotification:fire(Player, "This crate is out of stock!", Color3.fromRGB(255, 0, 0), "Error")
			end
		end
	end)
end

function CrateShopService:SetPlayerInfo(Player: Player)
	if PlayerReplicas[Player] then
		local _Replica = PlayerReplicas[Player]
		_Replica:Set({ "CrateStock" }, CurrentStockData)
		PlayerStockData[Player] = CurrentStockData
	else
		local _PlayerReplica = Replica.New({
			Token = PlayerReplicaToken,
			Data = {
				CrateStock = {},
			},
		})
		_PlayerReplica:Subscribe(Player)
		_PlayerReplica:Set({ "CrateStock" }, CurrentStockData)

		PlayerReplicas[Player] = _PlayerReplica
		PlayerStockData[Player] = CurrentStockData

		Player:GetPropertyChangedSignal("Parent"):Connect(function()
			PlayerReplicas[Player] = nil
			PlayerStockData[Player] = nil
		end)
	end
end

function CrateShopService:Restock(time: number)
	local rng = Random.new(Hash(`{KEY}/{time}`))

	-- now actually do shit with this rng
	for CrateName, Config in CrateConfig do
		local RandomNumber = rng:NextInteger(0, 100)

		if RandomNumber <= Config.RestockChance then
			local RestockAmount = rng:NextInteger(Config.RestockMin, Config.RestockMax)
			CurrentStockData[CrateName] = RestockAmount
		end
	end

	for _, Player in Players:GetPlayers() do
		self:SetPlayerInfo(Player)
	end

	Remotes.ShowNotification:fireAll("The crate shop has been restocked!", Color3.fromRGB(0, 255, 0))
end

return CrateShopService
