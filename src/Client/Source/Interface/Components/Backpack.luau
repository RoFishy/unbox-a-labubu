-- // Services
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")

-- // Player
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- // Modules/Utils
local Button = require("@ClientUtility/Button")

local Replica = require("@Packages/Replica") :: any

local GetLabubuImage = require("@Utility/GetLabubuImage")

local GetPlayerPlot = require("@Utility/GetPlayerPlot")

local Remotes = require("@Shared/Remotes")

-- // UI
local MainUI = PlayerGui:WaitForChild("UI") :: ScreenGui
local Hud = MainUI:WaitForChild("Hud") :: Frame

local Hotbar = Hud:WaitForChild("Hotbar") :: Frame
local Inventory = Hud:WaitForChild("Inventory") :: ScrollingFrame

local InventoryTemplate = Inventory:WaitForChild("Template") :: TextButton

local HammerButton = Hotbar:WaitForChild("Hammer") :: TextButton
local InventoryButton = Hotbar:WaitForChild("Inventory") :: TextButton

local function HandleHammer()
	local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
	local Humanoid = Character:WaitForChild("Humanoid") :: Humanoid
	local Backpack = LocalPlayer:WaitForChild("Backpack")
	for _, Tool: Tool in Backpack:GetChildren() do
		if Tool:GetAttribute("Hammer") then
			Humanoid:EquipTool(Tool)
			return
		end
	end
	Humanoid:UnequipTools()
end

return function()
	Button(HammerButton, HandleHammer)
	Button(InventoryButton, function()
		Inventory.Visible = not Inventory.Visible
	end)

	local OldFrameConnections = {} :: { RBXScriptConnection | () -> () }

	local OldData = {}
	local CurrentEquipped: string?
	local Prompts = {} :: { ProximityPrompt }
	local PromptConnections = {} :: { RBXScriptConnection }

	Replica.OnNew("PlayerData", function(_replica)
		_replica:OnSet({ "Backpack" }, function(new_value: { [string]: { Name: string, Size: string? } })
			if new_value == OldData then
				return
			else
				OldData = new_value
			end

			for _, v in OldFrameConnections do
				if typeof(v) == "RBXScriptConnection" then
					if v.Connected then
						v:Disconnect()
					end
				elseif typeof(v) == "function" then
					v()
				end
			end
			table.clear(OldFrameConnections)

			for _, Item in Inventory:GetChildren() do
				if Item:IsA("TextButton") and Item.Name ~= "Template" then
					Item:Destroy()
				end
			end

			for ID, value in new_value do
				local LabubuImage = GetLabubuImage(value.Name)

				local Frame = InventoryTemplate:Clone()
				Frame.Name = value.Name
				Frame.Parent = Inventory
				Frame.Visible = true
				local Image = Frame:WaitForChild("ImageLabel") :: ImageLabel
				Image.Image = LabubuImage or ""

				table.insert(
					OldFrameConnections,
					Button(Frame, function()
						if CurrentEquipped then
							Remotes.DestroyLabubuTool:fire(CurrentEquipped)

							if CurrentEquipped == value.Name then
								CurrentEquipped = nil
								return
							end

							CurrentEquipped = nil
						end

						local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
						local Humanoid = Character:WaitForChild("Humanoid") :: Humanoid
						Humanoid:UnequipTools()

						task.wait(0.1)
						Remotes.GetLabubuTool:request(ID):andThen(function(result: Instance)
							CurrentEquipped = value.Name

							local NewHotbarButton = HammerButton:Clone()
							NewHotbarButton.Name = result.Name
							NewHotbarButton.Parent = Hotbar
							NewHotbarButton.LayoutOrder = 2

							local Keybind = NewHotbarButton:WaitForChild("keybind") :: TextLabel
							Keybind.Text = "2"

							local _Image = NewHotbarButton:WaitForChild("ImageLabel") :: ImageLabel
							_Image.Image = LabubuImage or ""

							Frame.Visible = false

							local PlayerBase = GetPlayerPlot(LocalPlayer)
							if PlayerBase then
								local Slots = PlayerBase:WaitForChild("Components"):WaitForChild("Slots") :: Folder
								for _, Slot in Slots:GetChildren() do
									if Slot:GetAttribute("Labubu") then
										continue
									end

									local Prompt = Instance.new("ProximityPrompt")
									Prompt.ActionText = "Place Labubu"
									Prompt.RequiresLineOfSight = false
									Prompt.HoldDuration = 1.5

									local Stand = Slot:WaitForChild("Stand")

									local Attachment: Attachment
									if Stand:FindFirstChild("Attachment") then
										Attachment = Stand:WaitForChild("Attachment") :: Attachment
									else
										Attachment = Instance.new("Attachment")
										Attachment.Parent = Stand
										Attachment.CFrame *= CFrame.new(0, 3, 0)
									end
									Prompt.Parent = Attachment

									table.insert(Prompts, Prompt)
									table.insert(
										PromptConnections,
										Prompt.Triggered:Connect(function()
											if CurrentEquipped then
												Remotes.DestroyLabubuTool:fire(CurrentEquipped)

												Remotes.AddToSlot:fire(ID, Slot.Name)
											end
										end)
									)
								end

								for _, Player in Players:GetPlayers() do
									if Player == LocalPlayer then
										continue
									end

									local _Character = Player.Character or Player.CharacterAdded:Wait()

									local RootPart = _Character:WaitForChild("HumanoidRootPart")

									local Prompt = Instance.new("ProximityPrompt")
									Prompt.Parent = RootPart
									Prompt.ActionText = "Give Labubu"
									Prompt.RequiresLineOfSight = false
									Prompt.HoldDuration = 1.5

									table.insert(Prompts, Prompt)
									table.insert(
										PromptConnections,
										Prompt.Triggered:Connect(function()
											if CurrentEquipped then
												Remotes.DestroyLabubuTool:fire(CurrentEquipped)

												Remotes.GiveLabubu:fire(ID, Player)
											end
										end)
									)
								end
							end

							Button(NewHotbarButton, function()
								if CurrentEquipped then
									Remotes.DestroyLabubuTool:fire(CurrentEquipped)
								end
							end)

							result:GetPropertyChangedSignal("Parent"):Once(function()
								CurrentEquipped = nil
								local _Frame = Hotbar:FindFirstChild(result.Name)

								if result.Name == value.Name then
									Frame.Visible = true
								end

								if _Frame then
									_Frame:Destroy()
								end

								for _, Connection in PromptConnections do
									if Connection.Connected then
										Connection:Disconnect()
									end
								end
								table.clear(PromptConnections)

								for _, Prompt in Prompts do
									Prompt:Destroy()
								end
								table.clear(Prompts)
							end)
						end)
					end)
				)
			end
		end)
	end)

	UserInputService.InputBegan:Connect(function(InputObject: InputObject, GameProcessed: boolean)
		if GameProcessed then
			return
		end

		if InputObject.KeyCode == Enum.KeyCode.One then
			if CurrentEquipped then
				Remotes.DestroyLabubuTool:fire(CurrentEquipped)
				task.delay(0.1, HandleHammer)
			else
				HandleHammer()
			end
		elseif InputObject.KeyCode == Enum.KeyCode.Two then
			if CurrentEquipped then
				Remotes.DestroyLabubuTool:fire(CurrentEquipped)
			end
		elseif InputObject.KeyCode == Enum.KeyCode.Backquote then
			Inventory.Visible = not Inventory.Visible
		end
	end)
end
