-- // Services
local Players = game:GetService("Players")

-- // Packages
local ProfileStore = require("@ServerPackages/ProfileStore")

-- // Modules
local DataTemplate = (require)(script.Template)
local Types = require("@Shared/Types")

local GetPlayerPlot = require("@Utility/GetPlayerPlot")

local Replica = require("@Packages/Replica")

-- // Store
local PlayerStore = ProfileStore.New("PlayerStore", DataTemplate)

-- // Const
local DATA_TOKEN = Replica.Token("PlayerData")

-- // Module
type DataUtilType = {
	Profiles: { [Player]: any },
	Replicas: { [Player]: any },
	New: (Player) -> (),
	InitializePlayer: (self: DataUtilType, Player: Player) -> (),
	_SetupLeaderstats: (self: DataUtilType, Player: Player) -> (),
	_UpdateLeaderstats: (self: DataUtilType, Player: Player) -> (),
	GetData: (self: DataUtilType, Player: Player) -> Types.UserData?,
	SetData: (self: DataUtilType, Player: Player, Data: Types.UserData) -> (),
	CleanupProfile: (self: DataUtilType, Player: Player) -> (),
	SetupReplica: (self: DataUtilType, Player: Player) -> (),
	SaveBaseData: (self: DataUtilType, Player: Player) -> (),
	SetReplica: (self: DataUtilType, Player: Player, Data: Types.UserData) -> (),
}
local DataUtil = {
	Profiles = {} :: { [Player]: any },
	Replicas = {} :: { [Player]: any },
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

	task.spawn(function()
		while task.wait(120) do
			if Player and Player:IsDescendantOf(Players) then
				self:SaveBaseData(Player)
			end
		end
	end)

	task.delay(5, function()
		self:SaveBaseData(Player)
	end)
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

function DataUtil:SetupReplica(Player: Player)
	local Profile = self.Profiles[Player]
	if Player:IsDescendantOf(Players) and not Profile then
		repeat
			task.wait()
		until self.Profiles[Player]
		Profile = self.Profiles[Player]
	end
	local _replica = Replica.New({
		Token = DATA_TOKEN :: any,
		Data = Profile.Data,
	})
	self.Replicas[Player] = _replica
	_replica:Subscribe(Player)
	self:SetReplica(Player, Profile.Data)
end

function DataUtil:SetData(Player: Player, Data: Types.UserData)
	local Profile = self.Profiles[Player]
	if Profile then
		Profile.Data = Data

		self:_UpdateLeaderstats(Player)
		self:SetReplica(Player, Data)
	end
end

function DataUtil:SetReplica(Player: Player, Data: Types.UserData)
	local _replica = self.Replicas[Player]
	if _replica then
		_replica:Set({ "Index" }, Data.Index)
		_replica:Set({ "Backpack" }, Data.Backpack)
		_replica:Set({ "Cash" }, Data.Cash)
		_replica:Set({ "Upgrades" }, Data.Upgrades)
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

function DataUtil:SaveBaseData(Player: Player)
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
end

function DataUtil:CleanupProfile(Player: Player)
	self:SaveBaseData(Player)

	if self.Profiles[Player] then
		self.Profiles[Player]:EndSession()
	end
end

return DataUtil
