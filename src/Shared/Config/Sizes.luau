local Types = require(script.Parent.Parent:WaitForChild("Types"))

return {
	["Regular"] = {
		SpawnChance = 90,
		Scale = 2,
		CashMultiplier = 1,
		Offset = CFrame.new(0, 0, 0), -- the offset of the labubu shit
		PickupDistance = 7,
	},
	["Huge"] = {
		SpawnChance = 10, -- 10% chance
		Scale = 4,
		CashMultiplier = 1.5,
		Offset = CFrame.new(0, 4, 0), -- the offset of the labubu shit
		PickupDistance = 10, -- proximity prompt range
	},
	["Titanic"] = {
		SpawnChance = 5, -- 5% chance
		Scale = 8,
		CashMultiplier = 2,
		Offset = CFrame.new(0, 11, 0), -- the offset of the labubu shit
		PickupDistance = 17, -- proximity prompt range
	},
} :: { [string]: Types.SizeConfig }
