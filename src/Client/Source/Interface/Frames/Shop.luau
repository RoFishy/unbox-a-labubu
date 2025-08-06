-- // Services
local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- // Player
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- // Util
local Button = require("@ClientUtility/Button")

local CalculateEarningsByTime = require("@Utility/CalculateEarningsByTime")
local FormatNumber = require("@Utility/FormatNumber")

-- // Luck
local CurrentLuck = ReplicatedStorage:WaitForChild("Luck"):WaitForChild("LuckAmount") :: IntValue

-- // Module
local InterfaceController = require("@Controllers/InterfaceController")

local PassesModule = require("@Config/Passes")
local ProductsModule = require("@Config/Products")

local Replica = require("@Packages/Replica") :: any

local ForeverPack = require("@Config/ForeverPack")

local Remotes = require("@Shared/Remotes")

local TimeUtil = require("@Utility/Time")

-- // UI
local MainUI = PlayerGui:WaitForChild("UI")

local ShopFrame = MainUI:WaitForChild("Frames"):WaitForChild("Shop")
local MainFrame = ShopFrame:WaitForChild("Main"):WaitForChild("Main")

local CloseButton = ShopFrame:WaitForChild("Close")

local Packs = MainFrame:WaitForChild("Packs") :: Frame
local Passes = MainFrame:WaitForChild("Passes") :: Frame
local Cash = MainFrame:WaitForChild("Cash") :: Frame

local SmallerCash = Cash:WaitForChild("Smaller") :: Frame

local ForeverPackHolder = MainFrame:WaitForChild("ForeverPack"):WaitForChild("Forever"):WaitForChild("Main")
local ForeverPackRefreshTimer =
	MainFrame:WaitForChild("ForeverPack"):WaitForChild("Forever"):WaitForChild("RefreshTime") :: TextLabel

-- // Const
local FOREVER_PACK_PURCHASE = Color3.fromRGB(101, 232, 0)
local FOREVER_PACK_NEXT = Color3.fromRGB(129, 129, 129)

type PurchaseFrame = Frame & {
	Buy: TextButton & {
		name: TextLabel,
	},
}
type CashFrame = PurchaseFrame & {
	amount: TextLabel,
}

local BigCash = Cash:WaitForChild("48hrs") :: CashFrame

local FiveMinutes = SmallerCash:WaitForChild("5mins") :: CashFrame
local ThirtyMinutes = SmallerCash:WaitForChild("30mins") :: CashFrame
local TwoHours = SmallerCash:WaitForChild("2hrs") :: CashFrame
local TwelveHours = SmallerCash:WaitForChild("12hrs") :: CashFrame

local LuckFrame = MainFrame:WaitForChild("Luck"):WaitForChild("ServerLuck") :: PurchaseFrame & {
	after: TextLabel,
	before: TextLabel,
}

-- // var
local LastForeverPackReset = 0
local CurrentInfo = {}

-- // local functions
local function GetLowestIndex(Table: {}): number
	local CurrentLowest: number
	for index, _ in Table do
		if not CurrentLowest then
			if typeof(index) == "number" then
				CurrentLowest = index
			end
		else
			if typeof(index) == "number" then
				if index < CurrentLowest then
					CurrentLowest = index
				end
			end
		end
	end
	return tonumber(CurrentLowest) or CurrentLowest
end

local function GetRobuxProductInfo(ProductId: number)
	local success, response = pcall(function()
		return MarketplaceService:GetProductInfo(ProductId, Enum.InfoType.Product)
	end)

	if success then
		return response
	end

	return
end

-- // Init
local Shop = {}

function Shop.Init()
	Shop.Junk = {} :: { RBXScriptConnection | () -> () }

	-- // forever pack shit
	Replica.OnNew("PlayerData", function(_replica)
		Shop:UpdateForeverPack(_replica.Data.ForeverPack)
		LastForeverPackReset = _replica.Data.LastForeverPackReset
		_replica:OnSet({ "ForeverPack" }, function(new_value)
			if new_value == CurrentInfo then
				return
			end
			Shop:UpdateForeverPack(new_value)
			CurrentInfo = new_value
		end)
		_replica:OnSet({ "LastForeverPackReset" }, function(new_value)
			if typeof(new_value) == "number" then
				if LastForeverPackReset == new_value then
					return
				end
				LastForeverPackReset = new_value
			end
		end)
	end)

	task.spawn(function()
		while task.wait(1) do
			local TimeLeft = 21600 - (workspace:GetServerTimeNow() - LastForeverPackReset)

			if TimeLeft > 0 then
				ForeverPackRefreshTimer.Text = `Refreshes in: {TimeUtil.FormatHMS(TimeLeft)}`
			else
				ForeverPackRefreshTimer.Text = "Refreshing Soon..."
			end
		end
	end)

	-- // Luck
	CurrentLuck:GetPropertyChangedSignal("Value"):Connect(function()
		if CurrentLuck.Value == 16 then
			LuckFrame.after.Text = "MAX"
			LuckFrame.before.Text = "16x"
			LuckFrame.Buy.name.Text = "MAX"
			return
		end

		local Info = GetRobuxProductInfo(ProductsModule.ServerLuck[`x{CurrentLuck.Value * 2}`])

		LuckFrame.after.Text = `x{CurrentLuck.Value * 2}`
		LuckFrame.before.Text = `x{CurrentLuck.Value}`
		LuckFrame.Buy.name.Text = ` {Info.PriceInRobux}`
	end)
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

	-- cash skips thingy
	for _, obj in SmallerCash:GetChildren() do
		if obj:IsA("Frame") then
			local CashFrame = obj :: PurchaseFrame

			local ID: number
			for Name, ProdId in ProductsModule.Skips do
				if typeof(Name) == "string" and typeof(ProdId) == "number" then
					if string.find(Name, string.split(CashFrame.Name, "")[1]) then
						ID = ProdId
					end
				end
			end
			table.insert(
				self.Junk,
				Button(CashFrame.Buy, function()
					MarketplaceService:PromptProductPurchase(LocalPlayer, ID)
				end)
			)
		end
	end

	table.insert(
		self.Junk,
		Button(BigCash.Buy, function()
			MarketplaceService:PromptProductPurchase(LocalPlayer, ProductsModule.Skips["48 Hours"])
		end)
	)

	self:SetupSkipEarnings()

	-- // luck
	table.insert(
		self.Junk,
		Button(LuckFrame.Buy, function()
			if CurrentLuck.Value == 16 then
				return
			end
			local Product = ProductsModule.ServerLuck[`x{CurrentLuck.Value * 2}`]
			if Product then
				MarketplaceService:PromptProductPurchase(LocalPlayer, Product)
			end
		end)
	)
end

local ButtonShit = {} :: { () -> () | RBXScriptConnection }
function Shop:UpdateForeverPack(ForeverPackTable)
	for _, v in ButtonShit do
		if typeof(v) == "function" then
			v()
		end
	end
	table.clear(ButtonShit)

	for _, Frame in ForeverPackHolder:GetChildren() do
		if Frame:IsA("Frame") and Frame.Visible then
			Frame:Destroy()
		end
	end

	local LowestIndex = GetLowestIndex(ForeverPackTable)

	for Index: any, Data: any in ForeverPackTable do
		local _Index = tonumber(Index) :: number
		local RewardIndex = Data.RewardIndex

		local new: Frame = ForeverPackHolder:FindFirstChild(Index) or ForeverPackHolder.Template:Clone()
		new.Name = Index
		new.LayoutOrder = Index

		local Claimbtn = new:WaitForChild("ClaimBtn") :: TextButton & {
			price: TextLabel,
		}
		Claimbtn.price.Text = tonumber(ForeverPack.GetPriceFromIndex(_Index))
				and utf8.char(0xE002) .. MarketplaceService:GetProductInfo(
					ForeverPack.GetPriceFromIndex(_Index),
					Enum.InfoType.Product
				).PriceInRobux
			or "FREE"
		new.Visible = true

		if Index == LowestIndex then
			Claimbtn.BackgroundColor3 = FOREVER_PACK_PURCHASE
		else
			Claimbtn.BackgroundColor3 = FOREVER_PACK_NEXT
		end

		table.insert(
			ButtonShit,
			Button(Claimbtn, function()
				Remotes.ClaimForeverPack:request():andThen(function(UpdateTable)
					if UpdateTable then
						for _, v in ButtonShit do
							if typeof(v) == "function" then
								v()
							end
						end
						table.clear(ButtonShit)
						local _Table = UpdateTable :: {}
						Shop:UpdateForeverPack(_Table)
					end
				end)
			end)
		)

		local RewardLabel = new:WaitForChild("RewardLabel") :: TextLabel
		local ImageLabel = new:WaitForChild("ImageLabel") :: ImageLabel
		RewardLabel.Text = ForeverPack.Rewards[RewardIndex].Text
		ImageLabel.Image = ForeverPack.Rewards[RewardIndex].Image
		new.Parent = ForeverPackHolder
	end
end

function Shop:SetupSkipEarnings()
	FiveMinutes.amount.Text = "$" .. FormatNumber.Comma(CalculateEarningsByTime(LocalPlayer, 60 * 5))
	ThirtyMinutes.amount.Text = "$" .. FormatNumber.Comma(CalculateEarningsByTime(LocalPlayer, 60 * 30))
	TwoHours.amount.Text = "$" .. FormatNumber.Comma(CalculateEarningsByTime(LocalPlayer, 60 * 60 * 2))
	TwelveHours.amount.Text = "$" .. FormatNumber.Comma(CalculateEarningsByTime(LocalPlayer, 60 * 60 * 12))

	BigCash.amount.Text = "$" .. FormatNumber.Comma(CalculateEarningsByTime(LocalPlayer, 60 * 60 * 48))
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
