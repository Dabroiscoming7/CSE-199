-- @ScriptType: Script
local waypoints = workspace:WaitForChild("Waypoints")

local function moveEnemy(enemy)
	local humanoid = enemy:WaitForChild("Humanoid")

	for i = 1, #waypoints:GetChildren() do
		local waypoint = waypoints:WaitForChild(tostring(i))
		humanoid:MoveTo(waypoint.Position)
		humanoid.MoveToFinished:Wait()
	end

	enemy:Destroy()
end

-- TEMPORARY TEST: finds the model named "Enemy" in Workspace
local enemy = workspace:WaitForChild("Enemy")
moveEnemy(enemy)