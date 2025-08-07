local Types = require("@Shared/Types")

return {
	["Regular"] = {
		SpawnChance = 50,
		Scale = 2,
		CashMultiplier = 1,
		Offset = CFrame.new(0, 0, 0), -- the offset of the labubu shit
	},
	["Big"] = {
		SpawnChance = 10, -- 10% chance
		Scale = 5,
		CashMultiplier = 1.25,
		Offset = CFrame.new(0, 3, 0), -- the offset of the labubu shit
	},
	["Huge"] = {
		SpawnChance = 5, -- 5% chance
		Scale = 7,
		CashMultiplier = 1.75,
		Offset = CFrame.new(0, 5, 0), -- the offset of the labubu shit
	},
} :: { [string]: Types.SizeConfig }
