-- // Services
local DataStoreService = game:GetService("DataStoreService")
local Players = game:GetService("Players")

-- // OrderedDS
local UnboxesOrderedDS = DataStoreService:GetOrderedDataStore("OrderedUnboxes")
local CashOrderedDS = DataStoreService:GetOrderedDataStore("OrderedCash")

-- // util
local FormatNumber = require("@Utility/FormatNumber")

-- // const
local REFRESH_INTERVAL = 120

-- // type
type LeaderboardFrame = Frame & {
	avatar: ImageLabel,
	amount: TextLabel,
	name: TextLabel,
	place: TextLabel,
}

type Leaderboard = Model & {
	main: Part & {
		SurfaceGui: SurfaceGui & {
			Frame: Frame & {
				Contents: Frame & {
					Items: ScrollingFrame & { LeaderboardFrame },
				},
			},
		},
	},
}

-- // local func
local function GetPlayerName(UserId: number)
	local MAX_RETRIES = 5
	local RETRY_DELAY = 0.1

	for _ = 1, MAX_RETRIES do
		local Success, Name = pcall(function()
			return Players:GetNameFromUserIdAsync(UserId)
		end)
		if Success then
			return Name
		end
		task.wait(RETRY_DELAY)
	end
	return nil
end

-- // obj
local LeaderboardsFolder = workspace.Leaderboards :: Folder & { Unbox: Leaderboard, Cash: Leaderboard }

-- // Init
local LeaderboardService = {}

function LeaderboardService:Start()
	task.wait(3)

	task.spawn(function()
		self:RefreshLeaderboard("Cash")
	end)
	task.spawn(function()
		self:RefreshLeaderboard("Unbox")
	end)

	while task.wait(REFRESH_INTERVAL) do
		task.spawn(function()
			self:RefreshLeaderboard("Cash")
		end)
		task.spawn(function()
			self:RefreshLeaderboard("Unbox")
		end)
	end
end

function LeaderboardService:RefreshLeaderboard(Leaderboard: "Cash" | "Unbox")
	local LeaderboardObj = LeaderboardsFolder:WaitForChild(Leaderboard) :: Leaderboard

	local MainContents = LeaderboardObj.main.SurfaceGui.Frame.Contents.Items
	self:ClearFrame(MainContents)

	-- // load data
	local Pages
	if Leaderboard == "Cash" then
		Pages = CashOrderedDS:GetSortedAsync(false, 10)
	elseif Leaderboard == "Unbox" then
		Pages = UnboxesOrderedDS:GetSortedAsync(false, 10)
	end
	local LeaderboardData = Pages:GetCurrentPage()

	for rank, data in LeaderboardData do
		local Template = MainContents:WaitForChild("Template") :: LeaderboardFrame
		local PlayerName = GetPlayerName(data.key)
		if not PlayerName then
			continue
		end
		Template.Name = data.key
		Template.name.Text = PlayerName
		Template.LayoutOrder = rank
		Template.place.Text = `#{rank}`
		Template.amount.Text = tostring(FormatNumber.Suffix(data.value))
		Template.avatar.Image =
			Players:GetUserThumbnailAsync(data.key, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size420x420)

		Template.Parent = MainContents
		Template.Visible = true
	end
end

function LeaderboardService:ClearFrame(ScrollingFrame: ScrollingFrame)
	for _, v in ScrollingFrame:GetChildren() do
		if v:IsA("Frame") and v.Name ~= "Template" then
			v:Destroy()
		end
	end
end

return LeaderboardService
