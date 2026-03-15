--!strict
--!optimize 2

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local localPlayer = Players.LocalPlayer

local ScreenGui = localPlayer:WaitForChild("PlayerGui"):WaitForChild("ScreenGui") :: ScreenGui
local moneyFrame = ScreenGui:WaitForChild("Money") :: Frame
local moneyLabel = moneyFrame:WaitForChild("TextLabel") :: TextLabel
local multiplierLabel = moneyFrame:WaitForChild("MultiplierLabel") :: TextLabel
local SyncDeadEvent: RemoteEvent = ReplicatedStorage:WaitForChild("SyncDeadEvent")

local State = require(localPlayer.PlayerScripts.Client.Shared.UI.State)
local Dialog = require(localPlayer.PlayerScripts.Client.Shared.UI.Dialog)
local Quests = require(localPlayer.PlayerScripts.Client.Shared.UI.Quests)

local cash = 0
local reward = 0
local rewardCounter = 0

local UIModule = {}

function UIModule.connect()
    Quests.initialize()
    SyncDeadEvent.OnClientEvent:Connect(function(died: boolean, player: Player)
        task.wait(3)
        if died and player == localPlayer then
            Dialog.showDialog("Oh looks like you died.\nYou earned " .. rewardCounter .. "$ this game.", {{ text = "OK" }})
        end
    end)
    State.SyncEvent.OnClientEvent:Connect(function(key: string, value: any)
        if key == "cash" then
            cash = value
            moneyLabel.Text = tostring(value) .. " (+" .. tostring(reward) .. ")"
        elseif key == "reward" then
            if value > 0 then
                rewardCounter += value - reward
            end
            reward = value
            moneyLabel.Text = tostring(cash) .. " (+" .. tostring(value) .. ")"
        elseif key == "multiplier" then
            multiplierLabel.Text = tostring(value * 100 - 100) .. "% friend multiplier"
        end
    end)
end

return UIModule