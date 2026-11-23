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

local upgrades = require(ReplicatedStorage:WaitForChild("BasicTowerUpgrades"))
local requestUpgrade = ReplicatedStorage:WaitForChild("Remotes")
	:WaitForChild("RequestUpgradeTower")
local placedTowers = workspace:WaitForChild("PlacedTowers")

local playerGui = player:WaitForChild("PlayerGui")
local panel = playerGui:WaitForChild("GameGui"):WaitForChild("UpgradePanel")
local infoLabel = panel:WaitForChild("InfoLabel")
local upgradeButton = panel:WaitForChild("UpgradeButton")
local closeButton = panel:WaitForChild("CloseButton")
local cash = player:WaitForChild("leaderstats"):WaitForChild("Cash")

local selectedTower = nil
local connections = {}

local function closePanel()
	for _, connection in ipairs(connections) do
		connection:Disconnect()
	end
	connections = {}
	panel.Visible = false
	selectedTower = nil
end

local function updatePanel()
	if not selectedTower then
		return
	end
	
	local level = selectedTower:GetAttribute("UpgradeLevel")
	local config = selectedTower:FindFirstChild("Configuration")
	local damage = config and config:FindFirstChild("Damage")
	local range = config and config:FindFirstChild("Range")
	if not level or not damage or not range then
		closePanel()
		return
	end
	
	local upgrade = upgrades[level]
	local nextText = "Maximum level"
	if upgrade then
		nextText = "Next: " .. upgrade.Cost .. " cash"
	end
	
	infoLabel.Text = "Basic Tower - level " .. level
		.. "\nDamage: " .. damage.Value
		.. " | Range: " .. range.Value
		.. "\n" .. nextText
	
	upgradeButton.Text = upgrade and "Upgrade" or "Max level"
end

local function selectPlacedTower()
	local part = mouse.Target
	local tower = part
	
	while tower and tower.Parent ~= placedTowers do 
		tower = tower.Parent
	end
	
	closePanel()
	
	if not tower or tower.Name ~= "BasicTower"
		or tower:GetAttribute("OwnerUserId") ~= player.UserId then
		return
	end

	local config = tower:FindFirstChild("Configuration")
	local damage = config and config:FindFirstChild("Damage")
	local range = config and config:FindFirstChild("Range")
	if not damage or not range then
		warn("BasicTower is missing Damage or Range")
		return
	end
	
	selectedTower = tower
	panel.Visible = true
	
	table.insert(connections, tower:GetAttributeChangedSignal("UpgradeLevel"):Connect(updatePanel))
	table.insert(connections, damage:GetPropertyChangedSignal("Value"):Connect(updatePanel))
	table.insert(connections, range:GetPropertyChangedSignal("Value"):Connect(updatePanel))
	table.insert(connections, tower.AncestryChanged:Connect(function()
		if tower.Parent ~= placedTowers then
			closePanel()
		end
	end))
	
	updatePanel()
end

upgradeButton.MouseButton1Click:Connect(function()
	if selectedTower then 
		requestUpgrade:FireServer(selectedTower)
	end
end)

closeButton.MouseButton1Click:Connect(closePanel)

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
		closePanel()
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
	
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		if selectedName and lastPosition then
			requestPlaceTower:FireServer(selectedName, lastPosition)
			clearSelection()
		else if not selectedName then
				selectPlacedTower()
			end
		end
	end
end)