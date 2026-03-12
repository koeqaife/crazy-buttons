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

Event.name = "even_odd"
Event.category = "social"
Event.chance = 0.06
Event.minPlayers = 7
Event.maxPerGame = 1

function Event.check()
    return true
end

function Event.onEvent()
    GameState.runPromisePerDead(function(player, protect, await)
        return protect(TextModule.showTextSequence(player, {
            { key = "intro_dead", delay = 5 },
            { key = "intro_counting", delay = 5 },
            { key = "intro_odd", delay = 5 },
            { key = "intro_even", delay = 5 },
        }))
    end):andThen(function() end)

    GameState.runPromisePerAlive(function(player, protect, await)
        return protect(TextModule.showTextSequence(player, {
            { key = "intro_alive", delay = 5 },
            { key = "intro_counting", delay = 5 },
            { key = "intro_odd", delay = 5 },
            { key = "intro_even", delay = 5 },
        }))
    end):await()

    GameState.runFuncPerAlive(function(player)
        ButtonsModule.setButtons(player, {
            { idx = 2 }
        })
        TextModule.setText(player, "remember_to_talk")
    end)

    TimerModule.setTime(30)
    local _, chosen = ButtonsModule.initiateButtonChoice(30, nil, function(player, idx)
        ButtonsModule.updateButtons(player, {
            { idx = 2, text = if idx ~= nil then "Pressed" else "" }
        })
    end, nil, true):catch(error):await()

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
        TextModule.setText(player, "time_to_count")
    end)
    task.wait(2)

    for _, player in ipairs(clickedPlayers) do
        GameState.addHighlightToOne(player)

        GameState.runFuncPerAlive(function(playerToShow)
            TextModule.setText(playerToShow, "player_clicked", { player = player })
        end)

        task.wait(math.random(2, 4))
    end

    local isEven = count % 2 == 0

    GameState.runNewPromisePerAlive(function(player)
        if isEven then
            TextModule.setText(player, "count_even")
        else
            TextModule.setText(player, "count_odd")
        end
        task.wait(5)
        GameState.addRewardTo(player, 3)

        if (isEven and table.find(clickedPlayers, player)) or
           (not isEven and not table.find(clickedPlayers, player))
        then
            GameState.addRewardTo(player, 4)
            TextModule.setText(player, "you_survived")
        else
            TextModule.setText(player, "you_are_eliminated")
            GameState.kill(player)
        end
        task.wait(5)
    end):await()

    return
end

return Event