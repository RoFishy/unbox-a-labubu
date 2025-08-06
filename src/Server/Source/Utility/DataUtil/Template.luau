local Types = require("@Shared/Types")

return {
	Cash = 0,
	LastJoin = nil,

	Upgrades = {
		Cash = 1,
		Luck = 1,
		Tool = 1,
	},

	-- gamepass shit
	Luck = 1,
	CashMulti = 1,

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
} :: Types.UserData
