--!strict
--!optimize 2
local LeftButtons = {}

local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer

local window = localPlayer:WaitForChild("PlayerGui"):WaitForChild("ScreenGui"):WaitForChild("LeftButtons") :: Frame

local State = require(localPlayer.PlayerScripts.Client.Lobby.UI.State)
local lazyToggle = require(localPlayer.PlayerScripts.Client.Lobby.UI.LazyToggle)

function LeftButtons.initialize()
    local settingsButton = window:WaitForChild("SettingsButton") :: TextButton
    local shopButton = window:WaitForChild("ShopButton") :: TextButton

    shopButton.Activated:Connect(function(inputObject, clickCount)
        lazyToggle("shop")
    end)
end

return LeftButtons