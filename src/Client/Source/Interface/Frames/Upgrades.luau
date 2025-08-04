-- // Services
local Players = game:GetService("Players")

-- // Player
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- // Util
local Button = require("@ClientUtility/Button")

-- // Module
local InterfaceController = require("@Controllers/InterfaceController")

local Types = require("@Shared/Types")

local ToolData = require("@Config/Tools")
local UpgradeData = require("@Config/Upgrades")

local Remotes = require("@Shared/Remotes")

-- // Packages
local Replica = require("@Packages/Replica") :: any

-- // UI
local MainUI = PlayerGui:WaitForChild("UI")

local UpgradesFrame = MainUI:WaitForChild("Frames"):WaitForChild("Upgrades")

local CloseButton = UpgradesFrame:WaitForChild("Close")

type UpgradeFrame = Frame & {
	Sell: TextButton & { -- button to upgrade the ui naming is shity i know
		name: TextLabel,
	},
	after: TextLabel | ImageLabel, -- after you upgrade value
	before: TextLabel | ImageLabel, -- current value
	level: TextLabel, -- current upgrade lvl
	ImageLabel: ImageLabel, -- image
}

local MainFrame = UpgradesFrame:WaitForChild("Main") :: Frame & { UpgradeFrame }

-- // var
local PlayerUpgradeData = {}

-- // Init
local Upgrades = {}

function Upgrades.Init()
	Upgrades.Junk = {} :: { RBXScriptConnection | () -> () }

	Replica.OnNew("PlayerData", function(_replica)
		_replica:OnSet({ "Upgrades" }, function(new_value)
			if new_value == PlayerUpgradeData then
				return
			end
			PlayerUpgradeData = new_value
			Upgrades:Update()
		end)
	end)
end

function Upgrades:Start()
	table.insert(
		self.Junk,
		Button(CloseButton, function()
			InterfaceController:CloseAllFrames()
		end)
	)

	self:SetupButtonConnections()
end

function Upgrades:SetupButtonConnections()
	for _, Obj: Instance in MainFrame:GetChildren() do
		if Obj:IsA("Frame") then
			local Frame = Obj :: UpgradeFrame

			table.insert(
				self.Junk,
				Button(Frame.Sell, function()
					if Frame.Sell.name.Text == "MAX" then
						return
					end

					Remotes.PurchaseUpgrade:fire(Frame.Name)
				end)
			)
		end
	end
end

function Upgrades:Update()
	for Name, NewValue in PlayerUpgradeData do
		if typeof(Name) == "string" and typeof(NewValue) == "number" then
			local Frame = MainFrame:FindFirstChild(Name) :: UpgradeFrame

			if Frame then
				local NextValue: Types.ToolInfo | Types.UpgradeInfo<number> | nil
				local CurrentValue: Types.ToolInfo | Types.UpgradeInfo<number> | nil
				if Name == "Tool" then
					NextValue = ToolData[NewValue + 1] :: Types.ToolInfo?
					CurrentValue = ToolData[NewValue] :: Types.ToolInfo?
				else
					NextValue = UpgradeData[Name][NewValue + 1] :: Types.UpgradeInfo<number>?
					CurrentValue = UpgradeData[Name][NewValue] :: Types.UpgradeInfo<number>?
				end

				if NextValue then
					if Frame.after:IsA("ImageLabel") then -- its a tool
						local _NextValue = NextValue :: Types.ToolInfo

						if _NextValue.Gamepass then
							Frame.Sell.name.Text = "MAX"

							return
						end

						Frame.after.Image = _NextValue.Image
					else -- its a diff upgrade
						local _NextValue = NextValue :: Types.UpgradeInfo<number>
						Frame.after.Text = "x" .. tostring(_NextValue.NewValue)
					end

					if Frame.before:IsA("ImageLabel") then -- its a tool
						local _CurrentValue = CurrentValue :: Types.ToolInfo
						Frame.before.Image = _CurrentValue.Image or ""
					else -- its a diff upgrade
						if CurrentValue then
							local _CurrentValue = CurrentValue :: Types.UpgradeInfo<number>
							Frame.before.Text = "x" .. tostring(_CurrentValue.NewValue)
						end
					end

					Frame.Sell.name.Text = "$" .. tostring(NextValue.Price)
					Frame.level.Text = "LEVEL " .. tostring(NewValue)
				else
					Frame.level.Text = "LEVEL " .. tostring(NewValue)
					Frame.Sell.name.Text = "MAX"

					if Frame.after:IsA("TextLabel") then
						Frame.after.Text = "MAX"
					end

					if Frame.before:IsA("TextLabel") then
						local _CurrentValue = CurrentValue :: Types.UpgradeInfo<number>
						Frame.before.Text = "x" .. tostring(_CurrentValue.NewValue)
					end
				end
			end
		end
	end
end

function Upgrades:Stop()
	for _, Connection in self.Junk do
		if typeof(Connection) == "RBXScriptConnection" then
			if Connection.Connected then
				Connection:Disconnect()
			end
		elseif typeof(Connection) == "function" then
			Connection()
		end
	end

	table.clear(self.Junk)
end

return Upgrades
