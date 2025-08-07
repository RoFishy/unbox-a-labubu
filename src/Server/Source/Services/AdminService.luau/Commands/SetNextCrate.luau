return {
	Name = "setNextCrate",
	Aliases = {},
	Description = "Set a player's next crate",
	Args = {
		{
			Type = "players",
			Name = "player",
			Description = "The player to set the crate of",
		},
		{
			Type = "crateType",
			Name = "crate",
			Description = "The crate to set",
		},
	},
}
