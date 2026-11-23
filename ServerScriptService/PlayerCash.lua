-- @ScriptType: Script
local Players = game:GetService("Players")

local function setupCash(player)
	local leaderstats = player:FindFirstChild("leaderstats")
	if not leaderstats then
		leaderstats = Instance.new("Folder")
		leaderstats.Name = "leaderstats"
		leaderstats.Parent = player
	end
	
	local cash = leaderstats:FindFirstChild("Cash")
	if not cash then 
		cash = Instance.new("IntValue")
		cash.Name = "Cash"
		cash.Value = 0
		cash.Parent = leaderstats
	elseif not cash:IsA("IntValue") then
		warn(player.name .. "'s Cash must be a IntValue")
	end
end

Players.PlayerAdded:Connect(setupCash)

for _, player in ipairs(Players:GetPlayers()) do
	setupCash(player)
end