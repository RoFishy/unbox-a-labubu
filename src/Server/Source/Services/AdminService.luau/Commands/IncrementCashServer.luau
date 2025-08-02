local DataUtil = require("@ServerUtility/DataUtil")

return function(_, Players: { Player }, Amount: number)
	for _, Player in Players do
		local Data = DataUtil:GetData(Player)
		if Data then
			Data = table.clone(Data)
			Data.Cash += Amount
			DataUtil:SetData(Player, Data)
		end
	end
	return "Incremented Cash"
end
