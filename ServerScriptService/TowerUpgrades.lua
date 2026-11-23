-- @ScriptType: Script
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local requestUpgrade = ReplicatedStorage:WaitForChild("Remotes")
	:WaitForChild("RequestUpgradeTower")
local upgrades = require(ReplicatedStorage:WaitForChild("BasicTowerUpgrades"))
local placedTowers = workspace:WaitForChild("PlacedTowers")

requestUpgrade.OnServerEvent:Connect(function(player, tower)
	if typeof(tower) ~= "Instance"
		or not tower:IsA("Model")
		or tower.Parent ~= placedTowers
		or tower.Name ~= "BasicTower"
		or tower:GetAttribute("OwnerUserId") ~= player.UserId then
		return
	end
	
	local level = tower:GetAttribute("UpgradeLevel")
	local upgrade = upgrades[level]
	if not upgrade then
		return
	end
	
	local leaderstats = player:FindFirstChild("leaderstats")
	local cash = leaderstats and leaderstats:FindFirstChild("Cash")
	local config = tower:FindFirstChild("Configuration")
	local damage = config and config:FindFirstChild("Damage")
	local range = config and config:FindFirstChild("Range")
	
	if not cash or not cash:IsA("IntValue")
		or not damage or not damage:IsA("NumberValue")
		or not range or not range:IsA("NumberValue") then
		warn("Cash or tower configuration is missing for " .. player.Name)
		return
	end
	
	if cash.Value < upgrade.Cost then
		return -- Not enough cash
	end
	
	cash.Value = cash.Value - upgrade.Cost
	damage.Value = damage.Value + upgrade.DamageIncrease
	range.Value = range.Value + upgrade.RangeIncrease
	tower:SetAttribute("UpgradeLevel", level + 1)
end)