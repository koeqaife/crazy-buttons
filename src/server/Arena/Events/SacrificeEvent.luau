--!strict
--!optimize 2
local ServerScriptService = game:GetService("ServerScriptService")

-- Description:
-- Event where two random people are gonna be killed if no one will sacrifice themselves

local Arena = game:GetService("ServerScriptService").Server.Arena
local MiscModule = require(ServerScriptService.Server.Arena.MiscModule)
local PlayersModule = require(ServerScriptService.Server.Arena.PlayersModule)
local RewardsModule = require(ServerScriptService.Server.Arena.RewardsModule)
local EventTypeModule = require(Arena.Events.EventType)
local TextModule = require(Arena.TextModule)
local ButtonsModule = require(Arena.ButtonsModule)
local TimerModule = require(Arena.TimerModule)

type EventType = EventTypeModule.Event

local Event = {} :: EventType

Event.name = "sacrifice"
Event.category = "survival"
Event.chance = 0.09
Event.minRound = 3
Event.maxPerGame = 2
Event.minPlayers = 4

function Event.check()
    return true
end

function Event.onEvent()
    local randomPlayers = PlayersModule.pickPlayers(2)
    local p1 = randomPlayers[1]
    local p2 = randomPlayers[2]

    PlayersModule.runFuncPerDead(function(player)
        TextModule.setText(player, "dead_intro", { p1 = p1, p2 = p2 })
    end)

    PlayersModule.runPromisePerAlive(function(player, protect)
        if table.find(randomPlayers, player) then
            return protect(TextModule.showTextSequence(player, {
                { key = "chosen_you_1", delay = 5 },
                { key = "chosen_you_2", delay = 6 },
            }))
        else
            return protect(TextModule.showTextSequence(player, {
                { key = "chosen_others_1", delay = 6, data = { p1 = p1, p2 = p2 } },
                { key = "prompt_sacrifice", delay = 6 },
            }))
        end
    end):catch(error):await()

    local toKill: Player? = nil

    MiscModule.addHighlightTo(randomPlayers)

    TimerModule.setTime(30)
    PlayersModule.runNewPromisePerAlive(function(player, protect, await)
        if table.find(randomPlayers, player) then
            return
        end

        TextModule.setText(player, "press_to_save")
        ButtonsModule.setButtons(player, {
            { idx = 1, text = "Sacrifice yourself" }
        })
        local clicked = await(ButtonsModule.waitForIdxClick(player, 30, 1))

        ButtonsModule.setButtons(player, {})

        if clicked and toKill ~= nil then
            RewardsModule.addRewardTo(player, 8)
            TextModule.setText(player, "choice_cannot_be_undone")
            toKill = player
            PlayersModule.cancelAll()
        end
    end):catch(error):await()
    TimerModule.setTime(-1)
    task.wait(3)

    local playerMustBeKilled = toKill ~= nil

    PlayersModule.runFuncPerAll(function(player)
        RewardsModule.addRewardTo(player, 1)
        if playerMustBeKilled then
            if table.find(randomPlayers, player) then
                TextModule.setText(player, "you_are_eliminated")
                PlayersModule.kill(player)
            else
                TextModule.setText(player, "they_are_eliminated", { p1 = p1, p2 = p2 })
            end
        else
            if table.find(randomPlayers, player) then
                TextModule.setText(player, "you_are_saved")
            elseif player == toKill then
                TextModule.setText(player, "you_saved_them")
                PlayersModule.kill(player)
            else
                TextModule.setText(player, "they_were_saved", { p1 = p1, p2 = p2 })
            end
        end
    end)
    task.wait(5)

    MiscModule.removeHighlightFromAll()

    return
end

return Event