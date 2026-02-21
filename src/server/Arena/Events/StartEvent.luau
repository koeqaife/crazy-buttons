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
    TimerModule.setTime(-1)

    GameState.runPromisePerAlive(function(player, protect, await)
        return protect(TextModule.showTextSequence(player, {
            { text = "Hey " .. player.DisplayName .. "!", delay = 3 },
            { text = "This is a Button Experiment", delay = 4 },
            { text = "You're gonna be tested in different scenarios", delay = 4 },
            { text = "Some of them will be easy, some of them will be hard", delay = 5 },
            { text = "Let's start with something simple", delay = 4 },
        }))
    end):catch(error):await()

    GameState.runNewPromisePerAlive(function(player, protect, await)
        TextModule.setText(player, "You see this button?\nDo whatever it says")
        ButtonsModule.setButtons(player, {{ idx = 1, text = "Press me!" }})

        local clicked = await(ButtonsModule.waitForClick(player, 15))

        ButtonsModule.setButtons(player, {})
        if clicked then
            await(TextModule.showTextSequence(player, {
                { text = "Good, you can follow simple instructions", delay = 4 },
                { text = "That's already more than some people", delay = 4 },
                { text = "Let's see how long you last", delay = 4 }
            }))
        else
            await(TextModule.showTextSequence(player, {
                { text = "Oh, so you're ignoring me?", delay = 3 },
                { text = "That's not nice...", delay = 3 }
            }))
            GameState.kill(player)
        end
    end):catch(error):await()

    GameState.runPromisePerAlive(function(player, protect)
        return protect(TextModule.showTextSequence(player, {
            { text = "Before we start you should remember a few rules", delay = 4 },
            { text = "What you see might kill you", delay = 4 },
            { text = "What you hear might lie to you", delay = 4 },
            { text = "What you do might betray you", delay = 4 },
            { text = "Let's begin", delay = 3 },
        }))
    end):catch(error):await()

    return
end

return Event