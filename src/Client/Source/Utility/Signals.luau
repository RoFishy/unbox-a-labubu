-- packages
local Signal = require("@Packages/Signal")

return {
	NPCInteractionEnded = Signal.new(),
	ToggleNPCDialogue = Signal.new(),

	CloseFrame = Signal.new(),
}
