-- // Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- // obj
local NameGradients = ReplicatedStorage.Gradients
local LabubuFolder = ReplicatedStorage.Labubus

-- // packages/utils/modules
local Remotes = require("@Shared/Remotes")

local DataUtil = require("@ServerUtility/DataUtil")

local GetLabubuInfo = require("@Utility/GetLabubuInfo")
local GetPlayerPlot = require("@Utility/GetPlayerPlot")

local LabubuClass = require("@ServerClasses/Labubu")

-- // local functions
local function SetDisplayInfo(Labubu: Model, Name: string)
	local HumanoidRootPart = Labubu:WaitForChild("HumanoidRootPart")

	local Attachment = HumanoidRootPart:FindFirstChild("Attachment") :: Attachment
	if not Attachment then
		return
	end

	local Rarity, _ = GetLabubuInfo(Name)

	local _Rarity: string
	if typeof("Rarity") == "string" then
		_Rarity = Rarity :: string
	end

	local Billboard = Attachment:WaitForChild("Billboard")
	local Main = Billboard:WaitForChild("Main")

	local NameText = Main:WaitForChild("Name") :: TextLabel
	local RarityText = Main:WaitForChild("Rarity") :: TextLabel

	NameText.Text = Name
	RarityText.Text = _Rarity

	local OldGradient = RarityText:FindFirstChildOfClass("UIGradient")
	if OldGradient then
		OldGradient:Destroy()
	end

	local NewGradient = NameGradients:FindFirstChild(_Rarity)
	if NewGradient then
		local NewClone = NewGradient:Clone()
		NewClone.Parent = RarityText
	end
end

-- // Start
local LabubuService = {}

function LabubuService:Start()
	Remotes.GiveLabubu:connect(function(FirstPlayer, LabubuName, PlayerToGive)
		local Data = DataUtil:GetData(FirstPlayer)
		local DataTwo = DataUtil:GetData(PlayerToGive)
		if Data and DataTwo then
			Data = table.clone(Data)
			DataTwo = table.clone(DataTwo)

			if table.find(Data.Backpack, LabubuName) then
				table.insert(DataTwo.Backpack, LabubuName)
				table.remove(Data.Backpack, table.find(Data.Backpack, LabubuName))

				DataUtil:SetData(FirstPlayer, Data)
				DataUtil:SetData(PlayerToGive, DataTwo)

				Remotes.ShowNotification:fire(
					FirstPlayer,
					"Successfully gave labubu to " .. PlayerToGive.Name,
					Color3.fromRGB(0, 255, 0)
				)

				Remotes.ShowNotification:fire(
					PlayerToGive,
					`Successfully received labubu {LabubuName} from {FirstPlayer.Name}. It is in your backpack.`,
					Color3.fromRGB(0, 255, 0)
				)
			end
		end
	end)

	Remotes.GetLabubuTool:onRequest(function(Player: Player, Name: string): Instance
		local Labubu = LabubuFolder:FindFirstChild(Name) :: Model
		assert(Labubu, "No labubu model with name: " .. Name)

		Labubu = Labubu:Clone()

		local RootPart = Labubu:FindFirstChild("HumanoidRootPart") :: Part
		if RootPart then
			RootPart.Anchored = false
			RootPart.CanCollide = false
		end

		for _, Part in Labubu:GetDescendants() do
			if Part:IsA("BasePart") then
				if Part == RootPart then
					continue
				end

				Part.Anchored = false
				Part.CanCollide = false

				local WeldConstraint = Instance.new("WeldConstraint")
				WeldConstraint.Part0 = RootPart
				WeldConstraint.Part1 = Part

				WeldConstraint.Parent = RootPart
			end
		end

		local Character = Player.Character or Player.CharacterAdded:Wait()
		local HumanoidRootPart = Character:FindFirstChild("HumanoidRootPart") :: Part

		local Tool = Instance.new("Tool")

		local Toolhandle = Instance.new("Part")
		Toolhandle.Name = "Handle"
		Toolhandle.CanCollide = false
		Toolhandle.Parent = Tool
		Toolhandle.Transparency = 1
		Toolhandle.Size = Vector3.new(1, 1, 1)

		Tool.Parent = Character
		Labubu.Parent = Character

		Labubu:PivotTo(HumanoidRootPart.CFrame * CFrame.new(1, 2, -3))

		SetDisplayInfo(Labubu, Name)

		local WeldConstraint = Instance.new("WeldConstraint")
		WeldConstraint.Part0 = HumanoidRootPart
		WeldConstraint.Part1 = RootPart
		WeldConstraint.Parent = HumanoidRootPart

		return Labubu
	end)

	Remotes.DestroyLabubuTool:connect(function(Player: Player, Name: string)
		local Character = Player.Character or Player.CharacterAdded:Wait()
		local LabubuModel = Character:FindFirstChild(Name) :: Model

		if LabubuModel then
			LabubuModel:Destroy()
		end

		local Tool = Character:FindFirstChildOfClass("Tool")

		if Tool then
			Tool:Destroy()
		end
	end)

	Remotes.AddToSlot:connect(function(Player: Player, Name: string, Slot: string)
		local PlayerPlot = GetPlayerPlot(Player)

		if not PlayerPlot then
			return
		end

		local Components = PlayerPlot:FindFirstChild("Components") :: Folder
		if not Components then
			return
		end

		local Slots = Components:FindFirstChild("Slots") :: Folder
		if not Slots then
			return
		end

		local SlotInstance = Slots:FindFirstChild(Slot)

		if not SlotInstance then
			return
		end

		if SlotInstance:GetAttribute("Labubu") then
			return
		end

		local PlayerData = DataUtil:GetData(Player)
		if PlayerData then
			PlayerData = table.clone(PlayerData)

			if PlayerData.Backpack then
				local index = table.find(PlayerData.Backpack, Name)
				if index then
					table.remove(PlayerData.Backpack, index)
				else
					return
				end
			end
		end

		local _Labubu = LabubuClass.new(Name, Player, Slot)
		_Labubu:AddToSlot()
	end)
end

return LabubuService
