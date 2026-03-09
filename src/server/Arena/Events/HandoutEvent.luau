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

Event.category = "rare"
Event.chance = 0.10
Event.minRound = 3
Event.minPlayers = 3
Event.maxPerGame = 8

function Event.check()
    return true
end

function Event.onEvent()
    GameState.runFuncPerDead(function(player)
        TextModule.setText(player, "Someone will get a gift", "laughing")
    end)

    GameState.runPromisePerAlive(function(player, protect, await)
        return protect(TextModule.showTextSequence(player, {
            { text = "One very lucky player will get a gift now", delay = 5, face = "happy" },
            { text = "I think it's gonna be.......", delay = 4, face = "scared" },
        }))
    end):catch(error):await()

    local randomPlayer = GameState.pickOnePlayer()

    GameState.runFuncPerDead(function(player)
        TextModule.setText(player, randomPlayer.DisplayName .. " got a gift", "laughing")
    end)

    GameState.runNewPromisePerAlive(function(player, protect, await)
        if player == randomPlayer then
            KillToolModule.giveTool(player)
            await(TextModule.showTextSequence(player, {
                { text = "You!", delay = 2.5, face = "happy" },
                { text = "Click on the button that appeared", delay = 5, face = "shy" },
                { text = "And then click on somebody cool!!", delay = 5, face = "no_mouth" },
                { text = "Very pretty confetti is gonna spawn", delay = 5, face = "laughing" },
            }))
        else
            GameState.addRewardTo(player, 1)
            await(TextModule.showTextSequence(player, {
                { text = randomPlayer.DisplayName, delay = 2.5, face = "normal" },
                { text = "They have a cool gift now", delay = 5, face = "happy" },
                { text = "That's cool, right?", delay = 5, face = "shy" },
                { text = "Good luck.", delay = 5, face = "scared" },
            }))
        end
    end):catch(error):await()

    return
end

return Event