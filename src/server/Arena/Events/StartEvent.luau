--!strict
--!optimize 2

-- Description:
-- Event that is always first
-- Kills those who didn't click the button

local Arena = game:GetService("ServerScriptService").Server.Arena
local GameState = require(Arena.GameStateModule)
local EventTypeModule = require(Arena.Events.EventType)
local TextModule = require(Arena.TextModule)
local ButtonsModule = require(Arena.ButtonsModule)
local TimerModule = require(Arena.TimerModule)

type EventType = EventTypeModule.Event

local Event = {} :: EventType

Event.chance = 1.0
Event.maxRound = 1

function Event.check()
    return true
end

function Event.onEvent()
    TimerModule.setTime(45)

    GameState.runNewPromisePerAlive(function(player, protect, await)
        await(TextModule.showTextSequence(player, {
            { text = "Hey " .. player.DisplayName .. "!", delay = 3 }, -- 3s
            { text = "This is a Button Experiment", delay = 3 }, -- 5s
            { text = "You're gonna be tested in different scenarios", delay = 3 }, -- 8s
            { text = "Some of them will be easy, some of them will be hard", delay = 3 }, -- 11s
            { text = "Let's start with something simple", delay = 4 }, -- 15s,
            { text = "You see this button?\nDo whatever it says" }
        }))

        ButtonsModule.setButtons(player, {{ idx = 1, text = "Press me!" }})

        local clicked = await(ButtonsModule.waitForClick(player, 15)) -- 30s

        ButtonsModule.setButtons(player, {})
        if clicked then
            await(TextModule.showTextSequence(player, {
                { text = "Good, you can follow simple instructions", delay = 3 }, -- 33s
                { text = "That's already more than some people", delay = 4 }, -- 38s
                { text = "Let's see how long you last", delay = 3 }, -- 41s
                { text = "Wait for other people to finish...", delay = 2 }, -- 43s
            }))
        else
            await(TextModule.showTextSequence(player, {
                { text = "Oh, so you're ignoring me?", delay = 2 }, -- 27s
                { text = "That's not nice...", delay = 3 } -- 30s
            }))
            GameState.kill(player)
        end
    end):catch(error):await()

    TimerModule.setTime(15)

    GameState.runPromisePerAlive(function(player, protect)
        return protect(TextModule.showTextSequence(player, {
            { text = "Before we start you should remember a few rules", delay = 3 }, -- 3s
            { text = "What you see might kill you", delay = 3 }, -- 6s
            { text = "What you hear might lie to you", delay = 3 }, -- 9s
            { text = "What you do might betray you", delay = 3 }, -- 12s
            { text = "Let's begin", delay = 3 }, -- 15s
        }))
    end):catch(error):await()

    return
end

return Event