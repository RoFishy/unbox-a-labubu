-- // util
local NPC = require("@ClientUtility/NPC")

-- // controller
local InterfaceController = require("@Controllers/InterfaceController")

local Signals = require("@ClientUtility/Signals")

-- // chars
local NPCFolder = workspace:WaitForChild("NPCs")

local SellNPCCharacter = NPCFolder:WaitForChild("SellNPC")
local UpgradesNPCCharacter = NPCFolder:WaitForChild("UpgradeNPC")
local CrateNPCCharacter = NPCFolder:WaitForChild("CrateNPC")

-- // init
local NPCController = {}

function NPCController:Start()
	local SellNPC
	SellNPC = NPC.new(SellNPCCharacter, {
		[1] = {
			Option = "Open Sell Menu",
			Callback = function()
				SellNPC:Say("Computing!")
				InterfaceController:OpenFrame("Sell")
				Signals.CloseFrame:Wait()
			end,
		},
		[2] = {
			Option = "Goodbye!",
		},
	}, "How can I help you?", "Sell NPC")
	local UpgradesNPC
	UpgradesNPC = NPC.new(UpgradesNPCCharacter, {
		[1] = {
			Option = "Open Upgrades Menu",
			Callback = function()
				UpgradesNPC:Say("Computing!")
				InterfaceController:OpenFrame("Upgrades")
				Signals.CloseFrame:Wait()
			end,
		},
		[2] = {
			Option = "Goodbye!",
		},
	}, "How can I help you?", "Upgrades NPC")
	local CrateNPC
	CrateNPC = NPC.new(CrateNPCCharacter, {
		[1] = {
			Option = "Open Upgrades Menu",
			Callback = function()
				CrateNPC:Say("Computing!")
				InterfaceController:OpenFrame("Crates")
				Signals.CloseFrame:Wait()
			end,
		},
		[2] = {
			Option = "Goodbye!",
		},
	}, "How can I help you?", "Crate NPC")
end

return NPCController
