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

local badges = {
    [1] = 4478862295219855,
    [10] = 2597949705630302,
    [50] = 3448948393596106
}

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
        TextModule.setText(player, survivor.Name .. " made it to the end", "happy")
    end)

    DataStoreModule.increaseSurvives(survivor):await()

    local survives = DataStoreModule.getSurvives(survivor)
    for surviveCount, badgeId in pairs(badges) do
        if survives >= surviveCount then
            GameState.rewardBadge(survivor, badgeId):catch(warn):await()
        end
    end
    GameState.addRewardTo(survivor, 5)

    TextModule.showTextSequence(survivor, {
        { text = "Oh, looks like you're the one who is left", delay = 4, face = "shy" },
        { text = "Congratulations!", delay = 4, face = "happy" },
        { text = "But we cannot continue the experiment...", delay = 4, face = "normal" },
        { text = "So I will have to eliminate you", delay = 4, face = "scared" },
        { text = "Otherwise, there is just nowhere to go for you", delay = 4, face = "dead" },
    }):catch(warn):await()

    GameState.kill(survivor, "end_of_the_game")

    return
end

return Event