local Remo = require("@Packages/Remo")
local t = require("@Packages/t")

type Remotes = Remo.Remotes<{
	GetLabubuTool: Remo.ServerAsync<(string), (Instance)>,
	DestroyLabubuTool: Remo.ClientToServer<(string)>,
	AddToSlot: Remo.ClientToServer<(string, string)>,

	ShowNotification: Remo.ServerToClient<(string, Color3?, string?)>,

	SellLabubu: Remo.ClientToServer<(string)>,
	SellAllLabubus: Remo.ClientToServer<>,
}>

local Remotes: Remotes = Remo.createRemotes({
	GetLabubuTool = Remo.remote(t.string).returns(t.Instance),
	DestroyLabubuTool = Remo.remote(t.string),
	AddToSlot = Remo.remote(t.string, t.string),

	ShowNotification = Remo.remote(t.string, t.optional(t.Color3), t.optional(t.string)),

	SellLabubu = Remo.remote(t.string),
	SellAllLabubus = Remo.remote(),
})

return Remotes
