-- @ScriptType: Script
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local towersFolder = Workspace:FindFirstChild("PlacedTowers") or Instance.new("Folder")
towersFolder.Name = "PlacedTowers"
towersFolder.Parent = Workspace

local enemyFolder = Workspace:WaitForChild("Enemies")
local towerTemplates = ReplicatedStorage:WaitForChild("Towers")

local function getClosestEnemy(tower, range)
	local closestEnemy = nil
	local closestDistance = math.huge
	
	for _, enemy in ipairs(enemyFolder:GetChildren()) do
		local humanoid = enemy:FindFirstChildOfClass("Humanoid")
		local hrp = enemy:FindFirstChild("HumanoidRootPart")
		
		if humanoid and hrp and humanoid.Health > 0 then
			local distance = (hrp.Position - tower.PrimaryPart.Position).Magnitude
			if distance <= range and distance < closestDistance then
				closestDistance = distance
				closestEnemy = enemy
			end
		end
			
	end
	
	return closestEnemy
end

local function runTower(tower)
	local config = tower:WaitForChild("Configuration")
	local range = config:WaitForChild("Range")
	local damage = config:WaitForChild("Damage")
	local fr = config:WaitForChild("Firerate")
	
	while tower.Parent do
		local target = getClosestEnemy(tower, range.Value)
		if target then
			local humanoid = target:FindFirstChildOfClass("Humanoid")
			if humanoid and humanoid.Health > 0 then
				humanoid:TakeDamage(damage.Value)
			end
		end
		task.wait(fr.Value)
	end
end

local function placeTestTower()
	local template = towerTemplates:FindFirstChild("BasicTower")
	if not template then
		warn("BasicTower template not found in ReplicatedStorage")
		return
	end
	
	local tower = template:Clone()
	tower.Parent = towersFolder
	tower:PivotTo(CFrame.new(0, 12, 0))
	
	task.spawn(runTower, tower)
end

placeTestTower()
