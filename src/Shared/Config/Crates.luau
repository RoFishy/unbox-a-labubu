local Types = require(script.Parent.Parent:WaitForChild("Types"))

return {
	["Wooden Crate"] = {
		Health = 100,

		SpawnChance = 30, -- chance of this crate spawning

		RestockChance = 50, -- chance of this crate being restocked
		RestockMin = 1, -- minimum amount of crates to restock
		RestockMax = 10, -- maximum amount of crates to restock

		Product = 3359772575, -- dev product
		Price = 50, -- cash p rice

		Image = "rbxassetid://118635082887093",

		GradientLabel = "Common",

		LayoutOrder = 1,

		Chances = {
			["Common"] = 50, -- 50% chance
			["Uncommon"] = 40, -- 40% chance
			["Rare"] = 10, -- 10% chance
		},
	},
	["Iron Crate"] = {
		Health = 200,

		SpawnChance = 25, -- chance of this crate spawning

		RestockChance = 35, -- chance of this crate being restocked
		RestockMin = 1, -- minimum amount of crates to restock
		RestockMax = 8, -- maximum amount of crates to restock

		Product = 3359774458, -- dev product
		Price = 250, -- cash p rice

		Image = "rbxassetid://84888084943105",

		GradientLabel = "Common",

		LayoutOrder = 3,

		Chances = {
			["Common"] = 40, -- 40% chance
			["Uncommon"] = 40, -- 40% chance
			["Rare"] = 20, -- 20% chance
		},
	},
	["Refined Crate"] = {
		Health = 400,

		SpawnChance = 20, -- chance of this crate spawning

		RestockChance = 25, -- chance of this crate being restocked
		RestockMin = 1, -- minimum amount of crates to restock
		RestockMax = 7, -- maximum amount of crates to restock

		Product = 3359774865, -- dev product
		Price = 750, -- cash p rice

		Image = "rbxassetid://129584799233513",

		GradientLabel = "Uncommon",

		LayoutOrder = 5,

		Chances = {
			["Common"] = 30, -- 30% chance
			["Uncommon"] = 40, -- 40% chance
			["Rare"] = 30, -- 30% chance
		},
	},
	["Arcane Crate"] = {
		Health = 1000,

		SpawnChance = 15, -- chance of this crate spawning

		RestockChance = 20, -- chance of this crate being restocked
		RestockMin = 1, -- minimum amount of crates to restock
		RestockMax = 6, -- maximum amount of crates to restock

		Product = 3359775299, -- dev product
		Price = 3500, -- cash p rice

		Image = "rbxassetid://104570030548954",

		GradientLabel = "Uncommon",

		LayoutOrder = 7,

		Chances = {
			["Rare"] = 60, -- 50% chance
			["Epic"] = 35, -- 40% chance
			["Legendary"] = 5, -- 10% chance
		},
	},
	["Royal Crate"] = {
		Health = 2500,

		SpawnChance = 10, -- chance of this crate spawning

		RestockChance = 15, -- chance of this crate being restocked
		RestockMin = 1, -- minimum amount of crates to restock
		RestockMax = 5, -- maximum amount of crates to restock

		Product = 3359775390, -- dev product
		Price = 20000, -- cash p rice

		Image = "rbxassetid://70622623610806",

		GradientLabel = "Rare",

		LayoutOrder = 9,

		Chances = {
			["Rare"] = 40, -- 50% chance
			["Epic"] = 50, -- 40% chance
			["Legendary"] = 10, -- 10% chance
		},
	},
	["Rune Crate"] = {
		Health = 5000,

		SpawnChance = 5, -- chance of this crate spawning

		RestockChance = 10, -- chance of this crate being restocked
		RestockMin = 1, -- minimum amount of crates to restock
		RestockMax = 4, -- maximum amount of crates to restock

		Product = 3359775809, -- dev product
		Price = 70000, -- cash p rice

		Image = "rbxassetid://113922224251608",

		GradientLabel = "Rare",

		LayoutOrder = 11,

		Chances = {
			["Epic"] = 60, -- 50% chance
			["Legendary"] = 35, -- 40% chance
			["Divine"] = 5, -- 10% chance
		},
	},
	["Solar Crate"] = {
		Health = 10000,

		SpawnChance = 3, -- chance of this crate spawning

		RestockChance = 5, -- chance of this crate being restocked
		RestockMin = 1, -- minimum amount of crates to restock
		RestockMax = 3, -- maximum amount of crates to restock

		Product = 3359776256, -- dev product
		Price = 150000, -- cash p rice

		Image = "rbxassetid://117787260158263",

		GradientLabel = "Epic",

		LayoutOrder = 13,

		Chances = {
			["Epic"] = 40, -- 50% chance
			["Legendary"] = 50, -- 40% chance
			["Divine"] = 10, -- 10% chance
		},
	},
	["Void Crate"] = {
		Health = 22500,

		SpawnChance = 1, -- chance of this crate spawning

		RestockChance = 3, -- chance of this crate being restocked
		RestockMin = 1, -- minimum amount of crates to restock
		RestockMax = 2, -- maximum amount of crates to restock

		Product = 3359776554, -- dev product
		Price = 500000, -- cash p rice

		Image = "rbxassetid://108271337314448",

		GradientLabel = "Legendary",

		LayoutOrder = 15,

		Chances = {
			["Epic"] = 15, -- 50% chance
			["Legendary"] = 58, -- 60% chance
			["Divine"] = 25, -- 30% chance
			["Secret"] = 2, -- 10% chance
		},
	},
	["Kraken Crate"] = {
		Health = 37500,

		SpawnChance = 0.7, -- chance of this crate spawning

		RestockChance = 1.5, -- chance of this crate being restocked
		RestockMin = 1, -- minimum amount of crates to restock
		RestockMax = 1, -- maximum amount of crates to restock

		Product = 3359776710, -- dev product
		Price = 2500000, -- cash p rice

		Image = "rbxassetid://85351769081139",

		GradientLabel = "Divine",

		LayoutOrder = 17,

		Chances = {
			["Legendary"] = 30, -- 60% chance
			["Divine"] = 60, -- 30% chance
			["Secret"] = 10, -- 10% chance
		},
	},
	["GL!TCH Crate"] = {
		Health = 60000,

		SpawnChance = 0.3, -- chance of this crate spawning

		RestockChance = 1, -- chance of this crate being restocked
		RestockMin = 1, -- minimum amount of crates to restock
		RestockMax = 1, -- maximum amount of crates to restock

		Product = 3359776872, -- dev product
		Price = 15000000, -- cash p rice

		Image = "rbxassetid://130097129619276",

		GradientLabel = "Secret",

		LayoutOrder = 19,

		Chances = {
			["Legendary"] = 10, -- 60% chance
			["Divine"] = 50, -- 30% chance
			["Secret"] = 40, -- 10% chance
		},
	},
} :: { [string]: Types.CrateConfig }
