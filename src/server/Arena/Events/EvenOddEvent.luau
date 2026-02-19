--!strict
--!optimize 2

-- Description:

local Arena = game:GetService("ServerScriptService").Server.Arena
local GameState = require(Arena.GameStateModule)
local EventTypeModule = require(Arena.Events.EventType)
local TextModule = require(Arena.TextModule)
local ButtonsModule = require(Arena.ButtonsModule)
local TimerModule = require(Arena.TimerModule)

type EventType = EventTypeModule.Event

local Event = {} :: EventType

Event.chance = 0.2
Event.minPlayers = 7
Event.maxPerGame = 1

function Event.check()
    return true
end

function Event.onEvent()
    TimerModule.setTime(16)

    GameState.runPromisePerAlive(function(player, protect, await)
        return protect(TextModule.showTextSequence(player, {
            { text = "You will choose whether to press the button or not", delay = 4 },
            { text = "Once everyone has decided, I'll count the presses", delay = 4 },
            { text = "If the total is odd, all who pressed are eliminated", delay = 4 },
            { text = "If it's even, those who didn't press are eliminated", delay = 4 },
        }))
    end):await()

    GameState.runFuncPerAlive(function(player)
        ButtonsModule.setButtons(player, {
            { idx = 2 }
        })
        TextModule.setText(player, "Remember to talk with others")
    end)

    TimerModule.setTime(25)
    local _, chosen = ButtonsModule.initiateButtonChoice(25, nil, nil, nil, true):catch(error):await()
    TimerModule.setTime(-1)

    local count = 0
    local clickedPlayers: {Player} = {}

    for player, clicked in pairs(chosen) do
        if clicked ~= nil then
            count += 1
            table.insert(clickedPlayers, player)
        end
    end

    GameState.runFuncPerAlive(function(player)
        ButtonsModule.setButtons(player, {})
        TextModule.setText(player, "Time to count")
    end)
    task.wait(2)

    for i, player in ipairs(clickedPlayers) do
        GameState.addHighlightToOne(player)

        GameState.runFuncPerAlive(function(playerToShow)
            TextModule.setText(playerToShow, player.Name .. " clicked")
        end)

        task.wait(math.random(2, 4))
    end

    local isEven = count % 2 == 0

    TimerModule.setTime(10)

    GameState.runNewPromisePerAlive(function(player)
        if isEven then
            TextModule.setText(player, "It's even")
        else
            TextModule.setText(player, "It's odd")
        end
        task.wait(5)

        if (isEven and table.find(clickedPlayers, player)) or
           (not isEven and not table.find(clickedPlayers, player))
        then
            TextModule.setText(player, "You survived")
        else
            TextModule.setText(player, "You're eliminated")
            GameState.kill(player)
        end
        task.wait(5)
    end):await()

    return
end

return Event