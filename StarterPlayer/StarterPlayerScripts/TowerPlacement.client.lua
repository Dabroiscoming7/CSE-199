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

local function clearSelection()
	if ghost then
		ghost:Destroy()
	end
	ghost = nil
	selectedName = nil
	lastPosition = nil
	mouse.TargetFilter = nil
end

local function selectTower(name)
	local template = towerTemplates:FindFirstChild(name)
	if not template then
		warn("Tower template not found:", name)
		return
	end
	
	clearSelection()
	
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
	local boxCFrame, boxSize = ghost:GetBoundingBox()
	local bottomY = boxCFrame.Position.Y - boxSize.Y / 2
	heightOffset = ghost:GetPivot().Position.Y - bottomY
end

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
		if selectedName == hotkeyTower then
			clearSelection()
		else
			selectTower(hotkeyTower)
		end
		return
	end
	
	if input.KeyCode == Enum.KeyCode.Q or input.UserInputType == Enum.UserInputType.MouseButton2 then
		clearSelection()
		return
	end
	
	if input.UserInputType == Enum.UserInputType.MouseButton1 and selectedName and lastPosition then
		requestPlaceTower:FireServer(selectedName, lastPosition)
		clearSelection()
	end
end)