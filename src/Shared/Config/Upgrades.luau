local Types = require("@Shared/Types")

local CashUpgrades = {
	[1] = { -- default starter shit
		Price = 0,
		NewValue = 1,
	},
	[2] = {
		Price = 150,
		NewValue = 1.1,
	},
	[3] = {
		Price = 700,
		NewValue = 1.2,
	},
	[4] = {
		Price = 3500,
		NewValue = 1.3,
	},
	[5] = {
		Price = 12500,
		NewValue = 1.4,
	},
	[6] = {
		Price = 37500,
		NewValue = 1.5,
	},
	[7] = {
		Price = 125000,
		NewValue = 1.75,
	},
	[8] = {
		Price = 450000,
		NewValue = 2,
	},
	[9] = {
		Price = 1750000,
		NewValue = 2.5,
	},
	[10] = {
		Price = 6000000,
		NewValue = 3,
	},
} :: { [number]: Types.UpgradeInfo<number> }

local LuckUpgrades = {
	[1] = { -- default starter shit
		Price = 0,
		NewValue = 1,
	},
	[2] = {
		Price = 100,
		NewValue = 1.2,
	},
	[3] = {
		Price = 500,
		NewValue = 1.4,
	},
	[4] = {
		Price = 2000,
		NewValue = 1.6,
	},
	[5] = {
		Price = 7500,
		NewValue = 1.8,
	},
	[6] = {
		Price = 25000,
		NewValue = 2,
	},
	[7] = {
		Price = 100000,
		NewValue = 2.5,
	},
	[8] = {
		Price = 300000,
		NewValue = 3,
	},
	[9] = {
		Price = 1250000,
		NewValue = 4,
	},
	[10] = {
		Price = 4000000,
		NewValue = 5,
	},
} :: { [number]: Types.UpgradeInfo<number> }

return {
	Cash = CashUpgrades,
	Luck = LuckUpgrades,
} :: { Cash: { [number]: Types.UpgradeInfo<number> }, Luck: { [number]: Types.UpgradeInfo<number> } }
