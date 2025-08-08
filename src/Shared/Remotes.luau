local Remo = require("@Packages/Remo")
local t = require("@Packages/t")

type Remotes = Remo.Remotes<{
	GetLabubuTool: Remo.ServerAsync<(string), (Instance)>,
	DestroyLabubuTool: Remo.ClientToServer<(string)>,
	AddToSlot: Remo.ClientToServer<(string, string)>,
	GiveLabubu: Remo.ClientToServer<(string, Player)>,

	ShowNotification: Remo.ServerToClient<(string, Color3?, string?)>,

	SellLabubu: Remo.ClientToServer<(string)>,
	SellAllLabubus: Remo.ClientToServer<>,

	PurchaseUpgrade: Remo.ClientToServer<(string)>,
	PurchaseCrate: Remo.ClientToServer<(string)>,

	ClaimFreeReward: Remo.ClientToServer<>,

	TweenModelScale: Remo.ServerToClient<(Instance, number, number, { any })>,
	TweenModelPosition: Remo.ServerToClient<(Instance, CFrame, { any })>,

	SetupPlotDisplay: Remo.ServerToClient<(string)>,

	ClaimForeverPack: Remo.ServerAsync<(), ({ any }?)>,
	HitBox: Remo.ClientToServer<(string)>,
}>

local Remotes: Remotes = Remo.createRemotes({
	GetLabubuTool = Remo.remote(t.string).returns(t.Instance),
	DestroyLabubuTool = Remo.remote(t.string),
	AddToSlot = Remo.remote(t.string, t.string),
	GiveLabubu = Remo.remote(t.string, t.Instance),

	ShowNotification = Remo.remote(t.string, t.optional(t.Color3), t.optional(t.string)),

	SellLabubu = Remo.remote(t.string),
	SellAllLabubus = Remo.remote(),

	PurchaseUpgrade = Remo.remote(t.string),
	PurchaseCrate = Remo.remote(t.string),

	ClaimFreeReward = Remo.remote(),

	TweenModelScale = Remo.remote(t.Instance, t.numberPositive, t.numberPositive, t.table),
	TweenModelPosition = Remo.remote(t.Instance, t.CFrame, t.table),

	SetupPlotDisplay = Remo.remote(t.string),

	ClaimForeverPack = Remo.remote().returns(t.optional(t.table)),

	HitBox = Remo.remote(t.string),
})

return Remotes :: Remotes
