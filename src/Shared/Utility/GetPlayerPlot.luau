local PlotsFolder = workspace.Plots

local function GetPlayerPlot(Player: Player): Instance?
	for _, Plot in PlotsFolder:GetChildren() do
		if Plot:GetAttribute("Owner") and Plot:GetAttribute("Owner") == Player.Name then
			return Plot
		end
	end

	return
end

return GetPlayerPlot
