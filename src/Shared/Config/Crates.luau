local Types = require("@Shared/Types")

return {
	["Crate"] = {
		Health = 100,

		SpawnChance = 100, -- chance of this crate spawning

		Chances = {
			["Common"] = 50, -- 50% chance
			["Rare"] = 50, -- 50% chance
		},
	},
} :: { [string]: Types.CrateConfig }
