local Remotes = require("@Shared/Remotes")

local HammerTool = require("@ServerClasses/HammerTool")

local DataUtil = require("@ServerUtility/DataUtil")
local PlotUtil = require("@ServerUtility/PlotUtil")

local Cache = require("@ServerUtility/Cache")

local function AddCrateToPlayer(Player: Player, CrateName: string)
	if Cache.PlayerCrates[Player] then
		table.insert(Cache.PlayerCrates[Player], CrateName)
	else
		Cache.PlayerCrates[Player] = { CrateName }
	end
end

local function AwardHammerToPlayer(Player: Player, Hammer: number)
	local PlayerData = DataUtil:GetData(Player)
	if PlayerData then
		local CurrentTool = PlayerData.Upgrades.Tool

		if PlayerData.Upgrades.Tool > Hammer then
			return Remotes.ShowNotification:fire(
				Player,
				"You already have a better hammer than this!",
				Color3.fromRGB(255, 0, 0),
				"Error"
			)
		else
			PlayerData.Upgrades.Tool = Hammer
		end

		DataUtil:SetData(Player, PlayerData)

		local Backpack = Player.Backpack
		local CurrentToolObject = Backpack:FindFirstChild(tostring(CurrentTool))

		if CurrentToolObject then
			CurrentToolObject:Destroy()
		else
			local Character = Player.Character or Player.CharacterAdded:Wait()
			CurrentToolObject = Character:FindFirstChild(tostring(CurrentTool))
			if CurrentToolObject then
				CurrentToolObject:Destroy()
			end
		end

		HammerTool.new(Player)
	end
end

return {
	-- // Packs
	[1346234128] = function(Player: Player) -- STARTER PACK
		AwardHammerToPlayer(Player, 3)

		AddCrateToPlayer(Player, "Arcane Crate")
		Remotes.ShowNotification:fire(
			Player,
			"Your arcane crate will spawn on your base as the next crate.",
			Color3.fromRGB(0, 255, 0)
		)

		local PlayerData = DataUtil:GetData(Player)
		if PlayerData then
			PlayerData = table.clone(PlayerData)
			PlayerData.Cash += 1_000
			DataUtil:SetData(Player, PlayerData)
		end

		Remotes.ShowNotification:fire(
			Player,
			"You have successfully unlocked the Starter Pack!",
			Color3.fromRGB(0, 255, 0),
			"CashCollect"
		)
	end,
	[1345624182] = function(Player: Player) -- ULTIMATE PACK
		AwardHammerToPlayer(Player, 5)

		AddCrateToPlayer(Player, "Royal Crate")
		Remotes.ShowNotification:fire(
			Player,
			"Your royal crate will spawn on your base as the next crate.",
			Color3.fromRGB(0, 255, 0)
		)

		local PlayerData = DataUtil:GetData(Player)
		if PlayerData then
			PlayerData = table.clone(PlayerData)
			PlayerData.Cash += 10_000
			DataUtil:SetData(Player, PlayerData)
		end

		Remotes.ShowNotification:fire(
			Player,
			"You have successfully unlocked the Starter Pack!",
			Color3.fromRGB(0, 255, 0),
			"CashCollect"
		)
	end,

	-- // other passes
	[1346702052] = function(Player: Player) -- VIP
		local PlayerData = DataUtil:GetData(Player)
		if PlayerData then
			PlayerData = table.clone(PlayerData)
			PlayerData.Luck += 0.25
			PlayerData.CashMulti += 0.25
			DataUtil:SetData(Player, PlayerData)
		end

		Remotes.ShowNotification:fire(
			Player,
			"You have successfully unlocked VIP!",
			Color3.fromRGB(255, 209, 3),
			"CashCollect"
		)
	end,
	[1347317999] = function(Player: Player) -- x2 Money
		local PlayerData = DataUtil:GetData(Player)
		if PlayerData then
			PlayerData = table.clone(PlayerData)
			PlayerData.CashMulti += 1
			DataUtil:SetData(Player, PlayerData)
		end

		Remotes.ShowNotification:fire(
			Player,
			"You have successfully unlocked x2 Money!",
			Color3.fromRGB(0, 255, 0),
			"CashCollect"
		)
	end,
	[1347413880] = function(Player: Player) -- x2 Luck
		local PlayerData = DataUtil:GetData(Player)
		if PlayerData then
			PlayerData = table.clone(PlayerData)
			PlayerData.Luck += 1
			DataUtil:SetData(Player, PlayerData)
		end

		Remotes.ShowNotification:fire(
			Player,
			"You have successfully unlocked x2 Luck!",
			Color3.fromRGB(0, 255, 0),
			"CashCollect"
		)
	end,
	[1346052101] = function(Player: Player) -- +2 Slots
		local PlayerData = DataUtil:GetData(Player)
		if PlayerData then
			PlayerData = table.clone(PlayerData)
			table.insert(PlayerData.ExtraSlots, 11)
			table.insert(PlayerData.ExtraSlots, 12)
			DataUtil:SetData(Player, PlayerData)
		end

		local PlayerPlot = PlotUtil:GetPlayerPlot(Player)
		if PlayerPlot then
			PlotUtil:SetupExtraSlots(PlayerPlot)
		end

		Remotes.ShowNotification:fire(
			Player,
			"You have successfully unlocked +2 Slots!",
			Color3.fromRGB(0, 255, 0),
			"CashCollect"
		)
	end,

	-- // Tools
	[1346871951] = function(Player: Player) -- Banhammer
		AwardHammerToPlayer(Player, 11)

		Remotes.ShowNotification:fire(
			Player,
			"You have successfully unlocked the Banhammer!",
			Color3.fromRGB(255, 0, 0),
			"CashCollect"
		)
	end,
} :: { [number]: (Player) -> () }
