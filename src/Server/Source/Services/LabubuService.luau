-- // Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TeleportService = game:GetService("TeleportService")

-- // obj
local NameGradients = ReplicatedStorage.Gradients
local LabubuFolder = ReplicatedStorage.Labubus

-- // packages/utils/modules
local Remotes = require("@Shared/Remotes")

local DataUtil = require("@ServerUtility/DataUtil")

local GetLabubuInfo = require("@Utility/GetLabubuInfo")
local GetPlayerPlot = require("@Utility/GetPlayerPlot")

local SizeConfig = require("@Config/Sizes")

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

local function RejoinPlayer(Player: Player)
	if #Players:GetPlayers() > 1 then
		local Options = Instance.new("TeleportOptions")
		Options.ServerInstanceId = game.JobId

		TeleportService:TeleportAsync(game.PlaceId, { Player }, Options)
	else
		Player:Kick("Data Load Fail - Please Rejoin!")
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

			if Data.Backpack[LabubuName] then
				DataTwo.Backpack[LabubuName] = Data.Backpack[LabubuName]
				Data.Backpack[LabubuName] = nil

				DataUtil:SetData(FirstPlayer, Data)
				DataUtil:SetData(PlayerToGive, DataTwo)

				Remotes.ShowNotification:fire(
					FirstPlayer,
					"Successfully gave labubu to " .. PlayerToGive.Name,
					Color3.fromRGB(0, 255, 0)
				)

				Remotes.ShowNotification:fire(
					PlayerToGive,
					`Successfully received labubu {DataTwo.Backpack[LabubuName].Name} from {FirstPlayer.Name}. It is in your backpack.`,
					Color3.fromRGB(0, 255, 0)
				)
			end
		end
	end)

	Remotes.GetLabubuTool:onRequest(function(Player: Player, ID: string): Instance
		local LabubuData

		local PlayerData = DataUtil:GetData(Player)
		if PlayerData then
			local Backpack = PlayerData.Backpack
			if Backpack then
				LabubuData = Backpack[ID]
			end
		end

		local Labubu = LabubuFolder:FindFirstChild(LabubuData.Name) :: Model
		assert(Labubu, "No labubu model with name: " .. LabubuData.Name)

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
				Part.Massless = true

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

		for _, Part in Labubu:GetDescendants() do
			if Part:IsA("BasePart") then
				Part.Anchored = false
				Part.CanCollide = false
			end
		end

		Labubu:PivotTo(HumanoidRootPart.CFrame * CFrame.new(1, 2, -3))

		SetDisplayInfo(Labubu, LabubuData.Name)

		if LabubuData.Size then
			local Size = SizeConfig[LabubuData.Size]
			if Size then
				Labubu:ScaleTo(Size.Scale)

				Labubu:PivotTo(Labubu:GetPivot() * Size.Offset)
			end
		end

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

		local LabubuData

		local PlayerData = DataUtil:GetData(Player)
		if PlayerData then
			PlayerData = table.clone(PlayerData)

			if PlayerData.Backpack then
				LabubuData = PlayerData.Backpack[Name]

				if LabubuData then
					PlayerData.Backpack[Name] = nil
				else
					return
				end
			end
		end

		local _Labubu = LabubuClass.new(LabubuData.Name, Player, Slot, nil, LabubuData.Size)
		_Labubu:AddToSlot()
	end)
end

function LabubuService:ValidatePlot(Player: Player)
	local PlotModel = GetPlayerPlot(Player)
	if PlotModel and PlotModel:IsA("Model") then
		local Components = PlotModel:FindFirstChild("Components") :: Folder
		if Components then
			local Slots = Components:FindFirstChild("Slots") :: Folder
			if Slots then
				for _, Slot in Slots:GetChildren() do
					local Labubu = Slot:GetAttribute("Labubu")
					if Labubu then
						local Stand = Slot:FindFirstChild("Stand") :: Part

						local RaycastParams = RaycastParams.new()
						RaycastParams.FilterDescendantsInstances = { Stand }
						RaycastParams.FilterType = Enum.RaycastFilterType.Exclude
						RaycastParams.IgnoreWater = true

						local Result = workspace:Raycast(
							Stand.Position + Vector3.new(0, 1, 0),
							Vector3.new(0, 200, 0),
							RaycastParams
						)
						if Result then
							if not Result.Instance then
								RejoinPlayer(Player)
							end
						end
					end
				end
			end
		end
	end
end

return LabubuService
