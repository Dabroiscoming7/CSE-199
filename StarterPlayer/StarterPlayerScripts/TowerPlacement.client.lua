-- @ScriptType: LocalScript
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

local player = Players.LocalPlayer
local mouse = player:GetMouse()

local requestPlaceTower = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("RequestPlaceTower")
local template = ReplicatedStorage:WaitForChild("Towers"):WaitForChild("BasicTower")

local TOWER_NAME = "BasicTower"

-- Ghost preview (Client-side only)
local ghost = template:Clone()
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

local heightOffset = ghost:GetExtentsSize().Y / 2
local lastPosition = nil

RunService.RenderStepped:Connect(function()
	if mouse.Hit then
		lastPosition = mouse.Hit.Position + Vector3.new(0, heightOffset, 0)
		ghost:PivotTo(CFrame.new(lastPosition))
	end
end)

UserInputService.InputBegan:Connect(function(input, processed)
	if processed then return end
	if input.UserInputType == Enum.UserInputType.MouseButton1 and lastPosition then
		requestPlaceTower:FireServer(TOWER_NAME, lastPosition)
	end
end)