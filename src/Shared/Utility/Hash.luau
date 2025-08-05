return function(str: string): number
	local hash = 2166136261

	for i = 1, #str do
		local c = str:sub(i, i)
		local byte = string.byte(c)
		hash = bit32.bxor(hash, byte)
		hash = (hash * 16777619) % 2 ^ 32
	end

	return hash
end
