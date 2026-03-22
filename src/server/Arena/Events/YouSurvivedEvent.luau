--!strict
--!optimize 2
local ServerScriptService = game:GetService("ServerScriptService")
local TeleportService = game:GetService("TeleportService")

-- Description:
-- When one person is left

local Arena = game:GetService("ServerScriptService").Server.Arena
local ButtonsModule = require(ServerScriptService.Server.Arena.ButtonsModule)
local LinksModule = require(ServerScriptService.Server.Arena.LinksModule)
local PlayersModule = require(ServerScriptService.Server.Arena.PlayersModule)
local RewardsModule = require(ServerScriptService.Server.Arena.RewardsModule)
local DataStoreModule = require(ServerScriptService.Server.Shared.DataStoreModule)
local EventTypeModule = require(Arena.Events.EventType)
local TextModule = require(Arena.TextModule)

local logAction = require(ServerScriptService.Server.Shared.QuestsModule).logAction

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
    local survivor = PlayersModule.alivePlayers[1]
    table.clear(PlayersModule.alivePlayers)

    PlayersModule.runFuncPerDead(function(player)
        TextModule.setText(player, "survivor_made_it", { survivor = survivor })
    end)

    DataStoreModule.increaseKey(survivor, "survives", 1)

    local survives = DataStoreModule.getNumber(survivor, "survives")
    for surviveCount, badgeId in pairs(badges) do
        if survives >= surviveCount then
            RewardsModule.rewardBadge(survivor, badgeId):catch(warn):await()
        end
    end
    RewardsModule.addRewardTo(survivor, 5)
    RewardsModule.flushReward(survivor)
    logAction(survivor, "survive_streak")
    logAction(survivor, "survive")
    if LinksModule.wasLinked[survivor] then
        logAction(survivor, "linked_win")
    end

    task.spawn(function()
        ButtonsModule.setButtons(survivor, {
            { idx = 5, text = "Return to lobby" }
        })

        ButtonsModule.waitForClick(survivor, -1, nil):await()
        ButtonsModule.setButtons(survivor, {
            { idx = 5, text = "Teleporting...", inputDisabled = true }
        })
        TeleportService:Teleport(LOBBY_PLACE_ID, survivor)
    end)

    TextModule.showTextSequence(survivor, {
        { key = "survivor_one_left", delay = 4 },
        { key = "survivor_congratulations", delay = 4 },
    }):catch(warn):await()

    return true
end

return Event