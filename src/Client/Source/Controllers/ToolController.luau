-- // Services
local Players = game:GetService("Players")

-- // local plr
local LocalPlayer = Players.LocalPlayer

-- // mod
local Remotes = require("@Shared/Remotes")

-- // init
local ToolService = {}

function ToolService:Init()
	--local Backpack = LocalPlayer:WaitForChild("Backpack")

	--local CurrentTool: string = ""
	local Debounce = false

	local Mouse = LocalPlayer:GetMouse()

	Mouse.Button1Down:Connect(function()
		local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()

		if Character then
			if Character:FindFirstChildOfClass("Tool") then
				if Debounce then
					return
				end

				Debounce = true

				task.delay(0.5, function()
					Debounce = false
				end)
				Remotes.HitBox:fire(Character:FindFirstChildOfClass("Tool").Name)
			end
		end
	end)

	--[[
	Backpack.ChildAdded:Connect(function(Child: Instance)
		if Child.Name == CurrentTool then
			return
		end
		if Child:IsA("Tool") then
			CurrentTool = Child.Name
			Child.Activated:Connect(function()
				if Debounce then
					return
				end
				Debounce = true

				task.delay(0.5, function()
					Debounce = false
				end)

				Remotes.HitBox:fire(Child.Name)

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
    ]]
end

return ToolService
