--!strict
--!optimize 2
local CoinsView = {}

local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer

local State = require(localPlayer.PlayerScripts.Client.Lobby.UI.State)

type CoinsItem = {
    value: number,
    id: string,
}

local coinsItems: {CoinsItem} = {
    {
        value = 100,
        id = "coins_100"
    },
    {
        value = 250,
        id = "coins_250"
    },
    {
        value = 500,
        id = "coins_500"
    },
    {
        value = 1000,
        id = "coins_1000"
    },
}


function CoinsView.initialize(window: State.WindowWidget)
    local coins = window.canvas:WaitForChild("Coins") :: Frame
    local gridCoins = coins:WaitForChild("Grid") :: Frame
    local coinsItemTemplate = gridCoins:WaitForChild("Template") :: TextButton
    coinsItemTemplate.Visible = false

    for _, item in ipairs(coinsItems) do
        local clone = coinsItemTemplate:Clone()
        clone.Name = item.id
        clone.Parent = gridCoins
        clone.Visible = true

        local text = clone:WaitForChild("TextLabel") :: TextLabel
        text.Text = tostring(item.value) .. "$"

        clone.Activated:Connect(function(inputObject, clickCount)
            State.BuyEvent:FireServer(item.id)
        end)
    end

    return coins
end

return CoinsView