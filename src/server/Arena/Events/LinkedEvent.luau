--!strict
--!optimize 2
local ServerScriptService = game:GetService("ServerScriptService")

-- Description:
-- Two people are linked together
-- If one of them dies, the other one dies too

local Arena = game:GetService("ServerScriptService").Server.Arena
local GameState = require(Arena.GameStateModule)
local EventTypeModule = require(Arena.Events.EventType)
local TextModule = require(Arena.TextModule)

local logAction = require(ServerScriptService.Server.Shared.QuestsModule).logAction

type EventType = EventTypeModule.Event

local Event = {} :: EventType

Event.name = "linked"
Event.category = "survival"
Event.chance = 0.09
Event.minRound = 2
Event.maxPerGame = 1
Event.minPlayers = 5

local COLOR = Color3.fromRGB(56, 138, 245)

function Event.check()
    return true
end

function Event.onEvent()
    local randomPlayers = GameState.pickPlayers(2)
    local p1 = randomPlayers[1]
    local p2 = randomPlayers[2]

    GameState.runPromisePerAll(function(player, protect)
        return protect(TextModule.showTextSequence(player, {
            { key = "intro_part1", delay = 5 },
            { key = "intro_part2", delay = 5 },
            { key = "intro_part3", delay = 5 },
            { key = "first_player_is", delay = 5 },
        }))
    end):await()

    GameState.runFuncPerAll(function(player)
        TextModule.setText(player, "player", { player = p1 })
    end)
    GameState.addHighlightToOne(p1, COLOR, COLOR)
    logAction(p1, "linked")
    task.wait(5)

    GameState.runFuncPerAll(function(player)
        TextModule.setText(player, "second_player_is")
    end)
    task.wait(5)

    GameState.runFuncPerAll(function(player)
        TextModule.setText(player, "player", { player = p2 })
    end)
    GameState.addHighlightToOne(p2, COLOR, COLOR)
    logAction(p2, "linked")
    task.wait(5)

    GameState.linkTogether(p1, p2)

    return
end

return Event