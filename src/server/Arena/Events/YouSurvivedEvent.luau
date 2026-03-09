--!strict
--!optimize 2
local ServerScriptService = game:GetService("ServerScriptService")
local TeleportService = game:GetService("TeleportService")

-- Description:
-- When one person is left

local Arena = game:GetService("ServerScriptService").Server.Arena
local ButtonsModule = require(ServerScriptService.Server.Arena.ButtonsModule)
local DataStoreModule = require(ServerScriptService.Server.Shared.DataStoreModule)
local GameState = require(Arena.GameStateModule)
local EventTypeModule = require(Arena.Events.EventType)
local TextModule = require(Arena.TextModule)

type EventType = EventTypeModule.Event

local LOBBY_PLACE_ID = 115379867051786
local badges = {
    [1] = 4478862295219855,
    [10] = 2597949705630302,
    [50] = 3448948393596106
}

local Event = {} :: EventType

Event.name = "you_survived"
Event.category = "end"
Event.chance = 1.0
Event.maxPlayers = 1
Event.minPlayers = 1
Event.maxPerGame = 1

function Event.check()
    return true
end

function Event.onEvent()
    local survivor = GameState.alivePlayers[1]
    table.clear(GameState.alivePlayers)

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

    task.spawn(function()
        ButtonsModule.setButtons(survivor, {
            { idx = 5, text = "Return to lobby"}
        })

        ButtonsModule.waitForClick(survivor, -1, nil):await()
        ButtonsModule.setButtons(survivor, {
            { idx = 5, text = "Teleporting...", inputDisabled = true }
        })
        TeleportService:Teleport(LOBBY_PLACE_ID, survivor)
    end)

    TextModule.showTextSequence(survivor, {
        { text = "Oh, looks like you're the one who is left", delay = 4, face = "shy" },
        { text = "You survived, congratulations!", delay = 4, face = "happy" },
    }):catch(warn):await()

    return
end

return Event