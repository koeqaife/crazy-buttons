--!strict
--!optimize 2

-- Description:
-- Gives a weapon to one random player

local Arena = game:GetService("ServerScriptService").Server.Arena
local KillToolModule = require(Arena.KillToolModule)
local GameState = require(Arena.GameStateModule)
local EventTypeModule = require(Arena.Events.EventType)
local TextModule = require(Arena.TextModule)

type EventType = EventTypeModule.Event

local Event = {} :: EventType

Event.chance = 0.10
Event.minRound = 3
Event.minPlayers = 3
Event.maxPerGame = 8

function Event.check()
    return true
end

function Event.onEvent()
    GameState.runFuncPerDead(function(player)
        TextModule.setText(player, "Someone will get a gift")
    end)

    GameState.runPromisePerAlive(function(player, protect, await)
        return protect(TextModule.showTextSequence(player, {
            { text = "One very lucky player will get a gift now", delay = 4 },
            { text = "I think it's gonna be.......", delay = 4 },
        }))
    end):catch(error):await()

    local randomPlayer = GameState.pickOnePlayer()

    GameState.runFuncPerDead(function(player)
        TextModule.setText(player, randomPlayer.Name .. " got a gift")
    end)

    GameState.runNewPromisePerAlive(function(player, protect, await)
        if player == randomPlayer then
            KillToolModule.giveTool(player)
            await(TextModule.showTextSequence(player, {
                { text = "You!", delay = 2.5 },
                { text = "Click on the button that appeared", delay = 3 },
                { text = "And then click on somebody cool!!", delay = 3 },
                { text = "Very pretty confetti is gonna spawn", delay = 3 },
            }))
        else
            await(TextModule.showTextSequence(player, {
                { text = randomPlayer.Name, delay = 2.5 },
                { text = "They have a cool gift now", delay = 3 },
                { text = "That's cool, right?", delay = 3 },
                { text = "Good luck.", delay = 3 },
            }))
        end
    end):catch(error):await()

    return
end

return Event