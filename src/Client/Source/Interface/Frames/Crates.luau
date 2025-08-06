-- // Services
local MarketplaceService = game:GetService("MarketplaceService")
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

local Time = require("@Utility/Time")

local FormatNumber = require("@Utility/FormatNumber")

local CrateData = require("@Config/Crates")

local Remotes = require("@Shared/Remotes")

-- // UI
local MainUI = PlayerGui:WaitForChild("UI")

local CratesFrame = MainUI:WaitForChild("Frames"):WaitForChild("Crates")

local MainHolder = CratesFrame:WaitForChild("Main")

local RestockLabel = CratesFrame:WaitForChild("inventory") :: TextLabel -- dont talk to me about these shitty ass names man

type CrateFrame = Frame & {
	Rarity: TextButton & {
		name: TextLabel,
	},
	name: TextLabel,
	stock: TextLabel,
	price: TextLabel,
	Frame: Frame & {
		ImageLabel: ImageLabel,
	},
	Button: TextButton,
}
local TemplateFrame = MainHolder:WaitForChild("Buy") :: CrateFrame

type CrateDropdown = Frame & {
	Buy: TextButton & {
		name: TextLabel,
	},
	BuyRbx: TextButton & {
		name: TextLabel,
	},
}
local TemplateDropdown = MainHolder:WaitForChild("BuyDropdown") :: CrateDropdown

-- // var
local CurrentCrateShopData = {}
local OpenedCrateFrames = {}

-- // local func
local function GetPrice(ProductId: number): number?
	local success, result = pcall(function()
		return MarketplaceService:GetProductInfo(ProductId, Enum.InfoType.Product)
	end)

	if success then
		return result.PriceInRobux
	else
		return warn(result)
	end
end

-- // Init
local Crates = {}

function Crates.Init()
	Crates.Junk = {}

	Replica.OnNew("Stock", function(_replica)
		_replica:OnSet({ "RestockTime" }, function(new_value)
			RestockLabel.Text = Time.FormatMS(new_value)
		end)
	end)
	Replica.OnNew("PlayerStock", function(_replica)
		_replica:OnSet({ "CrateStock" }, function(new_value)
			if new_value == CurrentCrateShopData then
				return
			end
			CurrentCrateShopData = new_value
			Crates:UpdateShop()
		end)
	end)
end

function Crates:Start()
	table.insert(
		self.Junk,
		Button(CratesFrame:WaitForChild("Close"), function()
			InterfaceController:CloseAllFrames()
		end)
	)
end

function Crates:UpdateShop()
	for _, Frame in MainHolder:GetChildren() do
		if Frame:IsA("Frame") then
			if Frame.Name == "Buy" or Frame.Name == "BuyDropdown" then
				continue
			end
			Frame:Destroy()
		end
	end

	for Name, Stock in CurrentCrateShopData do
		if typeof(Name) == "string" and typeof(Stock) == "number" then
			local Clone = TemplateFrame:Clone()
			Clone.Name = Name
			Clone.stock.Text = `x{Stock} Stock`
			Clone.name.Text = Name
			Clone.Parent = MainHolder
			Clone.Visible = true

			local DropdownClone = TemplateDropdown:Clone()
			DropdownClone.Name = `{Name}_Dropdown`
			DropdownClone.Parent = MainHolder
			DropdownClone.Visible = if table.find(OpenedCrateFrames, Name) then true else false

			local Data = CrateData[Name]
			if Data then
				Clone.price.Text = `${FormatNumber.Comma(Data.Price)}`
				DropdownClone.Buy.name.Text = `${FormatNumber.Comma(Data.Price)}`

				Clone.LayoutOrder = Data.LayoutOrder
				DropdownClone.LayoutOrder = Data.LayoutOrder + 1

				local RobuxPrice = GetPrice(Data.Product)
				if RobuxPrice then
					DropdownClone.BuyRbx.name.Text = ` {RobuxPrice}`
				end

				Clone.Frame.ImageLabel.Image = Data.Image

				Clone.Button.MouseButton1Click:Connect(function()
					DropdownClone.Visible = not DropdownClone.Visible

					if DropdownClone.Visible then
						table.insert(OpenedCrateFrames, Name)
					else
						table.remove(OpenedCrateFrames, table.find(OpenedCrateFrames, Name))
					end
				end)

				Button(DropdownClone.BuyRbx, function()
					MarketplaceService:PromptProductPurchase(LocalPlayer, Data.Product)
				end)

				Button(DropdownClone.Buy, function()
					Remotes.PurchaseCrate:fire(Name)
				end)
			end
		end
	end
end

function Crates:Stop()
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

return Crates
