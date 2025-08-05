-- // Services
local Players = game:GetService("Players")
local SoundService = game:GetService("SoundService")

-- // plr
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- // Packages
local Replica = require("@Packages/Replica") :: any

-- // Util
local Button = require("@ClientUtility/Button")

-- // sound
local SellSound = SoundService:WaitForChild("Sell")

-- // Module
local InterfaceController = require("@Controllers/InterfaceController")

local GetLabubuImage = require("@Utility/GetLabubuImage")
local GetLabubuInfo = require("@Utility/GetLabubuInfo")

local Remotes = require("@Shared/Remotes")

-- // UI
local MainUI = PlayerGui:WaitForChild("UI")
local SellFrame = MainUI:WaitForChild("Frames"):WaitForChild("Sell")

local CloseButton = SellFrame:WaitForChild("Close") :: TextButton

local SellAllButton = SellFrame:WaitForChild("SellAll") :: TextButton

local InventoryValue = SellFrame:WaitForChild("InventoryValue") :: TextLabel

type SellTemplate = Frame & {
	amount: TextLabel,
	name: TextLabel,
	price: TextLabel,
	Icon: ImageLabel,
	Sell: TextButton,
}
local MainHolder = SellFrame:WaitForChild("Main") :: ScrollingFrame
local SellTemplate = MainHolder:WaitForChild("SellTemplate") :: SellTemplate

-- // Vars
local PlayerBackpack = {}

-- // Init
local Sell = {}

function Sell.Init()
	Sell.Junk = {} :: { RBXScriptConnection | () -> () }

	-- // Data
	Replica.OnNew("PlayerData", function(_replica)
		_replica:OnSet({ "Backpack" }, function(new_value: { [string]: number })
			if new_value == PlayerBackpack then
				return
			end
			PlayerBackpack = new_value
			Sell:Update()
		end)
	end)
end

function Sell:Start()
	table.insert(
		self.Junk,
		Button(CloseButton, function()
			InterfaceController:CloseAllFrames()
		end)
	)

	table.insert(
		self.Junk,
		Button(SellAllButton, function()
			if #PlayerBackpack > 0 then
				Remotes.SellAllLabubus:fire()
				SoundService:PlayLocalSound(SellSound)
			end
		end)
	)
end

function Sell:Clear()
	for _, Item in MainHolder:GetChildren() do
		if Item.Name == "SellTemplate" then
			continue
		elseif Item:IsA("Frame") then
			Item:Destroy()
		end
	end
end

function Sell:UpdateInventoryValue()
	local TotalCost = 0
	for _, Labubu in PlayerBackpack do
		if typeof(Labubu) == "string" then
			local _, LabubuInfo = GetLabubuInfo(Labubu)
			if LabubuInfo then
				TotalCost += LabubuInfo.SellPrice
			end
		end
	end
	InventoryValue.Text = `${TotalCost}`
end

function Sell:Update()
	self:Clear()
	self:UpdateInventoryValue()
	for _, Item in PlayerBackpack do
		if typeof(Item) == "string" then
			Item = Item :: string

			local ExistingFrame = MainHolder:FindFirstChild(Item) :: SellTemplate
			if ExistingFrame then
				local FixedString = string.gsub(ExistingFrame.amount.Text, "x", "")
				if FixedString then
					local Amount = tonumber(FixedString)
					if Amount and typeof(Amount) == "number" then
						Amount += 1
						ExistingFrame.amount.Text = `x{Amount}`
					end
				end
			else
				local Clone = SellTemplate:Clone()
				Clone.Name = Item
				Clone.name.Text = Item
				Clone.Visible = true

				local Image = GetLabubuImage(Item)
				if Image then
					Clone.Icon.Image = Image
				end

				local _, Info = GetLabubuInfo(Item)
				if Info then
					Clone.price.Text = "$" .. Info.SellPrice
				end

				Clone.Parent = MainHolder

				Button(Clone.Sell, function()
					Remotes.SellLabubu:fire(Item)
					SoundService:PlayLocalSound(SellSound)
				end)
			end
		end
	end
end

function Sell:Stop()
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

return Sell
