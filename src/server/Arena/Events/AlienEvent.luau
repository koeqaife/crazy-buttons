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

type EventType = EventTypeModule.Event

local BADGE_ID = 311683273248280
local Event = {} :: EventType

Event.chance = 0.005
Event.minRound = 4
Event.minPlayers = 7
Event.maxPerGame = 1
Event.category = "rare"
Event.name = "alien"

function Event.check()
    return true
end

function Event.onEvent()
    GameState.runFuncPerDead(function(player)
        TextModule.setText(player, "secret_question")
    end)

    GameState.runNewPromisePerAlive(function(player, protect, await)
        await(TextModule.showTextSequence(player, {
            { key = "question_for_you", delay = 4 },
            { key = "question_like_aliens", delay = 4 },
        }))

        ButtonsModule.setButtons(player, {
            { idx = 1, text = "Yes" },
            { idx = 2, text = "No" }
        })

        local clicked = await(ButtonsModule.waitForClick(player, 15))

        ButtonsModule.setButtons(player, {})
        GameState.rewardBadge(player, BADGE_ID):andThenCall(print, "rewardBadge: success")

        if clicked ~= 1 then
            await(TextModule.showTextSequence(player, {
                { key = "oh_no", delay = 2 },
                { key = "unamused", delay = 3 }
            }))
            GameState.kill(player)
        else
            await(TextModule.showTextSequence(player, {
                { key = "happy_face", delay = 2 },
                { key = "that_is_cool", delay = 3 }
            }))
        end

        GameState.addRewardTo(player, 5)
    end):catch(error):await()

    return
end

return Event