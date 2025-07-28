-- // Services
local Players = game:GetService("Players")

-- // Player
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- // Modules/Utils
local Button = require("@ClientUtility/Button")

local GetPlayerPlot = require("@Utility/GetPlayerPlot")

-- // obj
local Teleports = workspace.Teleports :: Folder & { Part }

-- // UI Shit
local MainUI = PlayerGui:WaitForChild("UI") :: ScreenGui
local Hud = MainUI:WaitForChild("Hud") :: Frame

-- hud
local LeftButtons = Hud:WaitForChild("Left") :: Frame
local RightButtons = Hud:WaitForChild("Right") :: Frame
local TopButtons = Hud:WaitForChild("Top") :: Frame

local StarterPack = Hud:WaitForChild("StarterPack") :: TextButton

-- // Start
return function(props: {
	OpenFrame: (FrameName: string) -> (),
})
	for _, Instance in LeftButtons:GetChildren() do
		if Instance:IsA("TextButton") or Instance:IsA("ImageButton") then
			local button: TextButton | ImageButton = Instance

			Button(button, function()
				props.OpenFrame(button.Name)
			end)
		end
	end

	for _, Instance in RightButtons:GetChildren() do
		if Instance:IsA("TextButton") or Instance:IsA("ImageButton") then
			local button: TextButton | ImageButton = Instance

			Button(button, function()
				props.OpenFrame(button.Name)
			end)
		end
	end

	for _, Instance in TopButtons:GetChildren() do
		if Instance:IsA("TextButton") or Instance:IsA("ImageButton") then
			local button: TextButton | ImageButton = Instance

			Button(button, function()
				local Teleport = Teleports:FindFirstChild(Instance.Name) :: Part
				local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()

				if Teleport then
					Character:PivotTo(Teleport:GetPivot())
				else
					local PlayerPlot = GetPlayerPlot(LocalPlayer)
					if PlayerPlot then
						local Components = PlayerPlot:FindFirstChild("Components") :: Folder
						if Components then
							local TeleportPart = Components:WaitForChild("Teleport") :: Part
							Character:PivotTo(TeleportPart:GetPivot())
						end
					end
				end
			end)
		end
	end

	Button(StarterPack)
end
