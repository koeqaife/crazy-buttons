--!strict
--!optimize 2

local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ScreenGui = localPlayer:WaitForChild("PlayerGui"):WaitForChild("ScreenGui") :: ScreenGui
local moneyFrame = ScreenGui:WaitForChild("Money") :: Frame
local moneyLabel = moneyFrame:WaitForChild("TextLabel") :: TextLabel
local multiplierLabel = moneyFrame:WaitForChild("MultiplierLabel") :: TextLabel

local cash = 0
local reward = 0

local UIModule = {}

local SyncEvent = ReplicatedStorage:WaitForChild("SyncEvent") :: RemoteEvent

function UIModule.connect()
    SyncEvent.OnClientEvent:Connect(function(key: string, value: any)
        if key == "cash" then
            cash = value
            moneyLabel.Text = tostring(value) .. " (+" .. tostring(reward) .. ")"
        elseif key == "reward" then
            reward = value
            moneyLabel.Text = tostring(cash) .. " (+" .. tostring(value) .. ")"
        elseif key == "multiplier" then
            multiplierLabel.Text = tostring(value * 100 - 100) .. "% friend multiplier"
        end
    end)
end

return UIModule