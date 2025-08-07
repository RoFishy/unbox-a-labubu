-- // services
local Players = game:GetService("Players")

-- // plr
local LocalPlayer = Players.LocalPlayer

-- // obj
local PlotsFolder = workspace:WaitForChild("Plots")

-- // modules
local Remotes = require("@Shared/Remotes")

-- // init
local PlotController = {}

function PlotController:Start()
	Remotes.SetupPlotDisplay:connect(function(Plot: string)
		local PlotModel = PlotsFolder:FindFirstChild(Plot)

		if PlotModel then
			local DisplayFrame = PlotModel:WaitForChild("Components")
				:WaitForChild("Display")
				:WaitForChild("Attachment")
				:WaitForChild("Billboard")
				:WaitForChild("Frame")

			local Thumnail = Players:GetUserThumbnailAsync(
				LocalPlayer.UserId,
				Enum.ThumbnailType.HeadShot,
				Enum.ThumbnailSize.Size420x420
			)

			local Image = DisplayFrame:WaitForChild("ImageLabel") :: ImageLabel
			Image.Image = Thumnail
		end

		for _, Model in PlotsFolder:GetChildren() do
			if Model.Name == Plot then
				continue
			end

			local DisplayFrame = Model:WaitForChild("Components")
				:WaitForChild("Display")
				:WaitForChild("Attachment")
				:WaitForChild("Billboard") :: BillboardGui

			DisplayFrame.Enabled = false
		end
	end)
end

return PlotController
