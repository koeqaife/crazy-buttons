--!strict
--!optimize 2

-- Description:
-- Event where two random people are gonna be killed if no one will sacrifice themselves

local Arena = game:GetService("ServerScriptService").Server.Arena
local GameState = require(Arena.GameStateModule)
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
    local randomPlayers = GameState.pickPlayers(2)
    local p1 = randomPlayers[1]
    local p2 = randomPlayers[2]

    GameState.runFuncPerDead(function(player)
        TextModule.setText(player, "dead_intro", { p1 = p1, p2 = p2 })
    end)

    GameState.runPromisePerAlive(function(player, protect)
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

    local toKill: { Player } = {}

    GameState.addHighlightTo(randomPlayers)

    TimerModule.setTime(30)
    GameState.runNewPromisePerAlive(function(player, protect, await)
        if table.find(randomPlayers, player) then
            return
        end

        TextModule.setText(player, "press_to_save")
        ButtonsModule.setButtons(player, {
            { idx = 1, text = "Sacrifice yourself" }
        })
        local clicked = await(ButtonsModule.waitForIdxClick(player, 30, 1))

        ButtonsModule.setButtons(player, {})

        if clicked then
            GameState.addRewardTo(player, 8)
            TextModule.setText(player, "choice_cannot_be_undone")
            table.insert(toKill, player)
            task.wait(3)
        end
    end):catch(error):await()

    local playerMustBeKilled = #toKill == 0

    GameState.runFuncPerAll(function(player)
        GameState.addRewardTo(player, 1)
        if playerMustBeKilled then
            if table.find(randomPlayers, player) then
                TextModule.setText(player, "you_are_eliminated")
                GameState.kill(player)
            else
                TextModule.setText(player, "they_are_eliminated", { p1 = p1, p2 = p2 })
            end
        else
            if table.find(randomPlayers, player) then
                TextModule.setText(player, "you_are_saved")
            elseif table.find(toKill, player) then
                TextModule.setText(player, "you_saved_them")
                GameState.kill(player)
            else
                TextModule.setText(player, "they_were_saved", { p1 = p1, p2 = p2 })
            end
        end
    end)
    task.wait(5)

    GameState.removeHighlightFromAll()

    return
end

return Event