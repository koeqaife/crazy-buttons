--!strict
--!optimize 2
local ServerScriptService = game:GetService("ServerScriptService")

-- Description:
-- When one person is left

local Arena = game:GetService("ServerScriptService").Server.Arena
local DataStoreModule = require(ServerScriptService.Server.Shared.DataStoreModule)
local GameState = require(Arena.GameStateModule)
local EventTypeModule = require(Arena.Events.EventType)
local TextModule = require(Arena.TextModule)

type EventType = EventTypeModule.Event

local BADGE_ID = 4478862295219855

local Event = {} :: EventType

Event.chance = 1.0
Event.maxPlayers = 1
Event.minPlayers = 1

function Event.check()
    return true
end

function Event.onEvent()
    local survivor = GameState.alivePlayers[1]

    GameState.runFuncPerDead(function(player)
        TextModule.setText(player, survivor.Name .. " made it to the end")
    end)

    TextModule.showTextSequence(survivor, {
        { text = "Oh, looks like you're the one who is left", delay = 4 },
        { text = "Congratulations!", delay = 4 },
        { text = "But we cannot continue the experiment...", delay = 4 },
        { text = "So I will have to eliminate you", delay = 4 },
        { text = "Otherwise, there is just nowhere to go for you", delay = 4 },
    }):catch(warn):await()

    DataStoreModule.increaseSurvives(survivor):await()
    GameState.rewardBadge(survivor, BADGE_ID):catch(warn):await()

    GameState.kill(survivor)

    return
end

return Event