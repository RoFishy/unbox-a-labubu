local Owners = {
	"xRo_Fishy",
	"dead3yex",
}

return function(registry)
	registry:RegisterHook("BeforeRun", function(context): any
		if not table.find(Owners, context.Executor.Name) then
			return "You are not allowed to use this command."
		end
		return
	end)
end
