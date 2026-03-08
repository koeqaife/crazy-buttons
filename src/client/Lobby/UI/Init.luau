--!strict
--!optimize 2

local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer

local UI = localPlayer.PlayerScripts.Client.Lobby.UI

return function()
    require(UI.LeftButtons).initialize()
    require(UI.Stats).initialize()
end