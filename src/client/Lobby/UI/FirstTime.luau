--!strict
--!optimize 2

local FirstTimeModule = {}
local Players = game:GetService("Players")
local player = Players.LocalPlayer

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local State = require(player.PlayerScripts.Client.Lobby.UI.State)

local gui = player:WaitForChild("PlayerGui"):WaitForChild("ScreenGui")
local canvas = gui:WaitForChild("FirstTimeCanvas") :: CanvasGroup

local FirstTimeJoined = ReplicatedStorage:WaitForChild("FirstTimeJoined") :: RemoteEvent

local function onFirstTimeJoin()
    local window = State.createWindow("first_time_window", canvas)
    local textLabel = canvas:WaitForChild("TextLabel") :: TextLabel
    local closeButton = canvas:WaitForChild("CloseButton") :: TextButton
    window.show()

    local text = (
        "Hey " .. player.Name .. "!\n\n" ..
        "Welcome to the Buttons Experiment!\n" ..
        "The game was released 1 week ago, so you might encounter a few bugs.\n" ..
        "Gathering new players can be tricky...\n" ..
        "If the lobby looks empty, invite your friends!\n" ..
        "We'd love to hear your feedback and see what you think.\n\n" ..
        "Have fun and enjoy!!"
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