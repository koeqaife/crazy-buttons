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

type EventType = EventTypeModule.Event

local Event = {} :: EventType

Event.chance = 1.0
Event.maxRound = 1

function Event.check()
    return true
end

function Event.onEvent()
    GameState.runPromisePerAlive(function(player, protect, await)
        return protect(TextModule.showTextSequence(player, {
            { text = "Hey " .. player.DisplayName .. "!", delay = 4, face = "shy" },
            { text = "This is a Button Experiment", delay = 5, face = "normal" },
            { text = "You're gonna be tested in different scenarios", delay = 6, face = "scared" },
            { text = "Some of them will be easy, some of them will be hard", delay = 7, face = "dead" },
            { text = "Let's start with something simple", delay = 5, face = "no_mouth" },
        }))
    end):catch(error):await()

    GameState.runNewPromisePerAlive(function(player, protect, await)
        TextModule.setText(player, "You see this button?\nDo whatever it says", "click_button_icon")
        ButtonsModule.setButtons(player, {{ idx = 1, text = "Press me!" }})

        local clicked = await(ButtonsModule.waitForClick(player, 15))

        ButtonsModule.setButtons(player, {})
        if clicked then
            await(TextModule.showTextSequence(player, {
                { text = "Good, you can follow simple instructions", delay = 6, face = "happy" },
                { text = "That's already more than some people", delay = 5, face = "laughing" },
                { text = "Let's see how long you last", delay = 5, face = "no_mouth" }
            }))
        else
            await(TextModule.showTextSequence(player, {
                { text = "Oh, so you're ignoring me?", delay = 3, face = "angry" },
                { text = "That's not nice...", delay = 3, face = "unamused" }
            }))
            GameState.kill(player)
        end
    end):catch(error):await()

    GameState.runPromisePerAlive(function(player, protect)
        return protect(TextModule.showTextSequence(player, {
            { text = "Before we start you should remember a few rules", delay = 5, face = "nerd" },
            { text = "What you see might kill you", delay = 5, face = { text = "1" } },
            { text = "What you hear might lie to you", delay = 5, face = { text = "2" } },
            { text = "What you do might betray you", delay = 5, face = { text = "3" } },
            { text = "Let's begin", delay = 5, face = "shy" },
        }))
    end):catch(error):await()

    return
end

return Event