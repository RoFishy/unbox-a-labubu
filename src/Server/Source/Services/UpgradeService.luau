-- // module
local Remotes = require("@Shared/Remotes")

local DataUtil = require("@ServerUtility/DataUtil")

local Types = require("@Shared/Types")

local HammerTool = require("@ServerClasses/HammerTool")

-- // data
local ToolData = require("@Config/Tools")
local UpgradeData = require("@Config/Upgrades")

-- // init
local UpgradeService = {}

function UpgradeService:Start()
	Remotes.PurchaseUpgrade:connect(function(Player: Player, Name: string)
		local PlayerData = DataUtil:GetData(Player)
		if PlayerData then
			PlayerData = table.clone(PlayerData)

			local CurrentUpgrade = PlayerData.Upgrades[Name]
			if CurrentUpgrade then
				local NextUpgrade: Types.ToolInfo | Types.UpgradeInfo<number> | nil
				if Name == "Tool" then
					NextUpgrade = ToolData[CurrentUpgrade + 1]
				else
					NextUpgrade = UpgradeData[Name][CurrentUpgrade + 1]
				end

				if NextUpgrade then
					if PlayerData.Cash >= NextUpgrade.Price then
						PlayerData.Cash -= NextUpgrade.Price

						PlayerData.Upgrades[Name] += 1
						DataUtil:SetData(Player, PlayerData)

						if Name == "Tool" then
							local Backpack = Player.Backpack
							local CurrentTool = Backpack:FindFirstChild(tostring(CurrentUpgrade))

							if CurrentTool then
								CurrentTool:Destroy()
							else
								local Character = Player.Character or Player.CharacterAdded:Wait()
								CurrentTool = Character:FindFirstChild(tostring(CurrentUpgrade))
								if CurrentTool then
									CurrentTool:Destroy()
								end
							end

							HammerTool.new(Player)
						end
					end
				end
			end
		end
	end)
end

return UpgradeService
