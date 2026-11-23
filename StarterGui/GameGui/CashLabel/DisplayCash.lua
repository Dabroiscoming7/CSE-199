-- @ScriptType: LocalScript
local Players = game:GetService("Players")

local player = Players.LocalPlayer
local cash = player:WaitForChild("leaderstats"):WaitForChild("Cash")
local label = script.Parent

local function updateCash()
	label.Text = "Cash: " .. tostring(cash.Value)
end

cash:GetPropertyChangedSignal("Value"):Connect(updateCash)
updateCash()