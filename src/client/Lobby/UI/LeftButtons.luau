--!strict
--!optimize 2
local LeftButtons = {}

local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer

local window = localPlayer:WaitForChild("PlayerGui"):WaitForChild("ScreenGui"):WaitForChild("LeftButtons") :: Frame

local lazyToggle = require(localPlayer.PlayerScripts.Client.Lobby.UI.LazyToggle)

function LeftButtons.initialize()
    local volumeButton = window:WaitForChild("VolumeButton") :: TextButton
    local shopButton = window:WaitForChild("ShopButton") :: TextButton

    shopButton.Activated:Connect(function(inputObject, clickCount)
        lazyToggle("shop")
    end)
    volumeButton.Activated:Connect(function(inputObject, clickCount)
        lazyToggle("volume")
    end)
end

return LeftButtons