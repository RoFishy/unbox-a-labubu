-- // Services
local Players = game:GetService("Players")

-- // local plr
local LocalPlayer = Players.LocalPlayer

-- // mod
local Remotes = require("@Shared/Remotes")

-- // init
local ToolService = {}

function ToolService:Start()
	local Backpack = LocalPlayer.Backpack

	local Debounce = false
	Backpack.ChildAdded:Connect(function(Child: Instance)
		if Child:IsA("Tool") then
			Child.Activated:Connect(function()
				if Debounce then
					return
				end
				Debounce = true

				task.delay(0.5, function()
					Debounce = false
				end)
				local Mouse = LocalPlayer:GetMouse()

				if Mouse.Target then
					local Target = Mouse.Target

					if Target and Target.Parent then
						if Target.Parent:GetAttribute("Crate") then
							Remotes.HitBox:fire(Target.Parent, Child.Name)
						elseif Target.Parent.Parent:GetAttribute("Crate") then
							Remotes.HitBox:fire(Target.Parent.Parent, Child.Name)
						end
					end
				end
			end)
		end
	end)
end

return ToolService
