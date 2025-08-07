-- // Services
local Players = game:GetService("Players")
local TextChatService = game:GetService("TextChatService")

-- // init
local TextController = {}

function TextController:Start()
	TextChatService.OnIncomingMessage = function(Message: TextChatMessage)
		if not Message.TextSource then
			return
		end

		local Properties = Instance.new("TextChatMessageProperties")
		local Player = Players:GetPlayerByUserId(Message.TextSource.UserId)

		if Player:GetAttribute("VIP") then
			Properties.PrefixText = `<font color = "#ffaa00">[VIP]</font> {Message.PrefixText}`
		end

		return Properties
	end
end

return TextController
