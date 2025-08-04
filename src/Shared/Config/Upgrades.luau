local Types = require("@Shared/Types")

local CashUpgrades = {
	[1] = { -- default starter shit
		Price = 0,
		NewValue = 1,
	},
	[2] = {
		Price = 100,
		NewValue = 1.5,
	},
} :: { [number]: Types.UpgradeInfo<number> }

local LuckUpgrades = {
	[1] = { -- default starter shit
		Price = 0,
		NewValue = 1,
	},
	[2] = {
		Price = 100,
		NewValue = 1.5,
	},
} :: { [number]: Types.UpgradeInfo<number> }

return {
	Cash = CashUpgrades,
	Luck = LuckUpgrades,
} :: { Cash: { [number]: Types.UpgradeInfo<number> }, Luck: { [number]: Types.UpgradeInfo<number> } }
