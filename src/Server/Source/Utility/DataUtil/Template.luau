local Types = require("@Shared/Types")

return {
	Cash = 0,
	LastJoin = nil,
	Unboxes = 0,

	Upgrades = {
		Cash = 1,
		Luck = 1,
		Tool = 1,
	},

	-- gamepass shit
	Luck = 0,
	CashMulti = 0,

	Gamepasses = {
		VIP = false,
		["x2 Money"] = false,
		["x2 Luck"] = false,
		["+2 Slots"] = false,
		["Banhammer"] = false,
		["Starter Pack"] = false,
		["Ultimate Pack"] = false,
	},

	Backpack = {},
	Labubus = {},

	Index = {},

	ExtraSlots = {},

	ClaimedFreeReward = false,

	ForeverPack = {},
	LastForeverPackReset = 0,
} :: Types.UserData
