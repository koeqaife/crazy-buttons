--!strict
--!optimize 2
local ServerScriptService = game:GetService("ServerScriptService")

-- Description:

local Arena = game:GetService("ServerScriptService").Server.Arena
local MiscModule = require(ServerScriptService.Server.Arena.MiscModule)
local PlayersModule = require(ServerScriptService.Server.Arena.PlayersModule)
local RewardsModule = require(ServerScriptService.Server.Arena.RewardsModule)
local TimerModule = require(ServerScriptService.Server.Arena.TimerModule)
local ButtonsModule = require(Arena.ButtonsModule)
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
    -- My code quality got worsen lately...
    -- No idea why, but I got really really bad in this
    -- But I will try to at least make it work
    PlayersModule.runPromisePerAll(function(player, protect, await)
        return protect(TextModule.showTextSequence(player, {
            { key = "intro_part1", delay = 5 },
            { key = "intro_part2", delay = 5 },
            { key = "intro_part3", delay = 5 },
        }))
    end):catch(error):await()

    local somebodyDied = false
    local counter = 0
    local kills = math.random(1, 5)

    PlayersModule.runFuncPerAlive(function(player)
        ButtonsModule.setButtons(player, {
            { idx = 1, inputDisabled = true },
            { idx = 2, inputDisabled = true },
            { idx = 3, inputDisabled = true },
            { idx = 4, inputDisabled = true },
            { idx = 5, inputDisabled = true },
        }, false)
    end)

    while not somebodyDied or counter < 5 do
        local randomPlayer = PlayersModule.pickOnePlayer()
        PlayersModule.runFuncPerAlive(function(player)
            if counter == 0 then
                return TextModule.setText(player, "first_player", { player = randomPlayer })
            end
            TextModule.setText(player, "next_player", { player = randomPlayer })
        end)

        MiscModule.removeHighlightFromAll()
        MiscModule.addHighlightToOne(randomPlayer)
        ButtonsModule.updateButtons(randomPlayer, {
            { idx = 1, inputDisabled = false },
            { idx = 2, inputDisabled = false },
            { idx = 3, inputDisabled = false },
            { idx = 4, inputDisabled = false },
            { idx = 5, inputDisabled = false },
        })

        TimerModule.setTime(20)
        local clicked = PlayersModule.protectedAwait(randomPlayer, ButtonsModule.waitForClick(randomPlayer, 20))
        if clicked ~= nil then
            PlayersModule.runFuncPerAlive(function(player)
                ButtonsModule.updateButtons(player, {
                    { idx = clicked, disabled = true },
                })
            end)
        end
        TimerModule.setTime(-1)

        if clicked == nil or clicked == kills then
            PlayersModule.runFuncPerAlive(function(player)
                if player == randomPlayer then
                    TextModule.setText(player, "you_eliminated")
                else
                    TextModule.setText(player, "player_eliminated", { player = randomPlayer })
                end
            end)
            PlayersModule.kill(randomPlayer)
            somebodyDied = true
        else
            RewardsModule.addRewardTo(randomPlayer, 2.5)
            PlayersModule.runFuncPerAlive(function(player)
                TextModule.setText(player, "button_safe")
            end)
        end

        PlayersModule.runFuncPerAlive(function(player)
            ButtonsModule.updateButtons(player, {
                { idx = 1, inputDisabled = true },
                { idx = 2, inputDisabled = true },
                { idx = 3, inputDisabled = true },
                { idx = 4, inputDisabled = true },
                { idx = 5, inputDisabled = true },
            })
        end)
        counter += 1
        task.wait(5)
    end

    return
end

return Event