local Types = require("@Shared/Types")

return {
	Cash = 0,

	Upgrades = {
		Cash = 1,
		Luck = 1,
		Tool = 1,
	},

	Backpack = {},
	Labubus = {},

	Index = {},

	ExtraSlots = {},

	ClaimedFreeReward = false,
} :: Types.UserData
