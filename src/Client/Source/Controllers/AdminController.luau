-- // Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Cmdr = (require)(ReplicatedStorage:WaitForChild("CmdrClient"))

local AdminController = {}

function AdminController:Start()
	task.spawn(function()
		Cmdr:SetActivationKeys({ Enum.KeyCode.F2 })
	end)
end

return AdminController
