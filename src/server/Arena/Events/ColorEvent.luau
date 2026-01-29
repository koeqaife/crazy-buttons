--!strict
--!optimize 2

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Arena = game:GetService("ServerScriptService").Server.Arena
local GameState = require(Arena.GameStateModule)
local EventTypeModule = require(Arena.Events.EventType)
local TextModule = require(Arena.TextModule)
local ButtonsModule = require(Arena.ButtonsModule)
local TimerModule = require(Arena.TimerModule)
local Promise = require(ReplicatedStorage.Shared.Promise)

type EventType = EventTypeModule.Event

local Event = {} :: EventType

Event.chance = 0.1
Event.maxPerGame = 2

local chosenColors: {[Player]: number} = {}
local COLOR_NAMES = { "red", "blue", "pink", "yellow" }

function Event.check()
    return true
end

function Event.onEvent()
    if next(chosenColors) then
        return Promise.new(function(resolve, reject, onCancel)
            TimerModule.setTime(5)

            GameState.runPromisePerAlive(function(player)
                return TextModule.showTextSequence(player, {
                    { text = "Do you remember the color you chose before?", delay = 2.5 },
                    { text = "Let's check your memory", delay = 2.5 },
                })
            end):await()

            TimerModule.setTime(15)
            GameState.runNewPromisePerAlive(function(player)
                TextModule.setText(player, "So which one did you choose?")
                ButtonsModule.setButtons(player, {
                    { idx = 1, text = "Red" },
                    { idx = 2, text = "Blue" },
                    { idx = 3, text = "Pink" },
                    { idx = 4, text = "Yellow" },
                })
            end):await()

            local ok, chosen = ButtonsModule.initiateButtonChoice(15):await()
            if not ok then
                reject(chosen)
            end

            TimerModule.setTime(5)
            GameState.runNewPromisePerAlive(function(player)
                local color = chosen[player] or 0
                if color ~= chosenColors[player] then
                    TextModule.setText(player, "That was not the color you chose")
                    GameState.kill(player)
                    task.wait(5)
                else
                    TextModule.showTextSequence(player, {
                        { text = "Woa, you actually remember!", delay = 3 },
                        { text = "Good job", delay = 2 },
                    })
                end
            end):await()

            resolve()
        end)
    end

    return Promise.new(function(resolve, reject, onCancel)
        TimerModule.setTime(5)

        GameState.runPromisePerAlive(function(player)
            return TextModule.showTextSequence(player, {
                { text = "What is you favorite color?", delay = 2.5 },
                { text = "I hope it's not yellow, I hate yellow", delay = 2.5 },
            })
        end):await()

        TimerModule.setTime(15)
        GameState.runNewPromisePerAlive(function(player)
            TextModule.setText(player, "Anyways, choose color you like the most")
            ButtonsModule.setButtons(player, {
                { idx = 1, text = "Red" },
                { idx = 2, text = "Blue" },
                { idx = 3, text = "Pink" },
                { idx = 4, text = "Yellow" },
            })
        end):await()

        local ok, chosen = ButtonsModule.initiateButtonChoice(15):await()
        if not ok then
            reject(chosen)
        end

        local toSave: {[Player]: number} = {}

        TimerModule.setTime(5)
        GameState.runNewPromisePerAlive(function(player)
            local color = chosen[player] or 0
            if color == 1 then
                TextModule.setText(player, "Red? An interesting choice")
            elseif color == 2 then
                TextModule.setText(player, "Blue, the color of the sky")
            elseif color == 3 then
                TextModule.setText(player, "Pink, sounds like a candy, yummy")
            elseif color == 4 then
                TextModule.setText(player, "Yellow!?!? Fine, that's your choice")
            else
                color = math.random(1, 4)
                local colorName = COLOR_NAMES[color]
                TextModule.setText(player, "Nothing? Let's go with " .. colorName .. " then")
            end
            toSave[player] = color
        end):await()
        chosenColors = toSave

        task.wait(5)
        resolve()
    end)
end

return Event