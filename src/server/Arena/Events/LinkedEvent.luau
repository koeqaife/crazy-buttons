--!strict
--!optimize 2
local ServerScriptService = game:GetService("ServerScriptService")

-- Description:
-- Two people are linked together
-- If one of them dies, the other one dies too

local Arena = game:GetService("ServerScriptService").Server.Arena
local LinksModule = require(ServerScriptService.Server.Arena.LinksModule)
local MiscModule = require(ServerScriptService.Server.Arena.MiscModule)
local PlayersModule = require(ServerScriptService.Server.Arena.PlayersModule)
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
    local randomPlayers = PlayersModule.pickPlayers(2)
    local p1 = randomPlayers[1]
    local p2 = randomPlayers[2]

    PlayersModule.runPromisePerAll(function(player, protect)
        return protect(TextModule.showTextSequence(player, {
            { key = "intro_part1", delay = 5 },
            { key = "intro_part2", delay = 5 },
            { key = "intro_part3", delay = 5 },
            { key = "first_player_is", delay = 5 },
        }))
    end):await()

    PlayersModule.runFuncPerAll(function(player)
        TextModule.setText(player, "player", { player = p1 })
    end)
    MiscModule.addHighlightToOne(p1, COLOR, COLOR)
    TextModule.setToast(p1, "When 4 subjects are left, you get unlinked", 5)
    logAction(p1, "linked")
    task.wait(5)

    PlayersModule.runFuncPerAll(function(player)
        TextModule.setText(player, "second_player_is")
    end)
    task.wait(5)

    PlayersModule.runFuncPerAll(function(player)
        TextModule.setText(player, "player", { player = p2 })
    end)
    MiscModule.addHighlightToOne(p2, COLOR, COLOR)
    logAction(p2, "linked")
    TextModule.setToast(p2, "When 4 subjects are left, you get unlinked", 5)
    task.wait(5)

    LinksModule.linkTogether(p1, p2)

    return
end

return Event