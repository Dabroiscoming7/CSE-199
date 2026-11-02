-- @ScriptType: Script
local waypoints = workspace:WaitForChild("Waypoints")
local enemiesFolder = workspace:WaitForChild("Enemies")
local movingEnemies = {}

local function moveEnemy(enemy)
	if not enemy:IsA("Model") or movingEnemies[enemy] then
		return
	end
	movingEnemies[enemy] = true
	
	local humanoid = enemy:WaitForChild("Humanoid")
	
	for i = 1, #waypoints:GetChildren() do
		if not enemy.Parent or humanoid.Health <= 0 then
			return
		end
		
		local waypoint = waypoints:WaitForChild(tostring(i))
		local root = enemy:WaitForChild("HumanoidRootPart")
		
		humanoid:MoveTo(waypoint.Position)
		while enemy.Parent and humanoid.Health > 0
			and (Vector3.new(root.Position.X, 0, root.Position.Z)
				- Vector3.new(waypoint.Position.X, 0, waypoint.Position.Z)).Magnitude > 2 do
			task.wait()
		end
	end
	
	if enemy.Parent then
		enemy:Destroy()
	end
end

enemiesFolder.ChildAdded:Connect(function(enemy)
	task.spawn(moveEnemy, enemy)
end)

for _, enemy in ipairs(enemiesFolder:GetChildren()) do
	task.spawn(moveEnemy, enemy)
end