local ForeverPack = {}

ForeverPack.Rewards = {
	[1] = {
		Image = "rbxassetid://81389192039217",
		Chance = 30,
		Text = "$500",
		ClaimFunction = function(Player)
			local DataUtil = require("@ServerUtility/DataUtil")

			local Data = DataUtil:GetData(Player)

			if Data then
				Data = table.clone(Data)
				Data.Cash += 500
				DataUtil:SetData(Player, Data)
			end
		end,
	},
}

ForeverPack.PriceGap = {
	[5] = 3349324735,
	[10] = 3349324953,
	[15] = 3349325130,
	[20] = 3349325279,
	[25] = 3349325427,
}

ForeverPack.GetPriceFromIndex = function(Index: number): string | number
	if Index % 3 ~= 0 then
		return "Free"
	else
		return ForeverPack.PriceGap[Index] and ForeverPack.PriceGap[Index] or ForeverPack.PriceGap[25]
	end
end

ForeverPack.GetNextIndex = function(ForeverPackTable)
	local NextTableIndex = nil

	for index in pairs(ForeverPackTable) do
		local numIndex = tonumber(index)
		if numIndex then
			if not NextTableIndex or numIndex < NextTableIndex then
				NextTableIndex = numIndex
			end
		end
	end

	return NextTableIndex
end

ForeverPack.PickRandomRewardIndex = function(): number?
	local total = 0
	for _, r in ipairs(ForeverPack.Rewards) do
		total = total + r.Chance
	end
	local roll = math.random() * total
	local acc = 0
	for i, r in ipairs(ForeverPack.Rewards) do
		acc = acc + r.Chance
		if roll <= acc then
			return i
		end
	end
	return
end

return ForeverPack
