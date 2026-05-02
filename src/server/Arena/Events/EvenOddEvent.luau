--!strict
--!optimize 2
local ServerScriptService = game:GetService("ServerScriptService")

-- Description:
-- Event where players will have to choose whether to press the button or not
-- If the total amount of presses is odd, those who pressed are eliminated
-- If it's even, those who didn't press are eliminated

local Arena = game:GetService("ServerScriptService").Server.Arena
local MiscModule = require(ServerScriptService.Server.Arena.MiscModule)
local PlayersModule = require(ServerScriptService.Server.Arena.PlayersModule)
local RewardsModule = require(ServerScriptService.Server.Arena.RewardsModule)
local EventTypeModule = require(Arena.Events.EventType)
local TextModule = require(Arena.TextModule)
local ButtonsModule = require(Arena.ButtonsModule)
local TimerModule = require(Arena.TimerModule)

type EventType = EventTypeModule.Event

local Event = {} :: EventType

Event.name = "even_odd"
Event.category = "social"
Event.chance = 0.06
Event.minPlayers = 3
Event.maxPerGame = 1
Event.minRound = 3 

function Event.check()
    return true
end

function Event.onEvent()
    PlayersModule.runPromisePerDead(function(player, protect, await)
        return protect(TextModule.showTextSequence(player, {
            { key = "intro_dead", delay = 5 },
            { key = "intro_counting", delay = 5 },
            { key = "intro_odd", delay = 5 },
            { key = "intro_even", delay = 5 },
        }))
    end):andThen(function() end)

    PlayersModule.runPromisePerAlive(function(player, protect, await)
        ButtonsModule.setButtons(player, {
            { idx = 1, disabled = true }
        })

        return protect(TextModule.showTextSequence(player, {
            { key = "intro_alive", delay = 5 },
            { key = "intro_counting", delay = 5 },
            { key = "intro_odd", delay = 5 },
            { key = "intro_even", delay = 5 },
        }))
    end):await()

    PlayersModule.runFuncPerAlive(function(player)
        ButtonsModule.setButtons(player, {
            { idx = 1, disabled = false }
        })
        TextModule.setText(player, "remember_to_talk")
    end)

    TimerModule.setTime(30)
    local _, chosen = ButtonsModule.initiateButtonChoice(30, nil, function(player, idx)
        ButtonsModule.updateButtons(player, {
            { idx = 1, text = if idx ~= nil then "Pressed" else "", highlighted = idx ~= nil }
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

    PlayersModule.runFuncPerAlive(function(player)
        ButtonsModule.setButtons(player, {})
        TextModule.setText(player, "time_to_count")
    end)
    task.wait(2)

    for _, player in ipairs(clickedPlayers) do
        MiscModule.addHighlightToOne(player)

        PlayersModule.runFuncPerAlive(function(playerToShow)
            TextModule.setText(playerToShow, "player_clicked", { player = player })
        end)

        task.wait(math.random(2, 4))
    end

    local isEven = count % 2 == 0

    PlayersModule.runNewPromisePerAlive(function(player)
        if isEven then
            TextModule.setText(player, "count_even")
        else
            TextModule.setText(player, "count_odd")
        end
        task.wait(5)
        RewardsModule.addRewardTo(player, 3)

        if (isEven and table.find(clickedPlayers, player)) or
           (not isEven and not table.find(clickedPlayers, player))
        then
            RewardsModule.addRewardTo(player, 4)
            TextModule.setText(player, "you_survived")
        else
            TextModule.setText(player, "you_are_eliminated")
            PlayersModule.kill(player)
        end
        task.wait(5)
    end):await()

    return
end

return Event