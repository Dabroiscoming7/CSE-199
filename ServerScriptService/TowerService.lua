-- @ScriptType: Script
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")

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

local function faceTarget(tower, target)
	local root = target:FindFirstChild("HumanoidRootPart")
	if not root then return end
	
	local pos = tower:GetPivot().Position
	local lookAt = Vector3.new(root.Position.X, pos.Y, root.Position.Z)
	tower:PivotTo(CFrame.lookAt(pos, lookAt) * CFrame.Angles(0, math.rad(-90), 0))
end

local function runTower(tower)
	-- Shows Error Message if Tower has no PrimaryPart
	if not tower.PrimaryPart then
		warn(tower.Name .. " has no PrimaryPart set")
		return
	end
	
	local config = tower:WaitForChild("Configuration")
	local range = config:WaitForChild("Range")
	local damage = config:WaitForChild("Damage")
	local fr = config:WaitForChild("Firerate")
	
	while tower.Parent do
		local target = getClosestEnemy(tower, range.Value)
		if target then
			faceTarget(tower, target)
			
			local humanoid = target:FindFirstChildOfClass("Humanoid")
			if humanoid and humanoid.Health > 0 then
				local healthBefore = humanoid.Health
				humanoid:TakeDamage(damage.Value)
				local healthLost = math.max(0, healthBefore - humanoid.Health)
				
				if healthLost > 0 then
					for _, player in ipairs(Players:GetPlayers()) do
						local leaderstats = player:FindFirstChild("leaderstats")
						local cash = leaderstats and leaderstats:FindFirstChild("Cash")
						
						if cash and cash:IsA("IntValue") then
							cash.Value = cash.Value +healthLost
						else
							warn("Cash IntValue missing for " .. player.Name)
						end
					end
				end
			end
		end
		task.wait(fr.Value)
		
	end
end

towersFolder.ChildAdded:Connect(function(tower)
	task.spawn(runTower, tower)
end)
