--!strict
--!optimize 2

-- Description:
-- Event where you have time to prepare (15 seconds)
-- And after prepare time you have 2 seconds to click fast
-- But not just click, there is a chance you don't have to click
-- And even terminal text has two different variants
-- On tests it was not too hard but also not too easy

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Arena = game:GetService("ServerScriptService").Server.Arena
local GameState = require(Arena.GameStateModule)
local EventTypeModule = require(Arena.Events.EventType)
local TextModule = require(Arena.TextModule)
local ButtonsModule = require(Arena.ButtonsModule)
local TimerModule = require(Arena.TimerModule)
local Promise = require(ReplicatedStorage.Shared.Promise)

type EventType = EventTypeModule.Event

local Event = {} :: EventType

Event.chance = 0.10
Event.minPlayers = 4
Event.maxPerGame = 3

function Event.check()
    return true
end

function Event.onEvent()
    return Promise.new(function(resolve, reject, onCancel)
        -- 1 -> click required
        -- 2 -> click kills
        local randomAction = math.random(1, 2)
        -- 1 -> button says to click
        -- 2 -> button says to not click
        local variant = math.random(1, 2)

        TimerModule.setTime(15)
        GameState.runPromisePerAlive(function(player, protect)
            return protect(TextModule.showTextSequence(player, {
                { text = "Now you will have to click or not the button", delay = 3 },
                { text = "But you will not have much time", delay = 3 }, -- 6s
                { text = "Only two seconds", delay = 3 }, -- 9s
                { text = "Be ready", delay = 3 }, -- 12s
                { text = "3...", delay = 1 }, -- 13s
                { text = "2...", delay = 1 }, -- 14s
                { text = "1...", delay = 1 }, -- 15s
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

            TextModule.setText(player, screenText)
        end)

        local _, chosen = ButtonsModule.initiateButtonChoice(2.5):catch(error):await()

        GameState.runFuncPerAlive(function(player)
            ButtonsModule.setButtons(player, {})
        end)
        TimerModule.setTime(5)
        GameState.runNewPromisePerAlive(function(player)
            local clicked = chosen[player] ~= nil

            if randomAction == 1 and not clicked then
                TextModule.setText(player, "You should've clicked")
                GameState.kill(player)
            elseif randomAction == 2 and clicked then
                TextModule.setText(player, "You shouldn't have to click")
                GameState.kill(player)
            else
                TextModule.setText(player, "You survived")
            end
        end):catch(error):await()
        task.wait(5)

        resolve()
    end)
end

return Event