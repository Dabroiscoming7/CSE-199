-- @ScriptType: Script
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local requestPlaceTower = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("RequestPlaceTower")
local towerTemplates = ReplicatedStorage:WaitForChild("Towers")
local waypoints = workspace:WaitForChild("Waypoints")

local placedFolder = workspace:FindFirstChild("PlacedTowers") or Instance.new("Folder")
placedFolder.Name = "PlacedTowers"
placedFolder.Parent = workspace

local MIN_TOWER_SPACING = 3 -- studs between towers
local MIN_PATH_DISTANCE = 2 -- studs from waypoints(Will be changed)
local MAX_PLACE_RANGE = 200 -- max studs from the player

local function distanceToSegment(p, a, b)
	local ab = b - a
	local lenSq = ab:Dot(ab)
	if lenSq == 0 then
		return (p - a).Magnitude
	end
	local t = math.clamp((p - a):Dot(ab) / lenSq, 0, 1)
	return (p - (a + ab * t)).Magnitude
end

local function isNearPath(position)
	local flat = Vector3.new(position.X, 0, position.Z)
	local prev = nil
	
	for i = 1, #waypoints:GetChildren() do 
		local wp = waypoints:FindFirstChild(tostring(i))
		if wp then
			local pos = Vector3.new(wp.Position.X, 0 ,wp.Position.Z)
			if prev and distanceToSegment(flat, prev, pos) < MIN_PATH_DISTANCE then
				return true
			end
			if (flat - pos).Magnitude <MIN_PATH_DISTANCE then
				return true
			end
			prev = pos
		end
	end
	
	return false
end

local function isValid(player, position)
	local character = player.Character
	local root = character and character:FindFirstChild("HumanoidRootPart")
	if not root or (root.Position - position).Magnitude < MIN_PATH_DISTANCE then
		return false
	end
	
	if isNearPath(position) then
		return false
	end
	
	for _, tower in ipairs(placedFolder:GetChildren()) do
		if (tower:GetPivot().Position - position).Magnitude < MIN_TOWER_SPACING then
			return false
		end
	end
	
	return true
end

requestPlaceTower.OnServerEvent:Connect(function(player, towerName, position)
	if type(towerName) ~= "string" or typeof(position) ~= "Vector3" then return end
	
	local template = towerTemplates:FindFirstChild(towerName)
	if not template then return end
	
	if not isValid(player, position) then return end
	
	local tower = template:Clone()
	tower.Parent = placedFolder
	tower:PivotTo(CFrame.new(position))
	
end)

