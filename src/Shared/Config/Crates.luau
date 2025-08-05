local Types = require("@Shared/Types")

return {
	["Wooden Crate"] = {
		Health = 100,

		SpawnChance = 10, -- chance of this crate spawning

		RestockChance = 100, -- chance of this crate being restocked
		RestockMin = 1, -- minimum amount of crates to restock
		RestockMax = 7, -- maximum amount of crates to restock

		Product = 0, -- dev product
		Price = 100, -- cash p rice

		Image = "",

		LayoutOrder = 1,

		Chances = {
			["Common"] = 50, -- 50% chance
			["Rare"] = 50, -- 50% chance
		},
	},
	["Iron Crate"] = {
		Health = 100,

		SpawnChance = 10, -- chance of this crate spawning

		RestockChance = 100, -- chance of this crate being restocked
		RestockMin = 1, -- minimum amount of crates to restock
		RestockMax = 7, -- maximum amount of crates to restock

		Product = 0, -- dev product
		Price = 100, -- cash p rice

		Image = "",

		LayoutOrder = 3,

		Chances = {
			["Common"] = 50, -- 50% chance
			["Rare"] = 50, -- 50% chance
		},
	},
	["Refined Crate"] = {
		Health = 100,

		SpawnChance = 10, -- chance of this crate spawning

		RestockChance = 100, -- chance of this crate being restocked
		RestockMin = 1, -- minimum amount of crates to restock
		RestockMax = 7, -- maximum amount of crates to restock

		Product = 0, -- dev product
		Price = 100, -- cash p rice

		Image = "",

		LayoutOrder = 5,

		Chances = {
			["Common"] = 50, -- 50% chance
			["Rare"] = 50, -- 50% chance
		},
	},
	["Arcane Crate"] = {
		Health = 100,

		SpawnChance = 10, -- chance of this crate spawning

		RestockChance = 100, -- chance of this crate being restocked
		RestockMin = 1, -- minimum amount of crates to restock
		RestockMax = 7, -- maximum amount of crates to restock

		Product = 0, -- dev product
		Price = 100, -- cash p rice

		Image = "",

		LayoutOrder = 7,

		Chances = {
			["Common"] = 50, -- 50% chance
			["Rare"] = 50, -- 50% chance
		},
	},
	["Royal Crate"] = {
		Health = 100,

		SpawnChance = 10, -- chance of this crate spawning

		RestockChance = 100, -- chance of this crate being restocked
		RestockMin = 1, -- minimum amount of crates to restock
		RestockMax = 7, -- maximum amount of crates to restock

		Product = 0, -- dev product
		Price = 100, -- cash p rice

		Image = "",

		LayoutOrder = 9,

		Chances = {
			["Common"] = 50, -- 50% chance
			["Rare"] = 50, -- 50% chance
		},
	},
	["Rune Crate"] = {
		Health = 100,

		SpawnChance = 10, -- chance of this crate spawning

		RestockChance = 100, -- chance of this crate being restocked
		RestockMin = 1, -- minimum amount of crates to restock
		RestockMax = 7, -- maximum amount of crates to restock

		Product = 0, -- dev product
		Price = 100, -- cash p rice

		Image = "",

		LayoutOrder = 11,

		Chances = {
			["Common"] = 50, -- 50% chance
			["Rare"] = 50, -- 50% chance
		},
	},
	["Solar Crate"] = {
		Health = 100,

		SpawnChance = 10, -- chance of this crate spawning

		RestockChance = 100, -- chance of this crate being restocked
		RestockMin = 1, -- minimum amount of crates to restock
		RestockMax = 7, -- maximum amount of crates to restock

		Product = 0, -- dev product
		Price = 100, -- cash p rice

		Image = "",

		LayoutOrder = 13,

		Chances = {
			["Common"] = 50, -- 50% chance
			["Rare"] = 50, -- 50% chance
		},
	},
	["Void Crate"] = {
		Health = 100,

		SpawnChance = 10, -- chance of this crate spawning

		RestockChance = 100, -- chance of this crate being restocked
		RestockMin = 1, -- minimum amount of crates to restock
		RestockMax = 7, -- maximum amount of crates to restock

		Product = 0, -- dev product
		Price = 100, -- cash p rice

		Image = "",

		LayoutOrder = 15,

		Chances = {
			["Common"] = 50, -- 50% chance
			["Rare"] = 50, -- 50% chance
		},
	},
	["Kraken Crate"] = {
		Health = 100,

		SpawnChance = 10, -- chance of this crate spawning

		RestockChance = 100, -- chance of this crate being restocked
		RestockMin = 1, -- minimum amount of crates to restock
		RestockMax = 7, -- maximum amount of crates to restock

		Product = 0, -- dev product
		Price = 100, -- cash p rice

		Image = "",

		LayoutOrder = 17,

		Chances = {
			["Common"] = 50, -- 50% chance
			["Rare"] = 50, -- 50% chance
		},
	},
	["GL!TCH Crate"] = {
		Health = 100,

		SpawnChance = 10, -- chance of this crate spawning

		RestockChance = 100, -- chance of this crate being restocked
		RestockMin = 1, -- minimum amount of crates to restock
		RestockMax = 7, -- maximum amount of crates to restock

		Product = 0, -- dev product
		Price = 100, -- cash p rice

		Image = "",

		LayoutOrder = 19,

		Chances = {
			["Common"] = 50, -- 50% chance
			["Rare"] = 50, -- 50% chance
		},
	},
} :: { [string]: Types.CrateConfig }
