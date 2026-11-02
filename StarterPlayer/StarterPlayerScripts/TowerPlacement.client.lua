-- @ScriptType: LocalScript
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

local player = Players.LocalPlayer
local mouse = player:GetMouse()

local requestPlaceTower = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("RequestPlaceTower")
local towerTemplates = ReplicatedStorage:WaitForChild("Towers")

local hotkeys = {
	[Enum.KeyCode.One] = "BasicTower",
	[Enum.KeyCode.Two] = "SniperTower",
}

local selectedName = nil
local ghost = nil
local heightOffset = 0
local lastPosition = nil

local function selectTower(name)
	local template = towerTemplates:FindFirstChild(name)
	if not template then
		warn("Tower template not found:", name)
		return
	end
	
	if ghost then
		ghost:Destroy()
	end
	
	selectedName = name
	ghost = template:Clone()
	for _, d in ipairs(ghost:GetDescendants()) do
		if d:IsA("BasePart") then
			d.Anchored = true
			d.CanCollide = false
			d.CanQuery = false
			d.Transparency = 0.5
		end
	end
	ghost.Parent = workspace
	mouse.TargetFilter = ghost
	heightOffset = ghost:GetExtentsSize().Y / 2
end

selectTower("BasicTower")

RunService.RenderStepped:Connect(function()
	if ghost and mouse.Hit then
		lastPosition = mouse.Hit.Position + Vector3.new(0, heightOffset, 0)
		ghost:PivotTo(CFrame.new(lastPosition))
	end
end)

UserInputService.InputBegan:Connect(function(input, processed)
	if processed then return end
	
	local hotkeyTower = hotkeys[input.KeyCode]
	if hotkeyTower then
		selectTower(hotkeyTower)
		return
	end
	
	if input.UserInputType == Enum.UserInputType.MouseButton1 and selectedName and lastPosition then
		requestPlaceTower:FireServer(selectedName, lastPosition)
	end
end)

