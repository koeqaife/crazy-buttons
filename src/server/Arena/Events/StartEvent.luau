--!strict
--!optimize 2
local ServerScriptService = game:GetService("ServerScriptService")

-- Description:
-- Event that is always first
-- Kills those who didn't click the button

local Arena = game:GetService("ServerScriptService").Server.Arena
local DataStoreModule = require(ServerScriptService.Server.Shared.DataStoreModule)
local ButtonsModule = require(Arena.ButtonsModule)
local GameState = require(Arena.GameStateModule)
local EventTypeModule = require(Arena.Events.EventType)
local TextModule = require(Arena.TextModule)

type EventType = EventTypeModule.Event

local Event = {} :: EventType

Event.chance = 1.0
Event.maxRound = 1
Event.name = "start"

function Event.check()
    return true
end

function Event.onEvent()
    local promise = GameState.runPromisePerAlive(function(player, protect, await)
        return protect(TextModule.showTextSequence(player, {
            { key = "intro_hey", data = { player = player }, delay = 4 },
            { key = "intro_button_experiment", delay = 5 },
            { key = "intro_tested", delay = 6 },
            { key = "intro_easy_hard", delay = 7 },
            { key = "intro_begin", delay = 3 },
        }))
    end):catch(error)

    GameState.runFuncPerAlive(function(player)
        ButtonsModule.setButtons(player, {
            { idx = 5, text = "Skip" }
        })
    end)

    ButtonsModule.initiateButtonChoice(25, nil, nil, nil, true, GameState.alivePlayers):catch(error):await()
    GameState.cancelAll()
    promise:cancel()

    GameState.runFuncPerAlive(function(player)
        DataStoreModule.increaseKey(player, "timesPlayed", 1)
    end)

    return
end

return Event