-- // Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

-- // Player
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

local Camera = workspace.CurrentCamera

-- // Start
local UIStrokes = {}

local function SetupUIStrokes()
	for _, Object in PlayerGui:GetDescendants() do
		if Object:IsA("UIStroke") then
			table.insert(UIStrokes, Object)
		end
	end
end

local function HandleUIStroke()
	for _, UIStroke in UIStrokes do
		if not UIStroke:GetAttribute("DefaultThickness") then
			UIStroke:SetAttribute("DefaultThickness", UIStroke.Thickness)
		end
		local Thickness = UIStroke:GetAttribute("DefaultThickness")

		UIStroke.Thickness = Camera.ViewportSize.Magnitude / 1800 * Thickness
	end
end

return function()
	SetupUIStrokes()

	PlayerGui.DescendantAdded:Connect(function(Child)
		if Child:IsA("UIStroke") then
			table.insert(UIStrokes, Child)
		end
	end)

	HandleUIStroke()
	RunService.RenderStepped:Connect(HandleUIStroke)
end
