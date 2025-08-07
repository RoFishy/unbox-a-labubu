local Cache = require("@ServerUtility/Cache")
return function(_, Players: { Player }, Crate: string)
	for _, Player in Players do
		if Cache.PlayerCrates[Player] then
			table.insert(Cache.PlayerCrates[Player], Crate .. " Crate")
		else
			Cache.PlayerCrates[Player] = { Crate .. " Crate" }
		end
	end
	return "Set their next crate"
end
