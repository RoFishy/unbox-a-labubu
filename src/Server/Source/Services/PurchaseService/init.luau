-- // Services
local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")

-- // mods
local Passes = (require)(script.Passes)
local Products = (require)(script.Products)

local DataUtil = require("@ServerUtility/DataUtil")

-- // init
local PurchaseService = {}

function PurchaseService:Start()
	MarketplaceService.ProcessReceipt = function(receiptInfo: {
		PurchaseId: number,
		PlayerId: number,
		ProductId: number,
		PlaceIdWherePurchased: number,
		CurrencySpent: number,
		CurrencyType: Enum.CurrencyType,
		ProductPurchaseChannel: Enum.ProductPurchaseChannel,
	})
		if Products[receiptInfo.ProductId] then
			Products[receiptInfo.ProductId](Players:GetPlayerByUserId(receiptInfo.PlayerId))
			return Enum.ProductPurchaseDecision.PurchaseGranted
		end

		return Enum.ProductPurchaseDecision.NotProcessedYet
	end

	MarketplaceService.PromptGamePassPurchaseFinished:Connect(function(Player: Player, GamePassId: number, _: boolean)
		if MarketplaceService:UserOwnsGamePassAsync(Player.UserId, GamePassId) then
			self:AwardGamepass(Player, GamePassId)
		end
	end)
end

function PurchaseService:SetupPlayerGamepasses(Player: Player)
	for ID, _ in Passes do
		if MarketplaceService:UserOwnsGamePassAsync(Player.UserId, ID) then
			self:AwardGamepass(Player, ID)
		end
	end
end

function PurchaseService:AwardVIPPhysicalRewards(Player: Player)
	local Character = Player.Character or Player.CharacterAdded:Wait()
	local Humanoid = Character:WaitForChild("Humanoid") :: Humanoid
	Player:SetAttribute("VIP", true)

	Humanoid.WalkSpeed *= 1.25

	Player.CharacterAdded:Connect(function(_: Model)
		Humanoid.WalkSpeed *= 1.25
	end)
end

function PurchaseService:AwardGamepass(Player: Player, GamePassId: number)
	local PlayerData = DataUtil:GetData(Player)
	if PlayerData then
		if Passes[GamePassId] then
			local Success, Info = pcall(function()
				return MarketplaceService:GetProductInfo(GamePassId, Enum.InfoType.GamePass)
			end)

			if Success then
				local Name = Info.Name :: string

				if Name == "VIP" then
					self:AwardVIPPhysicalRewards(Player)
				end

				if PlayerData.Gamepasses[Name] and PlayerData.Gamepasses[Name] == true then
					return
				else
					PlayerData.Gamepasses[Name] = true
				end
			end

			DataUtil:SetData(Player, PlayerData)

			Passes[GamePassId](Player)
		end
	end
end

return PurchaseService
