--!strict
--!optimize 2

local LobbyModule = {}

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local InQueueLabelEvent: RemoteEvent = ReplicatedStorage:WaitForChild("InQueueLabel")

local Players = game:GetService("Players")
local StarterPlayer = game:GetService("StarterPlayer")
local Toasts = require(StarterPlayer.StarterPlayerScripts.Client.Shared.UI.Toasts)

local CustomPromptModule = require(Players.LocalPlayer.PlayerScripts.Client.Shared.CustomPromptModule)
local MusicModule = require(Players.LocalPlayer.PlayerScripts.Client.Shared.MusicModule)

local UIInit = require(Players.LocalPlayer.PlayerScripts.Client.Lobby.UI.Init)

function LobbyModule.init()
    CustomPromptModule.onLoad()
    MusicModule.init()
    UIInit()

    InQueueLabelEvent.OnClientEvent:Connect(function(visible)
        if visible then
            Toasts.show("in_queue", "Currently in queue")
        else
            Toasts.hide("in_queue")
        end
    end)
end

return LobbyModule
