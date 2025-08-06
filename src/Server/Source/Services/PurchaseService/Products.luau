-- // Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- // luck
local CurrentLuck = ReplicatedStorage:WaitForChild("Luck"):WaitForChild("LuckAmount") :: IntValue
local LuckTime = ReplicatedStorage:WaitForChild("Luck"):WaitForChild("LuckTime") :: IntValue

-- // mod
local Remotes = require("@Shared/Remotes")

local CalculateEarningsByTime = require("@Utility/CalculateEarningsByTime")

local Cache = require("@ServerUtility/Cache")
local DataUtil = require("@ServerUtility/DataUtil")

local ForeverPackService = require("@Services/ForeverPackService")

local function AddCrateToPlayer(Player: Player, CrateName: string)
	if Cache.PlayerCrates[Player] then
		table.insert(Cache.PlayerCrates[Player], CrateName)
	else
		Cache.PlayerCrates[Player] = { CrateName }
	end
end

local function AddSkipToPlayer(Player: Player, Time: number)
	local Earnings = CalculateEarningsByTime(Player, Time)

	local PlayerData = DataUtil:GetData(Player)
	if PlayerData then
		PlayerData.Cash += Earnings
		DataUtil:SetData(Player, PlayerData)
	end
end

return {
	-- // Crates
	[3359772575] = function(Player) -- wooden
		AddCrateToPlayer(Player, "Wooden Crate")

		Remotes.ShowNotification:fire(
			Player,
			"You have successfully purchased a Wooden Crate! It will spawn on your base as the next crate.",
			Color3.fromRGB(0, 255, 0),
			"CashCollect"
		)
	end,
	[3359774458] = function(Player) -- iron
		AddCrateToPlayer(Player, "Iron Crate")

		Remotes.ShowNotification:fire(
			Player,
			"You have successfully purchased an Iron Crate! It will spawn on your base as the next crate.",
			Color3.fromRGB(0, 255, 0),
			"CashCollect"
		)
	end,
	[3359774865] = function(Player) -- refined
		AddCrateToPlayer(Player, "Refined Crate")

		Remotes.ShowNotification:fire(
			Player,
			"You have successfully purchased a Refined Crate! It will spawn on your base as the next crate.",
			Color3.fromRGB(0, 255, 0),
			"CashCollect"
		)
	end,
	[3359775299] = function(Player) -- arcane
		AddCrateToPlayer(Player, "Arcane Crate")

		Remotes.ShowNotification:fire(
			Player,
			"You have successfully purchased an Arcane Crate! It will spawn on your base as the next crate.",
			Color3.fromRGB(0, 255, 0),
			"CashCollect"
		)
	end,
	[3359775390] = function(Player) -- royal
		AddCrateToPlayer(Player, "Royal Crate")

		Remotes.ShowNotification:fire(
			Player,
			"You have successfully purchased a Royal Crate! It will spawn on your base as the next crate.",
			Color3.fromRGB(0, 255, 0),
			"CashCollect"
		)
	end,
	[3359775809] = function(Player) -- rune
		AddCrateToPlayer(Player, "Rune Crate")

		Remotes.ShowNotification:fire(
			Player,
			"You have successfully purchased a Rune Crate! It will spawn on your base as the next crate.",
			Color3.fromRGB(0, 255, 0),
			"CashCollect"
		)
	end,
	[3359776256] = function(Player: Player) -- solar
		AddCrateToPlayer(Player, "Solar Crate")

		Remotes.ShowNotification:fire(
			Player,
			"You have successfully purchased a Solar Crate! It will spawn on your base as the next crate.",
			Color3.fromRGB(0, 255, 0),
			"CashCollect"
		)
	end,
	[3359776554] = function(Player: Player) -- void
		AddCrateToPlayer(Player, "Void Crate")

		Remotes.ShowNotification:fire(
			Player,
			"You have successfully purchased a Void Crate! It will spawn on your base as the next crate.",
			Color3.fromRGB(0, 255, 0),
			"CashCollect"
		)
	end,
	[3359776710] = function(Player) -- kraken
		AddCrateToPlayer(Player, "Kraken Crate")

		Remotes.ShowNotification:fire(
			Player,
			"You have successfully purchased a Kraken Crate! It will spawn on your base as the next crate.",
			Color3.fromRGB(0, 255, 0),
			"CashCollect"
		)
	end,
	[3359776872] = function(Player) -- glitch
		AddCrateToPlayer(Player, "GL!TCH Crate")

		Remotes.ShowNotification:fire(
			Player,
			"You have successfully purchased a GL!TCH Crate! It will spawn on your base as the next crate.",
			Color3.fromRGB(0, 255, 0),
			"CashCollect"
		)
	end,

	-- skips
	[3349328035] = function(Player) -- 5 minutes
		AddSkipToPlayer(Player, 60 * 5)

		Remotes.ShowNotification:fire(
			Player,
			"You have successfully purchased a 5 minute skip!",
			Color3.fromRGB(0, 255, 0),
			"CashCollect"
		)
	end,
	[3349328280] = function(Player) -- 30 minutes
		AddSkipToPlayer(Player, 60 * 30)

		Remotes.ShowNotification:fire(
			Player,
			"You have successfully purchased a 30 minute skip!",
			Color3.fromRGB(0, 255, 0),
			"CashCollect"
		)
	end,
	[3349328493] = function(Player) -- 2 hours
		AddSkipToPlayer(Player, 60 * 60 * 2)

		Remotes.ShowNotification:fire(
			Player,
			"You have successfully purchased a 2 hour skip!",
			Color3.fromRGB(0, 255, 0),
			"CashCollect"
		)
	end,
	[3349328709] = function(Player) -- 12 hours
		AddSkipToPlayer(Player, 60 * 60 * 12)

		Remotes.ShowNotification:fire(
			Player,
			"You have successfully purchased a 12 hour skip!",
			Color3.fromRGB(0, 255, 0),
			"CashCollect"
		)
	end,
	[3349328876] = function(Player) -- 48 hours
		AddSkipToPlayer(Player, 60 * 60 * 48)

		Remotes.ShowNotification:fire(
			Player,
			"You have successfully purchased a 48 hour skip!",
			Color3.fromRGB(0, 255, 0),
			"CashCollect"
		)
	end,

	-- // Forever Pack Shit
	[3349324735] = function(Player)
		ForeverPackService:ClaimNextForeverPackReward(Player)
	end,
	[3349324953] = function(Player)
		ForeverPackService:ClaimNextForeverPackReward(Player)
	end,
	[3349325130] = function(Player)
		ForeverPackService:ClaimNextForeverPackReward(Player)
	end,
	[3349325279] = function(Player)
		ForeverPackService:ClaimNextForeverPackReward(Player)
	end,
	[3349325427] = function(Player)
		ForeverPackService:ClaimNextForeverPackReward(Player)
	end,

	-- // Server Luck
	[3349326063] = function(Player) -- 2x luck
		LuckTime.Value = 60 * 15 -- 15 minutes
		CurrentLuck.Value = 2

		task.spawn(function()
			while LuckTime.Value > 0 do
				task.wait(1)
				LuckTime.Value -= 1
			end
			CurrentLuck.Value = 1
		end)

		Remotes.ShowNotification:fireAll(
			`{Player.Name} has purchased 2x server luck for 15 minutes!`,
			Color3.fromRGB(0, 255, 0),
			"CashCollect"
		)
	end,
	[3349326234] = function(Player) -- 4x luck
		LuckTime.Value = 60 * 15 -- 15 minutes
		CurrentLuck.Value = 4

		Remotes.ShowNotification:fireAll(
			`{Player.Name} has purchased 4x server luck for 15 minutes!`,
			Color3.fromRGB(0, 255, 0),
			"CashCollect"
		)
	end,
	[3349326380] = function(Player) -- 8x luck
		LuckTime.Value = 60 * 15 -- 15 minutes
		CurrentLuck.Value = 8

		Remotes.ShowNotification:fireAll(
			`{Player.Name} has purchased 8x server luck for 15 minutes!`,
			Color3.fromRGB(0, 255, 0),
			"CashCollect"
		)
	end,
	[3349326654] = function(Player) -- 16x luck
		LuckTime.Value = 60 * 15 -- 15 minutes
		CurrentLuck.Value = 16

		Remotes.ShowNotification:fireAll(
			`{Player.Name} has purchased 16x server luck for 15 minutes!`,
			Color3.fromRGB(0, 255, 0),
			"CashCollect"
		)
	end,
} :: { [number]: (Player) -> () }
