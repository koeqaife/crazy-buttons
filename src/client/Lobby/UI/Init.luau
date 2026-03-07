--!strict
--!optimize 2

local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer

local UI = localPlayer.PlayerScripts.Client.Lobby.UI

return function()
    require(UI.Shop).initialize()
end