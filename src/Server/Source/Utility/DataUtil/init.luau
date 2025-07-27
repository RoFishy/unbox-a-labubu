-- // Services
local Players = game:GetService("Players")

-- // Packages
local ProfileStore = require("@ServerPackages/ProfileStore")

-- // Modules
local DataTemplate = require(script.Template)
local Types = require("@Shared/Types")

-- // Store
local PlayerStore = ProfileStore.New("PlayerStore", DataTemplate)

-- // objects
local PlotsFolder = workspace.Plots

-- // local functions
local function GetPlayerPlot(Player: Player): Instance?
	for _, Plot in PlotsFolder:GetChildren() do
		if Plot:GetAttribute("Owner") and Plot:GetAttribute("Owner") == Player.Name then
			return Plot
		end
	end

	return
end

-- // Module
type DataUtilType = {
	Profiles: { [Player]: any },
	New: (Player) -> (),
	InitializePlayer: (self: DataUtilType, Player: Player) -> (),
	_SetupLeaderstats: (self: DataUtilType, Player: Player) -> (),
	_UpdateLeaderstats: (self: DataUtilType, Player: Player) -> (),
	GetData: (self: DataUtilType, Player: Player) -> Types.UserData?,
	SetData: (self: DataUtilType, Player: Player, Data: Types.UserData) -> (),
	CleanupProfile: (self: DataUtilType, Player: Player) -> (),
}
local DataUtil = {
	Profiles = {} :: { [Player]: any },
} :: DataUtilType

function DataUtil.New(Player: Player)
	local Profile = PlayerStore:StartSessionAsync(`{Player.UserId}`, {
		Cancel = function()
			return Player.Parent ~= Players
		end,
	})

	if Profile ~= nil then
		Profile:AddUserId(Player.UserId)
		Profile:Reconcile()

		Profile.OnSessionEnd:Connect(function()
			DataUtil.Profiles[Player] = nil
			Player:Kick("Profile session end - Please Rejoin")
		end)

		if Player.Parent == Players then
			DataUtil.Profiles[Player] = Profile
			DataUtil:InitializePlayer(Player)
		else
			Profile:EndSession()
		end
	else
		Player:Kick(`Profile load fail - Please Rejoin`)
	end
end

function DataUtil:InitializePlayer(Player: Player)
	self:_SetupLeaderstats(Player)
end

function DataUtil:_SetupLeaderstats(Player: Player)
	local leaderstats = Instance.new("Folder")
	leaderstats.Name = "leaderstats"
	leaderstats.Parent = Player

	local Cash = Instance.new("IntValue")
	Cash.Name = "Cash"
	Cash.Parent = leaderstats

	local Data = self:GetData(Player)
	if Data then
		Cash.Value = Data.Cash
	end
end

function DataUtil:SetData(Player: Player, Data: Types.UserData)
	local Profile = self.Profiles[Player]
	if Profile then
		Profile.Data = Data

		self:_UpdateLeaderstats(Player)
	end
end

function DataUtil:_UpdateLeaderstats(Player: Player)
	local leaderstats = Player:FindFirstChild("leaderstats")
	if leaderstats then
		local Cash = leaderstats:FindFirstChild("Cash") :: IntValue
		if Cash then
			local Data = self:GetData(Player)
			if Data then
				Cash.Value = Data.Cash
			end
		end
	end
end

function DataUtil:GetData(Player: Player): Types.UserData?
	local Profile = self.Profiles[Player]
	if Profile then
		return Profile.Data
	else
		return nil
	end
end

function DataUtil:CleanupProfile(Player: Player)
	local Plot = GetPlayerPlot(Player)

	local LabubuData = {} :: Types.LabubuDataInfo
	if Plot then
		local Slots = Plot:WaitForChild("Components"):WaitForChild("Slots") :: Folder
		for _, Slot in Slots:GetChildren() do
			local LabubuName = Slot:GetAttribute("Labubu")
			if LabubuName then
				table.insert(LabubuData, {
					Name = LabubuName,
					Slot = Slot.Name,
				})
			end
		end
	end

	local PlayerData = self:GetData(Player)
	if PlayerData then
		PlayerData = table.clone(PlayerData)

		PlayerData.Labubus = LabubuData
		self:SetData(Player, PlayerData)
	end

	if self.Profiles[Player] then
		self.Profiles[Player]:EndSession()
	end
end

return DataUtil
