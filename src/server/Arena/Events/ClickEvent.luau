--!strict
--!optimize 2
local ServerScriptService = game:GetService("ServerScriptService")

-- Description:
-- Event where you have time to prepare (15 seconds)
-- And after prepare time you have 2 seconds to click fast
-- But not just click, there is a chance you don't have to click
-- And even terminal text has two different variants
-- On tests it was not too hard but also not too easy

local Arena = game:GetService("ServerScriptService").Server.Arena
local PlayersModule = require(ServerScriptService.Server.Arena.PlayersModule)
local RewardsModule = require(ServerScriptService.Server.Arena.RewardsModule)
local EventTypeModule = require(Arena.Events.EventType)
local TextModule = require(Arena.TextModule)
local ButtonsModule = require(Arena.ButtonsModule)
local TimerModule = require(Arena.TimerModule)

type EventType = EventTypeModule.Event

local Event = {} :: EventType

Event.name = "click"
Event.category = "reaction"
Event.chance = 0.08
Event.minPlayers = 4
Event.maxPerGame = 3

function Event.check()
    return true
end

function Event.onEvent()
    -- 1 -> click required
    -- 2 -> click kills
    local randomAction = math.random(1, 2)
    -- 1 -> button says to click
    -- 2 -> button says to not click
    local variant = math.random(1, 2)

    PlayersModule.runFuncPerDead(function(player)
        TextModule.setText(player, "reaction_test_for_dead")
    end)

    PlayersModule.runFuncPerAlive(function(player)
        ButtonsModule.setButtons(player, {
            { idx = 1, disabled = true }
        })
    end)

    PlayersModule.runPromisePerAlive(function(player, protect)
        return protect(TextModule.showTextSequence(player, {
            { key = "reaction_test", delay = 6 },
            { key = "not_much_time", delay = 6 },
            { key = "be_ready", delay = 4 },
            { key = "seconds_3", delay = 1.5 },
            { key = "seconds_2", delay = 1.5 },
            { key = "seconds_1", delay = 1.5 },
        }))
    end):catch(error):await()

    TimerModule.setTime(2)
    PlayersModule.runFuncPerAlive(function(player)
        local buttonText
        if variant == 1 then
            buttonText = "CLICK ME"
        else
            buttonText = "DO NOT"
        end

        ButtonsModule.updateButtons(player, {
            { idx = 1, text = buttonText, disabled = false }
        })

        local screenText
        if (randomAction == 1 and variant == 1) or
            (randomAction ~= 1 and variant == 2)
        then
            screenText = "button_says_truth"
        else
            screenText = "button_says_lie"
        end

        TextModule.setText(player, screenText)
    end)

    -- Longer delay for the case when player doesn't have to click
    local toWait = if randomAction == 1 then 2.5 else 4
    local _, chosen = ButtonsModule.initiateButtonChoice(toWait):catch(error):await()

    PlayersModule.runFuncPerAlive(function(player)
        ButtonsModule.setButtons(player, {})

        local clicked = chosen[player] ~= nil

        RewardsModule.addRewardTo(player, 2)
        if randomAction == 1 and not clicked then
            TextModule.setText(player, "you_had_to_click")
            PlayersModule.kill(player)
        elseif randomAction == 2 and clicked then
            TextModule.setText(player, "you_had_to_not_click")
            PlayersModule.kill(player)
        else
            TextModule.setText(player, "you_survived")
            RewardsModule.addRewardTo(player, 4)
        end
    end)
    task.wait(5)

    return
end

return Event