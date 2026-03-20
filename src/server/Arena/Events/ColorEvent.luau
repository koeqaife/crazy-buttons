--!strict
--!optimize 2
local ServerScriptService = game:GetService("ServerScriptService")

-- Description:
-- Event where you choose color in the beginning
-- And you're gonna be asked what color you chose
-- Buttons are mixed due to default argument in ButtonsModule
-- So positions are always different

local Arena = game:GetService("ServerScriptService").Server.Arena
local PlayersModule = require(ServerScriptService.Server.Arena.PlayersModule)
local RewardsModule = require(ServerScriptService.Server.Arena.RewardsModule)
local EventTypeModule = require(Arena.Events.EventType)
local TextModule = require(Arena.TextModule)
local ButtonsModule = require(Arena.ButtonsModule)
local TimerModule = require(Arena.TimerModule)

local logAction = require(ServerScriptService.Server.Shared.QuestsModule).logAction

type EventType = EventTypeModule.Event

local Event = {} :: EventType

Event.name = "color"
Event.category = "mind"
Event.chance = 0.1
Event.minPlayers = 6
Event.maxPerGame = 2

local chosenColors: {[Player]: number} = {}
local COLOR_NAMES = { "RED", "BLUE", "PINK", "YELLOW", "GREEN" }

local counter = 0

function Event.check()
    Event.chance += 0.03
    counter -= 1
    return counter <= 0
end

function Event.onEvent()
    if next(chosenColors) then
        PlayersModule.runFuncPerDead(function(player)
            TextModule.setText(player, "for_dead_remember")
        end)

        PlayersModule.runPromisePerAlive(function(player, protect)
            return protect(TextModule.showTextSequence(player, {
                { key = "you_remember_color", delay = 5.5 },
                { key = "lets_check", delay = 4 },
            }))
        end):catch(error):await()

        TimerModule.setTime(15)
        PlayersModule.runFuncPerAlive(function(player)
            if not chosenColors[player] then
                TextModule.setText(player, "did_not_choose")
                return
            end
            TextModule.setText(player, "which_one_you_chose")
            ButtonsModule.setButtons(player, {
                { idx = 1, text = "Red" },
                { idx = 2, text = "Blue" },
                { idx = 3, text = "Pink" },
                { idx = 4, text = "Yellow" },
                { idx = 5, text = "Green" },
            })
        end)

        local _, chosen = ButtonsModule.initiateButtonChoice(15, nil, nil, nil, nil, PlayersModule.alivePlayers):catch(error):await()
        TimerModule.setTime(-1)

        PlayersModule.runNewPromisePerAlive(function(player, protect, await)
            if not chosenColors[player] then
                TextModule.setText(player, "so_lucky")
                return
            end

            local color = chosen[player] or 0
            if color ~= chosenColors[player] then
                TextModule.setText(player, "wrong_color")
                PlayersModule.kill(player)
                task.wait(5)
            else
                RewardsModule.addRewardTo(player, 8)
                logAction(player, "remember_color")
                await(TextModule.showTextSequence(player, {
                    { key = "correct_color", delay = 4 },
                    { key = "good_job", delay = 2 },
                }))
            end
        end):catch(error):await()

        return
    end

    PlayersModule.runFuncPerDead(function(player)
        TextModule.setText(player, "for_dead_start")
    end)

    PlayersModule.runPromisePerAlive(function(player, protect)
        return protect(TextModule.showTextSequence(player, {
            { key = "about_to_show_colors", delay = 4.5 },
            { key = "remember_color", delay = 4.5 },
        }))
    end):catch(error):await()

    TimerModule.setTime(25)
    PlayersModule.runFuncPerAlive(function(player)
        TextModule.setText(player, "choose")
        local buttons = {
            { idx = 1, text = "Red" },
            { idx = 2, text = "Blue" },
            { idx = 3, text = "Pink" },
            { idx = 4, text = "Yellow" },
            { idx = 5, text = "Green" },
        }
        table.remove(buttons, math.random(1, #buttons))
        table.remove(buttons, math.random(1, #buttons))

        ButtonsModule.setButtons(player, buttons)
    end)

    local _, chosen = ButtonsModule.initiateButtonChoice(25, nil, nil, nil, nil, PlayersModule.alivePlayers):catch(error):await()
    TimerModule.setTime(-1)

    local toSave: {[Player]: number} = {}

    PlayersModule.runFuncPerAlive(function(player)
        local color = chosen[player] or 0
        if color == 1 then
            TextModule.setText(player, "red")
        elseif color == 2 then
            TextModule.setText(player, "blue")
        elseif color == 3 then
            TextModule.setText(player, "pink")
        elseif color == 4 then
            TextModule.setText(player, "yellow")
        elseif color == 5 then
            TextModule.setText(player, "green")
        else
            color = math.random(1, 5)
            local colorName = COLOR_NAMES[color]
            TextModule.setText(player, "nothing", {color = colorName})
        end
        toSave[player] = color
        RewardsModule.addRewardTo(player, 2)
    end)
    chosenColors = toSave

    -- Can show this event only after 5 rounds
    counter = 5
    Event.minPlayers = 2

    task.wait(5)

    return
end

return Event