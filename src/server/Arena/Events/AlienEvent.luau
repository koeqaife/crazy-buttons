--!strict
--!optimize 2

-- Description:
-- Event where person is asked "do you like aliens?" and if they say no, they get killed
-- They get badge 100%

local Arena = game:GetService("ServerScriptService").Server.Arena
local GameState = require(Arena.GameStateModule)
local EventTypeModule = require(Arena.Events.EventType)
local TextModule = require(Arena.TextModule)
local ButtonsModule = require(Arena.ButtonsModule)
local TimerModule = require(Arena.TimerModule)

type EventType = EventTypeModule.Event

local BADGE_ID = 311683273248280
local Event = {} :: EventType

Event.chance = 0.005
Event.minRound = 4
Event.minPlayers = 7
Event.maxPerGame = 1

function Event.check()
    return true
end

function Event.onEvent()
    TimerModule.setTime(-1)

    GameState.runNewPromisePerAlive(function(player, protect, await)
        await(TextModule.showTextSequence(player, {
            { text = "I have a question for you", delay = 2 },
            { text = "Do you like aliens?", delay = 3 },
        }))

        ButtonsModule.setButtons(player, {
            { idx = 1, text = "Yes" },
            { idx = 2, text = "No" }
        })

        local clicked = await(ButtonsModule.waitForClick(player, 15))

        ButtonsModule.setButtons(player, {})
        if clicked ~= 1 then
            await(TextModule.showTextSequence(player, {
                { text = "Oh no...", delay = 2 },
                { text = "That's not nice.....", delay = 3 }
            }))
            GameState.kill(player)
        else
            await(TextModule.showTextSequence(player, {
                { text = ":D", delay = 2 },
                { text = "That's cool", delay = 3 }
            }))
        end

        GameState.rewardBadge(player, BADGE_ID):andThenCall(print, "rewardBadge: success")
    end):catch(error):await()

    return
end

return Event