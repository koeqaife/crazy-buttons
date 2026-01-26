--!strict
--!optimize 2

local LobbyModule = {}

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UpdatePadCount: RemoteEvent = ReplicatedStorage:WaitForChild("UpdatePadCount")
local InQueueLabelEvent: RemoteEvent = ReplicatedStorage:WaitForChild("InQueueLabel")
local PadCountdown: RemoteEvent = ReplicatedStorage:WaitForChild("PadCountdown")

local Players = game:GetService("Players")
local spr = require(ReplicatedStorage.Shared.spr)

local inQueueLabel: TextLabel = Players.LocalPlayer.PlayerGui
    :WaitForChild("ScreenGui")
    :WaitForChild("inQueueLabel")

local playerBoardText: TextLabel = workspace
    :WaitForChild("PlayerCountBoard")
    :WaitForChild("Board")
    :WaitForChild("SurfaceGui")
    :WaitForChild("playerBoardText")

local boardText = {
    players="",
    countdown=""
}

local function updateBoardText()
    if #boardText.countdown > 0 then
        playerBoardText.Text = boardText.players .. "\n" .. boardText.countdown
    else
        playerBoardText.Text = boardText.players
    end
end

function LobbyModule.init()
    UpdatePadCount.OnClientEvent:Connect(
        function(count: number, max: number)
            boardText.players = "Players " .. count .. "/" .. max
            updateBoardText()
        end
    )

    PadCountdown.OnClientEvent:Connect(
        function(state: string, reason_or_num: any)
            if state == "finished" or state == "cancel" then
                boardText.countdown = ""
            elseif state == "started" or state == "update" then
                boardText.countdown = "Starting in " .. reason_or_num .. "..."
            end
            updateBoardText()
        end
    )

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
