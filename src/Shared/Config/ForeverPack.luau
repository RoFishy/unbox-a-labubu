local ForeverPack = {}

local function AddCashToPlayer(Player: Player, Amount: number)
	local DataUtil = require(game:GetService("ServerStorage"):WaitForChild("Utility"):WaitForChild("DataUtil"))
	local Data = DataUtil:GetData(Player)
	if Data then
		Data = table.clone(Data)
		Data.Cash += Amount
		DataUtil:SetData(Player, Data)
	end
end

local function AddCrateToPlayer(Player: Player, CrateName: string)
	local Cache = require(game:GetService("ServerStorage"):WaitForChild("Utility"):WaitForChild("Cache"))
	if Cache.PlayerCrates[Player] then
		table.insert(Cache.PlayerCrates[Player], CrateName .. " Crate")
	else
		Cache.PlayerCrates[Player] = { CrateName .. " Crate" }
	end
end

local CurrentLuckConn

local function AddLuckToPlayer(Player: Player, Amount: number, Time: number)
	Player:SetAttribute("Luck", Amount)

	if CurrentLuckConn then
		task.cancel(CurrentLuckConn)
	end

	CurrentLuckConn = task.delay(Time, function()
		if Player then
			local CurrentLuck = Player:GetAttribute("Luck") :: number
			Player:SetAttribute("Luck", CurrentLuck - Amount)
		end
	end)
end

ForeverPack.Rewards = {
	[1] = {
		Image = "rbxassetid://81389192039217",
		Chance = 30,
		Text = "$500",
		ClaimFunction = function(Player)
			AddCashToPlayer(Player, 500)
		end,
	},
	[2] = {
		Image = "rbxassetid://81389192039217",
		Chance = 25,
		Text = "$1k",
		ClaimFunction = function(Player)
			AddCashToPlayer(Player, 1000)
		end,
	},
	[3] = {
		Image = "rbxassetid://127283057840884",
		Chance = 15,
		Text = "x2 Luck (5 Minutes)",
		ClaimFunction = function(Player)
			AddLuckToPlayer(Player, 2, 300)
		end,
	},
	[4] = {
		Image = "rbxassetid://117787260158263",
		Chance = 8,
		Text = "Solar Crate",
		ClaimFunction = function(Player)
			AddCrateToPlayer(Player, "Solar")
		end,
	},
	[5] = {
		Image = "rbxassetid://108271337314448",
		Chance = 4,
		Text = "Void Crate",
		ClaimFunction = function(Player)
			AddCrateToPlayer(Player, "Void")
		end,
	},
	[6] = {
		Image = "rbxassetid://81389192039217",
		Chance = 10,
		Text = "$50k",
		ClaimFunction = function(Player)
			AddCashToPlayer(Player, 50_000)
		end,
	},
	[7] = {
		Image = "rbxassetid://85351769081139",
		Chance = 3,
		Text = "Kraken Crate",
		ClaimFunction = function(Player)
			AddCrateToPlayer(Player, "Kraken")
		end,
	},
	[8] = {
		Image = "rbxassetid://81389192039217",
		Chance = 4,
		Text = "$150k",
		ClaimFunction = function(Player)
			AddCashToPlayer(Player, 150_000)
		end,
	},
	[9] = {
		Image = "rbxassetid://81389192039217",
		Chance = 2,
		Text = "$500k",
		ClaimFunction = function(Player)
			AddCashToPlayer(Player, 500_000)
		end,
	},
	[10] = {
		Image = "rbxassetid://81389192039217",
		Chance = 1,
		Text = "$2M",
		ClaimFunction = function(Player)
			AddCashToPlayer(Player, 2_000_000)
		end,
	},
	[11] = {
		Image = "rbxassetid://130097129619276",
		Chance = 1.5,
		Text = "GL1TCH Crate",
		ClaimFunction = function(Player)
			AddCrateToPlayer(Player, "GL1TCH")
		end,
	},
	[12] = {
		Image = "rbxassetid://127283057840884",
		Chance = 9,
		Text = "x2 Luck (15 minutes)",
		ClaimFunction = function(Player)
			AddLuckToPlayer(Player, 2, 900)
		end,
	},
	[13] = {
		Image = "rbxassetid://127283057840884",
		Chance = 5,
		Text = "x2 Luck (30 minutes)",
		ClaimFunction = function(Player)
			AddLuckToPlayer(Player, 2, 18E2)
		end,
	},
	[14] = {
		Image = "rbxassetid://127283057840884",
		Chance = 3,
		Text = "x2 Luck (45 minutes)",
		ClaimFunction = function(Player)
			AddLuckToPlayer(Player, 2, 27E2)
		end,
	},
}

ForeverPack.PriceGap = {
	[5] = 3349324735,
	[10] = 3349324953,
	[15] = 3349325130,
	[20] = 3349325279,
	[25] = 3349325427,
}

ForeverPack.GetPriceFromIndex = function(Index: number): string | number
	if Index % 3 ~= 0 then
		return "Free"
	else
		return ForeverPack.PriceGap[Index] and ForeverPack.PriceGap[Index] or ForeverPack.PriceGap[25]
	end
end

ForeverPack.GetNextIndex = function(ForeverPackTable)
	local NextTableIndex

	for index in pairs(ForeverPackTable) do
		local numIndex = tonumber(index)
		if numIndex then
			if not NextTableIndex or numIndex < NextTableIndex then
				NextTableIndex = numIndex
			end
		end
	end

	return NextTableIndex
end

ForeverPack.PickRandomRewardIndex = function(): number?
	local total = 0
	for _, r in ipairs(ForeverPack.Rewards) do
		total = total + r.Chance
	end
	local roll = math.random() * total
	local acc = 0
	for i, r in ipairs(ForeverPack.Rewards) do
		acc = acc + r.Chance
		if roll <= acc then
			return i
		end
	end
	return
end

return ForeverPack
