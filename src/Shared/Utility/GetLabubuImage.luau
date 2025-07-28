local StarterGui = game:GetService("StarterGui")

local UI = StarterGui:WaitForChild("UI")
local Frames = UI:WaitForChild("Frames")
local Index = Frames:WaitForChild("Index")

local NormalHolder = Index:WaitForChild("Normal")

local function GetLabubuImage(Name: string): string?
	local Button = NormalHolder:FindFirstChild(Name)
	if Button then
		local ImageLabel = Button:WaitForChild("ImageLabel") :: ImageLabel
		if ImageLabel then
			return ImageLabel.Image
		end
	end
	return
end

return GetLabubuImage
