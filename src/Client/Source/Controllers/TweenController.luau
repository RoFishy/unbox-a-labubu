-- // modules
local Remotes = require("@Shared/Remotes")

local TweenModel = require("@Utility/TweenModel")

-- // init
local TweenController = {}

function TweenController:Start()
	Remotes.TweenModelScale:connect(function(Model, StartScale, EndScale, Info)
		if Model:IsA("Model") then
			local _Info = TweenInfo.new(table.unpack(Info))
			TweenModel.Scale(Model, StartScale, EndScale, _Info)
		end
	end)

	Remotes.TweenModelPosition:connect(function(Model, EndPosition, Info)
		if Model:IsA("Model") then
			local _Info = TweenInfo.new(table.unpack(Info))
			TweenModel.Position(Model, EndPosition, _Info)
		end
	end)
end

return TweenController
