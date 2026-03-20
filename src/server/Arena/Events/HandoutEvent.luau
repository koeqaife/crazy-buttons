--!strict
--!optimize 2

-- Description:
-- Gives a weapon to one random player

local Arena = game:GetService("ServerScriptService").Server.Arena
local KillToolModule = require(Arena.KillToolModule)
local GameState = require(Arena.GameStateModule)
local EventTypeModule = require(Arena.Events.EventType)
local TextModule = require(Arena.TextModule)

type EventType = EventTypeModule.Event

local Event = {} :: EventType

Event.name = "handout"
Event.category = "rare"
Event.chance = 0.10
Event.minRound = 3
Event.minPlayers = 3
Event.maxPerGame = 8

local explained = false

function Event.check()
    return true
end

function Event.onEvent()
    GameState.runFuncPerDead(function(player)
        TextModule.setText(player, "intro_dead")
    end)

    GameState.runPromisePerAlive(function(player, protect, await)
        return protect(TextModule.showTextSequence(player, {
            { key = "intro_alive_part1", delay = 5 },
            { key = "intro_alive_part2", delay = 4 },
        }))
    end):catch(error):await()

    local randomPlayer = GameState.pickOnePlayer()

    GameState.runFuncPerDead(function(player)
        TextModule.setText(player, "dead_who_got", { player = randomPlayer })
    end)

    if not explained then
        explained = true
        GameState.runNewPromisePerAlive(function(player, protect, await)
            if player == randomPlayer then
                KillToolModule.giveTool(player)
                await(TextModule.showTextSequence(player, {
                    { key = "you_got_tool_part1", delay = 2.5 },
                    { key = "you_got_tool_part2", delay = 5 },
                    { key = "you_got_tool_part3", delay = 5 },
                    { key = "you_got_tool_part4", delay = 5 },
                }))
            else
                GameState.addRewardTo(player, 1)
                await(TextModule.showTextSequence(player, {
                    { key = "someone_got_tool_part1", delay = 2.5, data = { player = randomPlayer } },
                    { key = "someone_got_tool_part2", delay = 5 },
                    { key = "someone_got_tool_part3", delay = 5 },
                    { key = "someone_got_tool_part4", delay = 5 },
                }))
            end
        end):catch(error):await()
    else
        GameState.runFuncPerAlive(function(player)
            if player == randomPlayer then
                TextModule.setText(player, "you_got_tool_part1" )
                KillToolModule.giveTool(player)
            else
                TextModule.setText(player, "someone_got_tool_part1", { player = randomPlayer } )
                GameState.addRewardTo(player, 1)
            end
        end)
        task.wait(5)
    end

    return
end

return Event