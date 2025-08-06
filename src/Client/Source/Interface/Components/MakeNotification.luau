-- // Services
local Players = game:GetService("Players")
local SoundService = game:GetService("SoundService")
local TweenService = game:GetService("TweenService")

-- // Player
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- // UI
local MainUI = PlayerGui:WaitForChild("UI") :: ScreenGui
local MiscUI = MainUI:WaitForChild("Misc") :: Frame

local NotificationHolder = MiscUI:WaitForChild("NotificationHolder") :: Frame
local NotificationTemplate = NotificationHolder:WaitForChild("NotificationTemplate") :: TextLabel

return function(Text: string, Color: Color3?, Sound: string?)
	if Sound then
		Sound = SoundService:FindFirstChild(Sound)
		if Sound and not LocalPlayer:GetAttribute("MuteSounds") then
			SoundService:PlayLocalSound(Sound)
		end
	end

	for _, Notification in NotificationHolder:GetChildren() do
		if Notification:IsA("TextLabel") then
			if Notification.Text == Text or string.find(Notification.Text, Text) then
				local CurrentIndex = tonumber(Notification.Name) :: number
				CurrentIndex += 1
				Notification.Text = `{Text} ({CurrentIndex})`
				Notification.Name = tostring(CurrentIndex)
				return
			end
		end
	end

	local NotificationClone: TextLabel = NotificationTemplate:Clone()
	NotificationClone.Parent = NotificationHolder
	NotificationClone.Text = Text
	NotificationClone.Visible = true
	NotificationClone.TextColor3 = Color or Color3.fromRGB(255, 255, 255)
	NotificationClone.Name = "0"

	local Scale = NotificationClone:WaitForChild("UIScale")
	TweenService:Create(Scale, TweenInfo.new(0.1), { Scale = 1 }):Play()

	task.delay(5, function()
		TweenService:Create(Scale, TweenInfo.new(0.2), { Scale = 0 }):Play()
		task.wait(0.2)
		NotificationClone:Destroy()
	end)
end
