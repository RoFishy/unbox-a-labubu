local Remo = require("@Packages/Remo")
local t = require("@Packages/t")

type Remotes = Remo.Remotes<{
	GetLabubuTool: Remo.ServerAsync<(string), (Instance)>,
	DestroyLabubuTool: Remo.ClientToServer<(string)>,
	AddToSlot: Remo.ClientToServer<(string, string)>,
}>

local Remotes: Remotes = Remo.createRemotes({
	GetLabubuTool = Remo.remote(t.string).returns(t.Instance),
	DestroyLabubuTool = Remo.remote(t.string),
	AddToSlot = Remo.remote(t.string, t.string),
})

return Remotes
