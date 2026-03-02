--!strict
--!optimize 2

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local FirstTimeModule = {}

local FirstTimeJoined = ReplicatedStorage:WaitForChild("FirstTimeJoined") :: RemoteEvent

local function onFirstTimeJoin()
    local gui = player:WaitForChild("PlayerGui"):WaitForChild("ScreenGui")
    local firstTimeFrame = gui:WaitForChild("FirstTimeFrame")
    local textLabel = firstTimeFrame:WaitForChild("TextLabel") :: TextLabel
    local closeButton = firstTimeFrame:WaitForChild("CloseButton") :: TextButton
    firstTimeFrame.Visible = true

    local text = (
        "Hey Stranger!\n\n" ..
        "This is Buttons Experiment\n" ..
        "The game was only released so it might be empty or unbalanced\n" ..
        "Also it's really hard to get new players together...\n" ..
        "So if you see empty lobby, just invite your friends!\n" ..
        "And I'm pretty sure that with friends this game is even more funny\n\n" ..
        "I hope you like the game and share your feedback\n\n" ..
        "Enjoy!!"
    )
    textLabel.Text = text

    closeButton.Activated:Once(function(inputObject, clickCount)
        firstTimeFrame.Visible = false
        FirstTimeJoined:FireServer()
    end)
end

function FirstTimeModule.init()
    FirstTimeJoined.OnClientEvent:Connect(onFirstTimeJoin)
end

return FirstTimeModule