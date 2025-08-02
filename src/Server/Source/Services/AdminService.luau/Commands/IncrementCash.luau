return {
	Name = "incrementCash",
	Aliases = {},
	Description = "Increment a player's cash",
	Args = {
		{
			Type = "players",
			Name = "player",
			Description = "The player to increment cash of",
		},
		{
			Type = "number",
			Name = "cash",
			Description = "The amount of cash to increment",
		},
	},
}
