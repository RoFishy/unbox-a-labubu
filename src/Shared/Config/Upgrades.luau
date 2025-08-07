local Types = require("@Shared/Types")

local CashUpgrades = {
	[1] = { -- default starter shit
		Price = 0,
		NewValue = 1,
	},
	[2] = {
		Price = 500,
		NewValue = 1.1,
	},
	[3] = {
		Price = 2500,
		NewValue = 1.2,
	},
	[4] = {
		Price = 9500,
		NewValue = 1.3,
	},
	[5] = {
		Price = 19000,
		NewValue = 1.4,
	},
	[6] = {
		Price = 75000,
		NewValue = 1.5,
	},
	[7] = {
		Price = 250000,
		NewValue = 1.75,
	},
	[8] = {
		Price = 950000,
		NewValue = 2,
	},
	[9] = {
		Price = 5000000,
		NewValue = 2.5,
	},
	[10] = {
		Price = 12000000,
		NewValue = 3,
	},
} :: { [number]: Types.UpgradeInfo<number> }

local LuckUpgrades = {
	[1] = { -- default starter shit
		Price = 0,
		NewValue = 1,
	},
	[2] = {
		Price = 1000,
		NewValue = 1.2,
	},
	[3] = {
		Price = 5000,
		NewValue = 1.4,
	},
	[4] = {
		Price = 8500,
		NewValue = 1.6,
	},
	[5] = {
		Price = 25000,
		NewValue = 1.8,
	},
	[6] = {
		Price = 75000,
		NewValue = 2,
	},
	[7] = {
		Price = 180000,
		NewValue = 2.5,
	},
	[8] = {
		Price = 500000,
		NewValue = 3,
	},
	[9] = {
		Price = 2250000,
		NewValue = 4,
	},
	[10] = {
		Price = 7000000,
		NewValue = 5,
	},
} :: { [number]: Types.UpgradeInfo<number> }

return {
	Cash = CashUpgrades,
	Luck = LuckUpgrades,
} :: { Cash: { [number]: Types.UpgradeInfo<number> }, Luck: { [number]: Types.UpgradeInfo<number> } }
