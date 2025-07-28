-- // Services
local Players = game:GetService("Players")

-- // plr
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- // Packages
local Replica = require("@Packages/Replica") :: any

-- // Util
local Button = require("@ClientUtility/Button")

-- // Module
local InterfaceController = require("@Controllers/InterfaceController")

local GetLabubuInfo = require("@Utility/GetLabubuInfo")

-- // UI
local MainUI = PlayerGui:WaitForChild("UI")
local IndexFrame = MainUI:WaitForChild("Frames"):WaitForChild("Index")

local CloseButton = IndexFrame:WaitForChild("Close") :: TextButton

local Collected = IndexFrame:WaitForChild("Collected") :: TextLabel

local NormalHolder = IndexFrame:WaitForChild("Normal") :: ScrollingFrame

-- // Vars
local PlayerLabubuIndex = {}

-- // Start
local Index = {}

function Index.Init()
	Index.Junk = {}

	-- // Data
	Replica.OnNew("PlayerData", function(_replica)
		_replica:OnSet({ "Index" }, function(new_value)
			PlayerLabubuIndex = new_value
			Index:SetMemes()
		end)
	end)

	Replica.RequestData()
end

function Index:Start()
	table.insert(
		self.Junk,
		Button(CloseButton, function()
			InterfaceController:CloseAllFrames()
		end)
	)
end

function Index:SetMemes()
	local TotalCollected = 0
	for _, Frame in NormalHolder:GetChildren() do
		if not Frame:IsA("TextButton") then
			continue
		end

		local Image = Frame:WaitForChild("ImageLabel") :: ImageLabel
		local Name = Frame:WaitForChild("Name") :: TextLabel
		local Amount = Frame:WaitForChild("Amount") :: TextLabel

		local _, Info = GetLabubuInfo(Frame.Name)
		if table.find(PlayerLabubuIndex, Frame.Name) then
			Image.ImageColor3 = Color3.fromRGB(255, 255, 255)
			Name.Text = Frame.Name
			if Info then
				Amount.Text = `${Info.SellPrice}/s`
			end

			TotalCollected += 1
		else
			Image.ImageColor3 = Color3.fromRGB(0, 0, 0)
			Name.Text = "???"
			Amount.Text = "???"
		end
	end

	Collected.Text = `{TotalCollected}/20 Discovered`
end

function Index:Stop()
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

return Index
