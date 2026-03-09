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

Event.category = "survival"
Event.chance = 0.09
Event.minRound = 2
Event.maxPerGame = 2
Event.minPlayers = 4

function Event.check()
    return true
end

function Event.onEvent()
    local randomPlayers = GameState.pickPlayers(2)

    GameState.runFuncPerDead(function(player)
        TextModule.setText(player, "They will need to sacrifice for " .. randomPlayers[1].DisplayName .. " and " .. randomPlayers[2].DisplayName, "scared")
    end)

    GameState.runPromisePerAlive(function(player, protect)
        if table.find(randomPlayers, player) then
            return protect(TextModule.showTextSequence(player, {
                { text = "You have been chosen...", delay = 5, face = "scared" },
                { text = "Someone has to sacrifice themselves to save you", delay = 6, face = "scared" }
            }))
        else
            return protect(TextModule.showTextSequence(player, {
                { text = randomPlayers[1].DisplayName .. " and " .. randomPlayers[2].DisplayName .. " are chosen.", delay = 6, face = "laughing" },
                { text = "Will you sacrifice yourself to save them?", delay = 6, face = "shy" }
            }))
        end
    end):catch(error):await()

    local toKill: {Player} = {}

    GameState.addHighlightTo(randomPlayers)

    TimerModule.setTime(30)
    GameState.runNewPromisePerAlive(function(player, protect, await)
        if table.find(randomPlayers, player) then
            return
        end

        TextModule.setText(player, "Press to save them", "shy")
        ButtonsModule.setButtons(player, {
            { idx = 1, text = "Sacrifice yourself" }
        })
        local clicked = await(ButtonsModule.waitForIdxClick(player, 30, 1))

        ButtonsModule.setButtons(player, {})

        if clicked then
            GameState.addRewardTo(player, 8)
            TextModule.setText(player, "Your choice cannot be undone", "dead")
            table.insert(toKill, player)
            task.wait(3)
        end
    end):catch(error):await()

    local playerMustBeKilled = #toKill == 0

    GameState.runFuncPerAll(function(player)
        GameState.addRewardTo(player, 1)
        if playerMustBeKilled then
            if table.find(randomPlayers, player) then
                TextModule.setText(player, "You're eliminated", "dead")
                GameState.kill(player)
            else
                TextModule.setText(player, "They are eliminated", "scared")
            end
        else
            if table.find(randomPlayers, player) then
                TextModule.setText(player, "You're saved", "happy")
            elseif table.find(toKill, player) then
                TextModule.setText(player, "You saved them", "dead")
                GameState.kill(player)
            else
                TextModule.setText(player, "They were saved!", "happy")
            end
        end
    end)
    task.wait(5)

    GameState.removeHighlightFromAll()

    return
end

return Event