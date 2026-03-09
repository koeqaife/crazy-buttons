--!strict
--!optimize 2

-- Description:
-- Event that is always first
-- Kills those who didn't click the button

local Arena = game:GetService("ServerScriptService").Server.Arena
local GameState = require(Arena.GameStateModule)
local EventTypeModule = require(Arena.Events.EventType)
local TextModule = require(Arena.TextModule)
local ButtonsModule = require(Arena.ButtonsModule)

type EventType = EventTypeModule.Event

local Event = {} :: EventType

Event.chance = 1.0
Event.maxRound = 1

function Event.check()
    return true
end

function Event.onEvent()
    GameState.runPromisePerAlive(function(player, protect, await)
        return protect(TextModule.showTextSequence(player, {
            { text = "Hey " .. player.DisplayName .. "!", delay = 4, face = "shy" },
            { text = "This is a Button Experiment", delay = 5, face = "normal" },
            { text = "You're gonna be tested in different scenarios", delay = 6, face = "scared" },
            { text = "Some of them will be easy, some of them will be hard", delay = 7, face = "dead" },
            { text = "Let's begin", delay = 3, face = "happy" },
        }))
    end):catch(error):await()

    return
end

return Event