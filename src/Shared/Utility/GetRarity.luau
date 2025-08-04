local Types = require("@Shared/Types")

local function GetRarity(
	Array: { [string | any]: number | { SpawnChance: number } | Types.CrateConfig },
	RareChances: { string }?,
	Luck: number?
): string?
	Luck = Luck or 1
	if not Luck then
		return
	end

	local AdjustedChances: { [string]: number } = {}
	for Name, Value: number | { SpawnChance: number } in Array do
		if typeof(Value) == "number" then
			AdjustedChances[Name] = Value
		elseif typeof(Value) == "table" then
			if Value.SpawnChance then
				AdjustedChances[Name] = Value.SpawnChance
			end
		end
	end

	if RareChances then
		for _, _Name in RareChances do
			if AdjustedChances[_Name] then
				AdjustedChances[_Name] = AdjustedChances[_Name] * Luck
			end
		end
	end

	local AdjustedSum = 0
	for _, value in AdjustedChances do
		AdjustedSum += value
	end

	local RandomNumber = math.random(AdjustedSum)
	for Name, Value in AdjustedChances do
		if RandomNumber <= Value then
			return Name
		else
			RandomNumber -= Value
		end
	end

	return
end

return GetRarity
