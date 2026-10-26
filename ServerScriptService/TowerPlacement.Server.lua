-- @ScriptType: Script
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local requestPlaceTower = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("RequestPlaceTower")
local towerTemplates = ReplicatedStorage:WaitForChild("Towers")
local waypoints = workspace:WaitForChild("Waypoints")

local placedFolder = workspace:FindFirstChild("PlacedTowers") or Instance.new("Folder")
placedFolder.Name = "PlacedTowers"
placedFolder.Parent = workspace

local MIN_TOWER_SPACING = 6 -- studs between towers
local MIN_PATH_DISTANCE = 6 -- studs from waypoints(Will be changed)
local MAX_PLACE_RANGE = 200 -- max studs from the player

local function isValid(player, position)
	local character = player.Character
	local root = character and character:FindFirstChild("HumanoidRootPart")
	if not root or (root.Position - position).Magnitude < MIN_PATH_DISTANCE then
		return false
	end
	
	for _, wp in ipairs(waypoints:GetChildren()) do
		if wp:IsA("BasePart") and (wp.Position - position). Magnitude < MIN_PATH_DISTANCE then
			return false
		end
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

