--!strict
--!optimize 2
local LeftButtons = {}

local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer

local window = localPlayer:WaitForChild("PlayerGui"):WaitForChild("ScreenGui"):WaitForChild("StatsFrame") :: Frame

local State = require(localPlayer.PlayerScripts.Client.Lobby.UI.State)

function LeftButtons.initialize()
    local survives = window:WaitForChild("Survives"):WaitForChild("TextLabel") :: TextLabel
    local streak = window:WaitForChild("Streak"):WaitForChild("TextLabel") :: TextLabel
    local money = window:WaitForChild("Money"):WaitForChild("TextLabel") :: TextLabel

    survives.Text = tostring(State.survives)
    money.Text = tostring(State.cash)
    streak.Text = tostring(State.streak)

    State.CashUpdated.Event:Connect(function(oldValue: number, newValue: number)
        money.Text = tostring(newValue)
    end)
    State.SurvivesUpdated.Event:Connect(function(oldValue: number, newValue: number)
        survives.Text = tostring(newValue)
    end)
    State.StreakUpdated.Event:Connect(function(oldValue: number, newValue: number)
        streak.Text = tostring(newValue)
    end)
end

return LeftButtons