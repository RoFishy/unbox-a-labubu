local GetLabubuInfo = require("@Utility/GetLabubuInfo")
local GetPlayerPlot = require("@Utility/GetPlayerPlot")

local function CalculateEarningsByTime(Player: Player, Time: number): number
	local Plot = GetPlayerPlot(Player)
	if Plot then
		local Slots = Plot:WaitForChild("Components"):WaitForChild("Slots")
		if Slots then
			local Earnings = 0
			for _, Slot in Slots:GetChildren() do
				if Slot:GetAttribute("Labubu") then
					local Labubuname = Slot:GetAttribute("Labubu") :: string
					local _, Info = GetLabubuInfo(Labubuname)
					if Info then
						Earnings += Info.Income
					end
				end
			end

			return math.floor(Earnings * Time)
		end
	end

	return 0
end

return CalculateEarningsByTime
