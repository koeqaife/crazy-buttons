--!strict
--!optimize 2

-- Description:
-- Event where players will have to choose whether to press the button or not
-- If the total amount of presses is odd, those who pressed are eliminated
-- If it's even, those who didn't press are eliminated

local Arena = game:GetService("ServerScriptService").Server.Arena
local GameState = require(Arena.GameStateModule)
local EventTypeModule = require(Arena.Events.EventType)
local TextModule = require(Arena.TextModule)
local ButtonsModule = require(Arena.ButtonsModule)
local TimerModule = require(Arena.TimerModule)

type EventType = EventTypeModule.Event

local Event = {} :: EventType

Event.chance = 0.06
Event.minPlayers = 10
Event.maxPerGame = 1

function Event.check()
    return true
end

function Event.onEvent()
    GameState.runPromisePerDead(function(player, protect, await)
        return protect(TextModule.showTextSequence(player, {
            { text = "They will choose whether to press the button or not", delay = 5, face = "even_odd_event_icon" },
            { text = "Once everyone has decided, I'll count the presses", delay = 5, face = "nerd" },
            { text = "If the total is odd, all who pressed are eliminated", delay = 5, face = "even_odd_event_icon" },
            { text = "If it's even, those who didn't press are eliminated", delay = 5, face = "even_odd_event_icon" },
        }))
    end):andThen(function() end)

    GameState.runPromisePerAlive(function(player, protect, await)
        return protect(TextModule.showTextSequence(player, {
            { text = "You will choose whether to press the button or not", delay = 5, face = "even_odd_event_icon" },
            { text = "Once everyone has decided, I'll count the presses", delay = 5, face = "nerd" },
            { text = "If the total is odd, all who pressed are eliminated", delay = 5, face = "even_odd_event_icon" },
            { text = "If it's even, those who didn't press are eliminated", delay = 5, face = "even_odd_event_icon" },
        }))
    end):await()

    GameState.runFuncPerAlive(function(player)
        ButtonsModule.setButtons(player, {
            { idx = 2 }
        })
        TextModule.setText(player, "Remember to talk with others", "shy")
    end)

    TimerModule.setTime(45)
    local _, chosen = ButtonsModule.initiateButtonChoice(45, nil, nil, nil, true):catch(error):await()

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
        TextModule.setText(player, "Time to count", "scared")
    end)
    task.wait(2)

    for i, player in ipairs(clickedPlayers) do
        GameState.addHighlightToOne(player)

        GameState.runFuncPerAlive(function(playerToShow)
            TextModule.setText(playerToShow, player.Name .. " clicked", "normal")
        end)

        task.wait(math.random(2, 4))
    end

    local isEven = count % 2 == 0

    GameState.runNewPromisePerAlive(function(player)
        if isEven then
            TextModule.setText(player, "It's even", "normal")
        else
            TextModule.setText(player, "It's odd", "normal")
        end
        task.wait(5)

        if (isEven and table.find(clickedPlayers, player)) or
           (not isEven and not table.find(clickedPlayers, player))
        then
            TextModule.setText(player, "You survived", "happy")
        else
            TextModule.setText(player, "You're eliminated", "dead")
            GameState.kill(player)
        end
        task.wait(5)
    end):await()

    return
end

return Event