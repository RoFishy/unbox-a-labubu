-- // Modules
local Remotes = require("@Shared/Remotes")

-- // util
local DataUtil = require("@ServerUtility/DataUtil")

local GetLabubuInfo = require("@Utility/GetLabubuInfo")

-- // init
local SellService = {}

function SellService:Start()
	Remotes.SellLabubu:connect(function(Player: Player, LabubuID: string)
		local Data = DataUtil:GetData(Player)

		if Data then
			Data = table.clone(Data)

			if Data.Backpack then
				for ID, LabubuData in Data.Backpack do
					if ID == LabubuID then
						local _, Info = GetLabubuInfo(LabubuData.Name)

						if Info then
							Data.Cash += Info.SellPrice
							Data.Backpack[ID] = nil
							break
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
				for _, LabubuData in Data.Backpack do
					local _, Info = GetLabubuInfo(LabubuData.Name)

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
