-- @ScriptType: Script
local ServerStorage = game:GetService("ServerStorage")

local enemyTemplates = ServerStorage:WaitForChild("Enemies")
local enemiesFolder = workspace:WaitForChild("Enemies")
local waypoints = workspace:WaitForChild("Waypoints")

local INTERMISSION = 4

local waves = {
	{
		{ enemy = "BasicEnemy", count = 5, delay = 1.5},
	},
	{
		{ enemy = "BasicEnemy", count = 8, delay = 0.9},
	},
	{
		{ enemy = "FastEnemy", count = 10, delay = 0.5},
	},
	{
		{ enemy = "SlowEnemy", count = 10, delay = 0.7},
	},
}

local function spawnEnemy(name)
	local template = enemyTemplates:FindFirstChild(name)
	if not template then
		warn("Enemy template not found:", name)
		return
	end
	
	local enemy = template:Clone()
	local start = waypoints:WaitForChild("1")
	enemy:PivotTo(start.CFrame + Vector3.new(0, 3, 0))
	enemy.Parent = enemiesFolder
	enemy:WaitForChild("HumanoidRootPart"):SetNetworkOwner(nil)
	
	local humanoid = enemy:WaitForChild("Humanoid")
	humanoid.Died:Connect(function()
		task.wait(0.5)
		enemy:Destroy()
	end)
end

task.wait(5)  -- time for players to join and place towers(Temporary)

for waveNumber, wave in ipairs(waves) do
	print("Wave", waveNumber, "starting")
	
	for _, group in ipairs(wave) do
		for _ = 1, group.count do
			spawnEnemy(group.enemy)
			task.wait(group.delay)
		end
	end
	
	-- wait for the wave to be cleared before the intermission
	while #enemiesFolder:GetChildren() > 0 do
		task.wait(1)
	end
	
	print("Wave", waveNumber, "cleared")
	if waveNumber < #waves then
		task.wait(INTERMISSION)
	end
end

print("All waves complete!")

