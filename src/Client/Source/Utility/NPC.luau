-- // Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

-- // Camera
local Camera = workspace.CurrentCamera

-- // objects
local NPCObjects = ReplicatedStorage:WaitForChild("NPC")
local NPCHighlight = NPCObjects:WaitForChild("NPCHighlight")
local NPCOverhead = NPCObjects:WaitForChild("NPCOverhead")

-- / mod
local Signals = require("@ClientUtility/Signals")
local Types = require("@Shared/Types")

-- // Constants
local ZOOMED_IN_FOV = 50

-- local functions
local function Typewrite(Object: TextLabel, Text: string)
	for i = 1, #Text, 1 do
		Object.Text = string.sub(Text, 1, i)
		task.wait(0.025)
	end
end

-- // NPC
local NPC = {}
NPC.__index = NPC

type NPCData = {
	Character: Model,
	DialogueOptions: Types.NPCDialogueOptions,
	OriginalQuestion: string,
	NPCName: string,
	NPCOverheadClone: any?,
}

export type NPC = typeof(setmetatable({} :: NPCData, NPC))

function NPC.new(
	Character: Model,
	DialogueOptions: Types.NPCDialogueOptions,
	OriginalQuestion: string,
	NPCName: string?
): NPC
	local self = setmetatable({}, NPC)

	self.Character = Character
	self.DialogueOptions = DialogueOptions
	self.OriginalQuestion = OriginalQuestion
	self.NPCName = NPCName or "NPC"
	self.NPCOverheadClone = nil

	self:Init()

	return self :: NPC
end

function NPC.Init(self: NPC)
	local ProximityPrompt = Instance.new("ProximityPrompt")
	ProximityPrompt.Parent = self.Character:WaitForChild("Torso")
	ProximityPrompt.ActionText = "Talk to NPC"
	ProximityPrompt.RequiresLineOfSight = false
	ProximityPrompt.ObjectText = self.NPCName

	local NPCHighlightClone = nil
	self.NPCOverheadClone = nil
	ProximityPrompt.PromptShown:Connect(function()
		NPCHighlightClone = NPCHighlight:Clone()
		NPCHighlightClone.Parent = self.Character
	end)
	ProximityPrompt.PromptHidden:Connect(function()
		if NPCHighlightClone then
			NPCHighlightClone:Destroy()
		end
	end)
	ProximityPrompt.Triggered:Connect(function()
		ProximityPrompt.Enabled = false
		TweenService:Create(Camera, TweenInfo.new(0.75), { FieldOfView = ZOOMED_IN_FOV }):Play()
		self.NPCOverheadClone = NPCOverhead:Clone()
		if self.NPCOverheadClone then
			self.NPCOverheadClone.Parent = self.Character:WaitForChild("Head")
			Typewrite(self.NPCOverheadClone.Frame.TextLabel, self.OriginalQuestion)
		end
		Signals.ToggleNPCDialogue:Fire(self.DialogueOptions)
	end)

	Signals.NPCInteractionEnded:Connect(function()
		TweenService:Create(Camera, TweenInfo.new(0.75), { FieldOfView = 70 }):Play()

		if self.NPCOverheadClone and self.NPCOverheadClone:FindFirstChild("Frame") then
			Typewrite(self.NPCOverheadClone.Frame.TextLabel, "Goodbye!")
			task.delay(1, function()
				self.NPCOverheadClone:Destroy()
				ProximityPrompt.Enabled = true
			end)
		end
	end)
end

function NPC.Say(self: NPC, Text: string)
	if self.NPCOverheadClone then
		Typewrite(self.NPCOverheadClone.Frame.TextLabel, Text)
	end
end

return NPC
