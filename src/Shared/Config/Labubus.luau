local Types = require("@Shared/Types")

return {
	["Common"] = {
		Labubus = {
			["Lychee Berry"] = {
				Income = 1,
				SellPrice = 5,
			},
			["Soy Milk"] = {
				Income = 2,
				SellPrice = 10,
			},
			["Noob"] = {
				Income = 3,
				SellPrice = 15,
			},
			["Sesame Bean"] = {
				Income = 4,
				SellPrice = 20,
			},
		},
	},
	["Uncommon"] = {
		Labubus = {

			["Chef"] = {
				Income = 5,
				SellPrice = 30,
			},
			["Toffee Candy"] = {
				Income = 7,
				SellPrice = 50,
			},
			["Chill"] = {
				Income = 10,
				SellPrice = 80,
			},
		},
	},
	["Rare"] = {
		Labubus = {
			["Astronaut"] = {
				Income = 15,
				SellPrice = 130,
			},
			["Love"] = {
				Income = 25,
				SellPrice = 250,
			},
			["Sea Salt Coconut"] = {
				Income = 35,
				SellPrice = 500,
			},
		},
	},
	["Epic"] = {
		Labubus = {
			["Green Grape"] = {
				Income = 50,
				SellPrice = 650,
			},
			["Ninja"] = {
				Income = 75,
				SellPrice = 900,
			},
			["Chestnut Cocoa"] = {
				Income = 100,
				SellPrice = 1200,
			},
		},
	},
	["Legendary"] = {
		Labubus = {
			["Viking"] = {
				Income = 125,
				SellPrice = 1750,
			},
			["Beach"] = {
				Income = 150,
				SellPrice = 2250,
			},
			["Squid"] = {
				Income = 200,
				SellPrice = 3000,
			},
		},
	},
	["Divine"] = {
		Labubus = {
			["Angel"] = {
				Income = 300,
				SellPrice = 5000,
			},
			["Loyalty"] = {
				Income = 450,
				SellPrice = 8000,
			},
		},
	},
	["Secret"] = {
		Labubus = {
			["King"] = {
				Income = 750,
				SellPrice = 15000,
			},
			["Secret"] = {
				Income = 1500,
				SellPrice = 40000,
			},
		},
	},
} :: { [Types.Rarity]: Types.LabubuRarityInfo }
