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
        "This is Buttons Experiment\n" ..
        "The game was only released so it might a bit buggy\n" ..
        "Also it's really hard to get new players together...\n" ..
        "So if you see empty lobby, just invite your friends!\n" ..
        "I hope you like the game and share your feedback\n\n" ..
        "Enjoy!!"
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