--!strict
--!optimize 2

local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer
local MusicModule = require(localPlayer.PlayerScripts.Client.Shared.MusicModule)

local SharedUI = localPlayer.PlayerScripts.Client.Shared.UI
local UI = localPlayer.PlayerScripts.Client.Lobby.UI

return function()
    require(SharedUI.State).VolumeUpdated.Event:Once(function(_, value: { music: number })
        MusicModule.setMultiplier(value.music)
    end)

    require(UI.LeftButtons).initialize()
    require(UI.Stats).initialize()
    require(UI.FirstTime).initialize()
    require(SharedUI.Quests).initialize()
end