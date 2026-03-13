--!strict
--!optimize 2

local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer

local UI = localPlayer.PlayerScripts.Client.Lobby.UI

return function(name: "shop" | "volume")
    if name == "shop" then
        local shop = require(UI.Shop.Window)
        shop.initialize()
        shop.window.toggle()
    elseif name == "volume" then
        local volume = require(UI.Volume)
        volume.initialize()
        volume.window.toggle()
    end
end