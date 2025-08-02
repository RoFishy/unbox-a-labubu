-- // Services
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")

-- // lplr
local LocalPlayer = Players.LocalPlayer

-- // Player
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- // mod
local ButtonUtil = require("@ClientUtility/Button")
local Signals = require("@ClientUtility/Signals")
local Types = require("@Shared/Types")

-- // ui
local MainUI = PlayerGui:WaitForChild("UI") :: ScreenGui
local MiscUI = MainUI:WaitForChild("Misc") :: Frame
local DialogueList = MiscUI:WaitForChild("DialogueList") :: Frame
local DialogueOptionTemplate = MiscUI:WaitForChild("DialogueOptionTemplate") :: Frame

-- // init
return function()
	local function NPCDialogueHandler(Option: Types.DialogueOption)
		for _, OptionFrame in DialogueList:GetChildren() do
			if not OptionFrame:IsA("Frame") then
				continue
			end
			OptionFrame:Destroy()
		end
		if Option.Callback then
			Option.Callback()
		end
		Signals.NPCInteractionEnded:Fire()
	end

	Signals.ToggleNPCDialogue:Connect(function(Dialogue: Types.NPCDialogueOptions)
		for Number, Option in Dialogue do
			local OptionFrame = DialogueOptionTemplate:Clone()
			OptionFrame.Visible = true
			OptionFrame.Parent = DialogueList

			local Text = OptionFrame:WaitForChild("Text") :: TextLabel
			Text.Text = Option.Option

			local NumberLabel = OptionFrame:WaitForChild("Number") :: TextLabel
			NumberLabel.Text = tostring(Number)

			local Button = OptionFrame:WaitForChild("Button") :: TextButton
			ButtonUtil(Button, function()
				NPCDialogueHandler(Option)
			end)

			local UIScale = OptionFrame:WaitForChild("UIScale") :: UIScale
			UIScale.Scale = 0
			local Tween = TweenService:Create(UIScale, TweenInfo.new(0.2), { Scale = 1 })
			Tween:Play()
			Tween.Completed:Wait()
		end
	end)
end
