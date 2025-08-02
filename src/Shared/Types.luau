export type CrateConfig = {
	Health: number,

	Chances: { [Rarity]: number },
}

export type ToolInfo = {
	Damage: number,
	Price: number,
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
	Tool: number,

	Labubus: { LabubuDataInfo },
	Backpack: { string },
	Index: { string },

	ExtraSlots: { number },
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
