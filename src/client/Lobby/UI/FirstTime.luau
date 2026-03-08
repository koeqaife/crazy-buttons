--!strict
--!optimize 2

local FirstTimeModule = {}
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local gui = player:WaitForChild("PlayerGui"):WaitForChild("ScreenGui")
local window = gui:WaitForChild("FirstTimeFrame") :: Frame

local State = require(player.PlayerScripts.Client.Lobby.UI.State)
local stackItem: State.WindowStackItem? = nil

local FirstTimeJoined = ReplicatedStorage:WaitForChild("FirstTimeJoined") :: RemoteEvent

local function ensureStackItem(): State.WindowStackItem
    if stackItem == nil then
        local new: State.WindowStackItem = {
            frame = window,
            closeFunc = function()
                window.Visible = false
            end
        }
        stackItem = new
        return new
    else
        return stackItem
    end
end

local function onFirstTimeJoin()
    local textLabel = window:WaitForChild("TextLabel") :: TextLabel
    local closeButton = window:WaitForChild("CloseButton") :: TextButton
    window.Visible = true

    local text = (
        "Hey " .. player.Name .. "!\n\n" ..
        "Welcome to the Buttons Experiment!\n" ..
        "The game is freshly released, so you might encounter a few bugs.\n" ..
        "Gathering new players can be tricky...\n" ..
        "If the lobby looks empty, invite your friends!\n" ..
        "We'd love to hear your feedback and see what you think.\n\n" ..
        "Have fun and enjoy!!"
    )
    textLabel.Text = text
    State.addToStack(ensureStackItem())

    closeButton.Activated:Once(function(inputObject, clickCount)
        State.removeFromStack(ensureStackItem())
        window.Visible = false
        FirstTimeJoined:FireServer()
    end)
end

function FirstTimeModule.initialize()
    FirstTimeJoined.OnClientEvent:Connect(onFirstTimeJoin)
end

return FirstTimeModule