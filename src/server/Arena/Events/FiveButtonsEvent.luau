--!strict
--!optimize 2
local ServerScriptService = game:GetService("ServerScriptService")

-- Description:

local Arena = game:GetService("ServerScriptService").Server.Arena
local TimerModule = require(ServerScriptService.Server.Arena.TimerModule)
local ButtonsModule = require(Arena.ButtonsModule)
local GameState = require(Arena.GameStateModule)
local EventTypeModule = require(Arena.Events.EventType)
local TextModule = require(Arena.TextModule)

type EventType = EventTypeModule.Event

local Event = {} :: EventType

Event.category = "rare"
Event.chance = 0.08
Event.minRound = 2
Event.maxPerGame = 2
Event.minPlayers = 3
Event.name = "five_buttons"

function Event.check()
    return true
end

function Event.onEvent()
    GameState.runPromisePerAll(function(player, protect, await)
        return protect(TextModule.showTextSequence(player, {
            { key = "intro_part1", delay = 5 },
            { key = "intro_part2", delay = 5 },
            { key = "intro_part3", delay = 5 },
        }))
    end):catch(error):await()

    local somebodyDied = false
    local counter = 0

    GameState.runFuncPerAlive(function(player)
        ButtonsModule.setButtons(player, {
            { idx = 1, inputDisabled = true },
            { idx = 2, inputDisabled = true },
            { idx = 3, inputDisabled = true },
            { idx = 4, inputDisabled = true },
            { idx = 5, inputDisabled = true },
        }, nil, false)
    end)

    while not somebodyDied or counter < 5 do
        local randomPlayer = GameState.pickOnePlayer()
        GameState.runFuncPerAlive(function(player)
            if counter == 0 then
                return TextModule.setText(player, "first_player", { player = randomPlayer })
            end
            TextModule.setText(player, "next_player", { player = randomPlayer })
        end)

        ButtonsModule.updateButtons(randomPlayer, {
            { idx = 1, inputDisabled = false },
            { idx = 2, inputDisabled = false },
            { idx = 3, inputDisabled = false },
            { idx = 4, inputDisabled = false },
            { idx = 5, inputDisabled = false },
        }, nil)

        TimerModule.setTime(15)
        local clicked = GameState.protectedAwait(randomPlayer, ButtonsModule.waitForClick(randomPlayer, 15))
        if clicked ~= nil then
            GameState.runFuncPerAlive(function(player)
                ButtonsModule.updateButtons(player, {
                    { idx = clicked, disabled = true },
                }, nil)
            end)
        end
        TimerModule.setTime(-1)

        if clicked == nil or math.random(1, 5) == 1 then
            GameState.kill(randomPlayer)
            somebodyDied = true
        end

        GameState.runFuncPerAlive(function(player)
            ButtonsModule.updateButtons(player, {
                { idx = 1, inputDisabled = true },
                { idx = 2, inputDisabled = true },
                { idx = 3, inputDisabled = true },
                { idx = 4, inputDisabled = true },
                { idx = 5, inputDisabled = true },
            }, nil)
        end)
        counter += 1
    end

    return
end

return Event