-- // Services
local Players = game:GetService("Players")

-- // Player
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- // Util
local Button = require("@ClientUtility/Button")

-- // Module
local InterfaceController = require("@Controllers/InterfaceController")

local Remotes = require("@Shared/Remotes")

-- // UI
local MainUI = PlayerGui:WaitForChild("UI")

local FreeFrame = MainUI:WaitForChild("Frames"):WaitForChild("Free")

local CloseButton = FreeFrame:WaitForChild("Close")

local ClaimButton = FreeFrame:WaitForChild("Claim")

-- // Init
local Free = {}

function Free.Init()
	Free.Junk = {} :: { RBXScriptConnection | () -> () }
end

function Free:Start()
	table.insert(
		self.Junk,
		Button(CloseButton, function()
			InterfaceController:CloseAllFrames()
		end)
	)

	table.insert(
		self.Junk,
		Button(ClaimButton, function()
			Remotes.ClaimFreeReward:fire()
		end)
	)
end

function Free:Stop()
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

return Free
