--!strict
--!optimize 2

-- Description:
-- Event where one random person is gonna be killed if no one will sacrifice themselves

local Arena = game:GetService("ServerScriptService").Server.Arena
local GameState = require(Arena.GameStateModule)
local EventTypeModule = require(Arena.Events.EventType)
local TextModule = require(Arena.TextModule)
local ButtonsModule = require(Arena.ButtonsModule)
local TimerModule = require(Arena.TimerModule)

type EventType = EventTypeModule.Event

local Event = {} :: EventType

Event.chance = 0.09
Event.minRound = 2
Event.maxPerGame = 2
Event.minPlayers = 3

function Event.check()
    return true
end

function Event.onEvent()
    TimerModule.setTime(5)
    local randomPlayer = GameState.alivePlayers[math.random(1, #GameState.alivePlayers)]

    GameState.runPromisePerAlive(function(player, protect)
        if player == randomPlayer then
            return protect(TextModule.showTextSequence(player, {
                { text = "You have been chosen...", delay = 2.5 },
                { text = "People will decide your fate", delay = 2.5 }
            }))
        else
            return protect(TextModule.showTextSequence(player, {
                { text = randomPlayer.Name .. " has been chosen...", delay = 2.5 },
                { text = "Will someone sacrifice themselves to save them?", delay = 2.5 }
            }))
        end
    end):catch(error):await()

    local toKill: {Player} = {}

    GameState.addHighlightTo({randomPlayer})

    TimerModule.setTime(30)
    GameState.runNewPromisePerAlive(function(player, protect, await)
        if player == randomPlayer then
            return
        end

        TextModule.setText(player, "Press to save " .. player.Name)
        ButtonsModule.setButtons(player, {
            { idx = 1, text = "Sacrifice yourself" }
        })
        local clicked = await(ButtonsModule.waitForIdxClick(player, 30, 1))

        ButtonsModule.setButtons(player, {})

        if clicked then
            TextModule.setText(player, "Your choice cannot be undone")
            table.insert(toKill, player)
            task.wait(3)
        end
    end):catch(error):await()

    local playerMustBeKilled = #toKill == 0

    TimerModule.setTime(5)
    GameState.runFuncPerAlive(function(player)
        if playerMustBeKilled then
            if player == randomPlayer then
                TextModule.setText(player, "You're eliminated")
                GameState.kill(player)
            else
                TextModule.setText(player, randomPlayer.Name .. " is eliminated")
            end
        else
            if player == randomPlayer then
                TextModule.setText(player, "Somebody saved you")
            elseif table.find(toKill, player) then
                TextModule.setText(player, "You saved " .. randomPlayer.Name)
                GameState.kill(player)
            else
                TextModule.setText(player, randomPlayer.Name .. " was saved!")
            end
        end
    end)
    task.wait(5)

    GameState.removeHighlightFromAll()

    return
end

return Event