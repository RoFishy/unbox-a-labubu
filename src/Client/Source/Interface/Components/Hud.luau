-- // Services
local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SocialService = game:GetService("SocialService")

-- // Player
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- // Modules/Utils
local Button = require("@ClientUtility/Button")

local GetPlayerPlot = require("@Utility/GetPlayerPlot")

local CashLabel = require("@Interface/Components/CashLabel")

local TimeUtils = require("@Utility/Time")

local Passes = require("@Config/Passes")

-- // luck
local CurrentLuck = ReplicatedStorage:WaitForChild("Luck"):WaitForChild("LuckAmount") :: IntValue
local LuckTime = ReplicatedStorage:WaitForChild("Luck"):WaitForChild("LuckTime") :: IntValue

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

local ServerluckLabel = Hud:WaitForChild("ServerLuck") :: TextLabel

-- // Start
return function(props: {
	OpenFrame: (FrameName: string) -> (),
})
	CashLabel()

	LuckTime:GetPropertyChangedSignal("Value"):Connect(function()
		if LuckTime.Value > 0 then
			ServerluckLabel.Visible = true
			ServerluckLabel.Text = `{CurrentLuck.Value}x Server Luck: {TimeUtils.FormatMS(LuckTime.Value)}`
		else
			ServerluckLabel.Visible = false
		end
	end)

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

			if button.Name == "Invite" then
				Button(button, function()
					if SocialService:CanSendGameInviteAsync(LocalPlayer) then
						SocialService:PromptGameInvite(LocalPlayer)
					end
				end)
			else
				Button(button, function()
					props.OpenFrame(button.Name)
				end)
			end
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

	if not MarketplaceService:UserOwnsGamePassAsync(LocalPlayer.UserId, Passes["Starter Pack"]) then
		local PackTimer = StarterPack:WaitForChild("Timer") :: TextLabel
		task.spawn(function()
			for i = 60 * 29, 0, -1 do
				PackTimer.Text = TimeUtils.FormatMS(i)
				task.wait(1)
			end

			StarterPack.Visible = false
		end)
		Button(StarterPack, function()
			props.OpenFrame("Shop")
		end)
	else
		StarterPack.Visible = false
	end
end
