export type CrateConfig = {
	Health: number,

	SpawnChance: number,

	RestockChance: number,
	RestockMin: number,
	RestockMax: number,

	Product: number,
	Price: number,

	Image: string,

	LayoutOrder: number,

	Chances: { [Rarity]: number },
}

export type ToolInfo = {
	Damage: number,
	Price: number,
	Image: string,
	Gamepass: number?,
}

export type DialogueOption = {
	Option: string,
	Callback: () -> ()?,
}

export type NPCDialogueOptions = {
	[number]: DialogueOption,
}

export type UserData = {
	Cash: number,
	LastJoin: number?,

	Upgrades: {
		Cash: number,
		Luck: number,
		Tool: number,
	},

	Luck: number,
	CashMulti: number,

	Gamepasses: {
		VIP: boolean,
		["x2 Money"]: boolean,
		["x2 Luck"]: boolean,
		["+2 Slots"]: boolean,
		["Banhammer"]: boolean,
		["Starter Pack"]: boolean,
		["Ultimate Pack"]: boolean,
	},

	Labubus: { LabubuDataInfo },
	Backpack: { string },
	Index: { string },

	ExtraSlots: { number },

	ClaimedFreeReward: boolean,
}

export type UpgradeInfo<T> = {
	Price: number,
	NewValue: T,
}

export type Rarity = "Uncommon" | "Common" | "Rare" | "Epic" | "Legendary" | "Divine" | "Secret"

export type LabubuDataInfo = {
	Name: string,
	Slot: string,
}

export type LabubuInfo = {
	Income: number,
	SellPrice: number,
}

export type LabubuRarityInfo = {
	Color: Color3?,
	Labubus: { [string]: LabubuInfo },
}

export type PlotData = {
	Owner: Player?,
	Spawner: unknown?,
	CurrentCrate: unknown?,
}

return {}
