--!strict
--!optimize 2

-- Description:
-- Event where you have time to prepare (15 seconds)
-- And after prepare time you have 2 seconds to click fast
-- But not just click, there is a chance you don't have to click
-- And even terminal text has two different variants
-- On tests it was not too hard but also not too easy

local Arena = game:GetService("ServerScriptService").Server.Arena
local GameState = require(Arena.GameStateModule)
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

    GameState.runFuncPerDead(function(player)
        TextModule.setText(player, "They have reaction test with a button", "click_button_icon")
    end)

    GameState.runPromisePerAlive(function(player, protect)
        return protect(TextModule.showTextSequence(player, {
            { text = "Now you will have to click or not the button", delay = 5, face = "click_button_icon" },
            { text = "But you will not have much time", delay = 5, face = "no_mouth" },
            { text = "Only two seconds", delay = 5, face = "scared" },
            { text = "Be ready", delay = 4, face = "shy" },
            { text = "3...", delay = 1.5, face = { text = "3" }},
            { text = "2...", delay = 1.5, face = { text = "2" }},
            { text = "1...", delay = 1.5, face = { text = "1" }},
        }))
    end):catch(error):await()

    TimerModule.setTime(2)
    GameState.runFuncPerAlive(function(player)
        local buttonText
        if variant == 1 then
            buttonText = "CLICK ME"
        else
            buttonText = "DO NOT"
        end

        ButtonsModule.setButtons(player, {
            { idx = 1, text = buttonText }
        })

        local screenText
        if (randomAction == 1 and variant == 1) or
            (randomAction ~= 1 and variant == 2)
        then
            screenText = "BUTTON SAYS TRUTH"
        else
            screenText = "BUTTON SAYS LIE"
        end

        TextModule.setText(player, screenText, "click_button_icon")
    end)

    -- Longer delay for the case when player doesn't have to click
    local toWait = if randomAction == 1 then 2.5 else 4
    local _, chosen = ButtonsModule.initiateButtonChoice(toWait):catch(error):await()

    GameState.runFuncPerAlive(function(player)
        ButtonsModule.setButtons(player, {})
    end)

    GameState.runNewPromisePerAlive(function(player)
        local clicked = chosen[player] ~= nil

        GameState.addRewardTo(player, 2)
        if randomAction == 1 and not clicked then
            TextModule.setText(player, "You should've clicked", "dead")
            GameState.kill(player)
        elseif randomAction == 2 and clicked then
            TextModule.setText(player, "You shouldn't have to click", "dead")
            GameState.kill(player)
        else
            TextModule.setText(player, "You survived", "happy")
            GameState.addRewardTo(player, 4)
        end
    end):catch(error):await()
    task.wait(5)

    return
end

return Event