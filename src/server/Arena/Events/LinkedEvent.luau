--!strict
--!optimize 2

-- Description:
-- Two people are linked together
-- If one of them dies, the other one dies too

local Arena = game:GetService("ServerScriptService").Server.Arena
local GameState = require(Arena.GameStateModule)
local EventTypeModule = require(Arena.Events.EventType)
local TextModule = require(Arena.TextModule)

type EventType = EventTypeModule.Event

local Event = {} :: EventType

Event.chance = 0.09
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
            { text = "Two people are gonna be linked together now", delay = 5, face = "scared" },
            { text = "If one of them dies, the other one dies too", delay = 5, face = "dead" },
            { text = "Let me think who is going to be linked", delay = 5, face = "shy" },
            { text = "The first player is...", delay = 5, face = "normal" },
        }))
    end):await()

    -- First player
    GameState.runFuncPerAll(function(player)
        return TextModule.setText(player, p1.DisplayName)
    end)
    GameState.addHighlightToOne(p1, COLOR, COLOR)
    task.wait(5)

    -- Second player
    GameState.runFuncPerAll(function(player)
        TextModule.setText(player, "The second player is...", "normal")
    end)
    task.wait(5)

    GameState.runFuncPerAll(function(player)
        return TextModule.setText(player, p2.DisplayName)
    end)
    GameState.addHighlightToOne(p2, COLOR, COLOR)
    task.wait(5)

    -- Link them together
    GameState.linkTogether(p1, p2)

    return
end

return Event