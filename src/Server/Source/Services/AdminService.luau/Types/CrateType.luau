return function(registry)
	registry:RegisterType(
		"crateType",
		registry.Cmdr.Util.MakeEnumType(
			"CrateType",
			{ "Wooden", "Iron", "Refined", "Arcane", "Royal", "Rune", "Solar", "Void", "Kraken", "GL!TCH" }
		)
	)
end
