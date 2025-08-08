local Types = require("@Shared/Types")

local CashUpgrades = {
	[1] = { -- default starter shit
		Price = 0,
		NewValue = 1,
	},
	[2] = {
		Price = 5000,
		NewValue = 1.1,
	},
	[3] = {
		Price = 25000,
		NewValue = 1.2,
	},
	[4] = {
		Price = 95000,
		NewValue = 1.3,
	},
	[5] = {
		Price = 190000,
		NewValue = 1.4,
	},
	[6] = {
		Price = 750000,
		NewValue = 1.5,
	},
	[7] = {
		Price = 2500000,
		NewValue = 1.75,
	},
	[8] = {
		Price = 9500000,
		NewValue = 2,
	},
	[9] = {
		Price = 50000000,
		NewValue = 2.5,
	},
	[10] = {
		Price = 120000000,
		NewValue = 3,
	},
} :: { [number]: Types.UpgradeInfo<number> }

local LuckUpgrades = {
	[1] = { -- default starter shit
		Price = 0,
		NewValue = 1,
	},
	[2] = {
		Price = 10000,
		NewValue = 1.2,
	},
	[3] = {
		Price = 50000,
		NewValue = 1.4,
	},
	[4] = {
		Price = 85000,
		NewValue = 1.6,
	},
	[5] = {
		Price = 250000,
		NewValue = 1.8,
	},
	[6] = {
		Price = 750000,
		NewValue = 2,
	},
	[7] = {
		Price = 1800000,
		NewValue = 2.5,
	},
	[8] = {
		Price = 5000000,
		NewValue = 3,
	},
	[9] = {
		Price = 22500000,
		NewValue = 4,
	},
	[10] = {
		Price = 70000000,
		NewValue = 5,
	},
} :: { [number]: Types.UpgradeInfo<number> }

return {
	Cash = CashUpgrades,
	Luck = LuckUpgrades,
} :: { Cash: { [number]: Types.UpgradeInfo<number> }, Luck: { [number]: Types.UpgradeInfo<number> } }
