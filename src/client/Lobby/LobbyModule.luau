--!strict
--!optimize 2

local LobbyModule = {}

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local InQueueLabelEvent: RemoteEvent = ReplicatedStorage:WaitForChild("InQueueLabel")

local Players = game:GetService("Players")
local spr = require(ReplicatedStorage.Shared.spr)

local inQueueLabel: TextLabel = Players.LocalPlayer.PlayerGui
    :WaitForChild("ScreenGui")
    :WaitForChild("inQueueLabel")


function LobbyModule.init()
    inQueueLabel.Visible = false
    inQueueLabel.BackgroundTransparency = 1
    inQueueLabel.TextTransparency = 1

    InQueueLabelEvent.OnClientEvent:Connect(function(visible)
        if visible then
            inQueueLabel.Visible = true
            spr.target(
                inQueueLabel, 1, 4,
                { TextTransparency=0, BackgroundTransparency=0 }
            )
        else
            spr.target(
                inQueueLabel, 1, 4,
                { TextTransparency=1, BackgroundTransparency=1 }
            )
            spr.completed(inQueueLabel, function()
                if inQueueLabel.BackgroundTransparency == 1 then
                    inQueueLabel.Visible = false
                end
            end)
        end
    end)
end

return LobbyModule
