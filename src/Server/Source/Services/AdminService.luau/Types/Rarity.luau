return function(registry)
	registry:RegisterType(
		"rarity",
		registry.Cmdr.Util.MakeEnumType(
			"Rarity",
			{ "Uncommon", "Common", "Rare", "Epic", "Legendary", "Divine", "Secret" }
		)
	)
end
