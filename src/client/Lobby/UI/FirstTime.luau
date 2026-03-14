--!strict
--!optimize 2

local FirstTimeModule = {}
local Players = game:GetService("Players")
local player = Players.LocalPlayer

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local State = require(player.PlayerScripts.Client.Shared.UI.State)

local gui = player:WaitForChild("PlayerGui"):WaitForChild("ScreenGui")
local canvas = gui:WaitForChild("FirstTimeCanvas") :: CanvasGroup

local FirstTimeJoined = ReplicatedStorage:WaitForChild("FirstTimeJoined") :: RemoteEvent

local function onFirstTimeJoin()
    local window = State.createWindow("first_time_window", canvas)
    local textLabel = canvas:WaitForChild("TextLabel") :: TextLabel
    local closeButton = canvas:WaitForChild("CloseButton") :: TextButton
    window.show()

    local text = (
        "Heyyyy " .. player.Name .. "!!\n\n" ..
        "Welcome to the Buttons Experiment!\n" ..
        "I released this game about a week ago\n" ..
        "And I keep improving it, I work everyday...\n\n" ..
        "Before you start playing you may go check shop\n" ..
        "Tap on the images to preview animations\n" ..
        "To earn more money, you can invite your friends.\n\n" ..
        "After you play don't forget to put like and leave constructive feedback!!"
    )
    textLabel.Text = text

    closeButton.Activated:Once(function(inputObject, clickCount)
        window.hide()
        FirstTimeJoined:FireServer()
    end)
end

function FirstTimeModule.initialize()
    FirstTimeJoined.OnClientEvent:Connect(onFirstTimeJoin)
end

return FirstTimeModule