-- // Modules
local Remotes = require("@Shared/Remotes")

-- // util
local DataUtil = require("@ServerUtility/DataUtil")

local GetLabubuInfo = require("@Utility/GetLabubuInfo")

-- // init
local SellService = {}

function SellService:Start()
	Remotes.SellLabubu:connect(function(Player: Player, Labubu: string)
		local Data = DataUtil:GetData(Player)

		if Data then
			Data = table.clone(Data)

			if Data.Backpack then
				for _, LabubuName in Data.Backpack do
					if LabubuName == Labubu then
						local _, Info = GetLabubuInfo(LabubuName)

						if Info then
							Data.Cash += Info.SellPrice
							table.remove(Data.Backpack, table.find(Data.Backpack, LabubuName))
						end
					end
				end

				DataUtil:SetData(Player, Data)
			end
		end
	end)

	Remotes.SellAllLabubus:connect(function(Player: Player)
		local Data = DataUtil:GetData(Player)

		if Data then
			Data = table.clone(Data)

			if Data.Backpack then
				for _, LabubuName in Data.Backpack do
					local _, Info = GetLabubuInfo(LabubuName)

					if Info then
						Data.Cash += Info.SellPrice
					end
				end

				Data.Backpack = {}
				DataUtil:SetData(Player, Data)
			end
		end
	end)
end

return SellService
