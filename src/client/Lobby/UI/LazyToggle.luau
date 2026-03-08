--!strict
--!optimize 2

local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer

local UI = localPlayer.PlayerScripts.Client.Lobby.UI

return function(name: "shop" | "settings")
    if name == "shop" then
        local shop = require(UI.Shop)
        shop.initialize()
        shop.window.toggle()
    end
end