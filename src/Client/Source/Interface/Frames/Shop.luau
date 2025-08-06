-- // Services
local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")

-- // Player
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- // Util
local Button = require("@ClientUtility/Button")

-- // Module
local InterfaceController = require("@Controllers/InterfaceController")

local PassesModule = require("@Config/Passes")

-- // UI
local MainUI = PlayerGui:WaitForChild("UI")

local ShopFrame = MainUI:WaitForChild("Frames"):WaitForChild("Shop")
local MainFrame = ShopFrame:WaitForChild("Main"):WaitForChild("Main")

local CloseButton = ShopFrame:WaitForChild("Close")

local Packs = MainFrame:WaitForChild("Packs") :: Frame
local Passes = MainFrame:WaitForChild("Passes") :: Frame

type PurchaseFrame = Frame & {
	Buy: TextButton,
}

-- // Init
local Shop = {}

function Shop.Init()
	Shop.Junk = {} :: { RBXScriptConnection | () -> () }
end

function Shop:Start()
	table.insert(
		self.Junk,
		Button(CloseButton, function()
			InterfaceController:CloseAllFrames()
		end)
	)

	-- packs
	for _, obj in Packs:GetChildren() do
		if obj:IsA("Frame") then
			local Pack = obj :: PurchaseFrame
			table.insert(
				self.Junk,
				Button(Pack.Buy, function()
					MarketplaceService:PromptGamePassPurchase(LocalPlayer, PassesModule[obj.Name .. " Pack"])
				end)
			)
		end
	end

	-- passes
	for _, obj in Passes:GetChildren() do
		if obj:IsA("Frame") then
			local Pass = obj :: PurchaseFrame
			table.insert(
				self.Junk,
				Button(Pass.Buy, function()
					MarketplaceService:PromptGamePassPurchase(LocalPlayer, PassesModule[Pass.Name])
				end)
			)
		end
	end
end

function Shop:Stop()
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

return Shop
