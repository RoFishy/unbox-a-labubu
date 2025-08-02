-- // Services
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")

-- // pkg
local Replica = require("@Packages/Replica") :: any

-- // Player
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- // UI
local MainUI = PlayerGui:WaitForChild("UI") :: ScreenGui
local Hud = MainUI:WaitForChild("Hud") :: Frame

local CashLabel = Hud:WaitForChild("cash") :: TextLabel
local Scale = CashLabel:WaitForChild("UIScale") :: UIScale

-- // Local Functions
local function FormatCash(Amount: number): any
	local formatted = Amount :: any
	while true do
		local k
		formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", "%1,%2")
		if k == 0 then
			break
		end
	end
	return formatted
end

-- // init
local currentCash: number = 0

return function()
	Replica.OnNew("PlayerData", function(_replica)
		_replica:OnSet({ "Cash" }, function(new_value: number)
			if new_value == currentCash then
				return
			end

			local OutTween = TweenService:Create(
				Scale,
				TweenInfo.new(0.1, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
				{ Scale = 1.2 }
			)

			OutTween:Play()
			OutTween.Completed:Connect(function()
				TweenService
					:Create(Scale, TweenInfo.new(0.1, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), { Scale = 1 })
					:Play()
			end)

			local i = 0
			while i < 1 do
				i = math.clamp(i + 0.1, 0, 1)
				local a = TweenService:GetValue(i, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
				local tweenInt = math.round(currentCash * (1 - a) + new_value * a)

				CashLabel.Text = "$" .. FormatCash(tweenInt)
				task.wait(0.05)
			end

			currentCash = new_value
		end)
	end)
end
