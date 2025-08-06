-- // Services
local Lighting = game:GetService("Lighting")
local Players = game:GetService("Players")

-- // Player
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- // Util
local Button = require("@ClientUtility/Button")

-- // Module
local InterfaceController = require("@Controllers/InterfaceController")

-- // UI
local MainUI = PlayerGui:WaitForChild("UI")

local SettingsFrame = MainUI:WaitForChild("Frames"):WaitForChild("Settings")

local CloseButton = SettingsFrame:WaitForChild("Close")

local Config = SettingsFrame:WaitForChild("Configuration") :: Configuration
local OnGradient = Config:WaitForChild("On") :: UIGradient
local OffGradient = Config:WaitForChild("Off") :: UIGradient

type SettingFrame = Frame & {
	Claim: TextButton & {
		name: TextLabel,
	},
}

local SettingsHolder = SettingsFrame:WaitForChild("Main") :: Frame

local MusicFrame = SettingsHolder:WaitForChild("Music") :: SettingFrame
local QualityFrame = SettingsHolder:WaitForChild("QualityMode") :: SettingFrame
local SoundFrame = SettingsHolder:WaitForChild("Sound") :: SettingFrame

-- // conns
local SoundConnection: RBXScriptConnection
local QualityConnection: RBXScriptConnection

-- // Init
local Settings = {}

function Settings.Init()
	Settings.Junk = {} :: { RBXScriptConnection | () -> () }
end

function Settings:Start()
	table.insert(
		self.Junk,
		Button(CloseButton, function()
			InterfaceController:CloseAllFrames()
		end)
	)

	table.insert(
		self.Junk,
		Button(SoundFrame.Claim, function()
			if SoundConnection and SoundConnection.Connected then
				SoundConnection:Disconnect()
			end

			if SoundFrame.Claim.name.Text == "On" then
				SoundFrame.Claim.name.Text = "Off"
				local Gradient = SoundFrame.Claim:FindFirstChildOfClass("UIGradient")
				if Gradient then
					Gradient:Destroy()

					local NewGradient = OffGradient:Clone()
					NewGradient.Parent = SoundFrame.Claim

					SoundConnection = workspace.DescendantAdded:Connect(function(Child)
						if Child:IsA("Sound") then
							Child.Volume = 0
						end
					end)

					LocalPlayer:SetAttribute("MuteSounds", true)

					for _, Item in workspace:GetDescendants() do
						if Item:IsA("Sound") then
							Item.Volume = 0
						end
					end
				end
			else
				SoundFrame.Claim.name.Text = "On"
				local Gradient = SoundFrame.Claim:FindFirstChildOfClass("UIGradient")

				LocalPlayer:SetAttribute("MuteSounds", nil)

				if Gradient then
					Gradient:Destroy()

					local NewGradient = OnGradient:Clone()
					NewGradient.Parent = SoundFrame.Claim
				end
			end
		end)
	)

	table.insert(
		self.Junk,
		Button(MusicFrame.Claim, function()
			if MusicFrame.Claim.name.Text == "On" then
				MusicFrame.Claim.name.Text = "Off"
				local Gradient = MusicFrame.Claim:FindFirstChildOfClass("UIGradient")
				if Gradient then
					Gradient:Destroy()

					local NewGradient = OffGradient:Clone()
					NewGradient.Parent = MusicFrame.Claim
				end
			else
				MusicFrame.Claim.name.Text = "On"
				local Gradient = MusicFrame.Claim:FindFirstChildOfClass("UIGradient")
				if Gradient then
					Gradient:Destroy()

					local NewGradient = OnGradient:Clone()
					NewGradient.Parent = MusicFrame.Claim
				end
			end
		end)
	)

	table.insert(
		self.Junk,
		Button(QualityFrame.Claim, function()
			if QualityConnection and QualityConnection.Connected then
				QualityConnection:Disconnect()
			end

			if QualityFrame.Claim.name.Text == "On" then
				QualityFrame.Claim.name.Text = "Off"

				Lighting.GlobalShadows = true

				local Gradient = QualityFrame.Claim:FindFirstChildOfClass("UIGradient")
				if Gradient then
					Gradient:Destroy()

					local NewGradient = OffGradient:Clone()
					NewGradient.Parent = QualityFrame.Claim
				end
			else
				QualityFrame.Claim.name.Text = "On"

				Lighting.GlobalShadows = false

				QualityConnection = workspace.DescendantAdded:Connect(function(Child)
					if Child:IsA("ParticleEmitter") then
						Child.Enabled = false

						Child:GetPropertyChangedSignal("Enabled"):Connect(function()
							Child.Enabled = false
						end)
					end
				end)

				for _, Item in workspace:GetDescendants() do
					if Item:IsA("ParticleEmitter") then
						Item.Enabled = false

						Item:GetPropertyChangedSignal("Enabled"):Connect(function()
							Item.Enabled = false
						end)
					end
				end

				local Gradient = QualityFrame.Claim:FindFirstChildOfClass("UIGradient")
				if Gradient then
					Gradient:Destroy()

					local NewGradient = OnGradient:Clone()
					NewGradient.Parent = QualityFrame.Claim
				end
			end
		end)
	)
end

function Settings:Stop()
	for _, v in self.Junk do
		if typeof(v) == "RBXScriptConnection" then
			v:Disconnect()
		elseif typeof(v) == "function" then
			v()
		else
			v:Destroy()
		end
	end

	table.clear(self.Junk)
end

return Settings
