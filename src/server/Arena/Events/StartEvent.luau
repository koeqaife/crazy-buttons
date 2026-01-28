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

type Event = EventTypeModule.Event

local StartEvent = {} :: Event

StartEvent.chance = 1.0
StartEvent.maxRound = 1
StartEvent.customGreen = true

function StartEvent.check()
    return true
end

function StartEvent.onEvent()
    return Promise.new(function(resolve, reject, onCancel)

        TimerModule.setTime(40)
        GameState.runNewPromisePerAlive(function(player)
            TextModule.showTextSequence(player, {
                { text = "Okay so...", delay = 2 }, -- 2s
                { text = "Hey there " .. player.DisplayName .. "!", delay = 3 }, -- 5s
                { text = "This is a Button Experiment", delay = 3 }, -- 8s
                { text = "Very obvious what it means, huh?", delay = 3 }, -- 11s
                { text = "Let's start with something simple then", delay = 4 }, -- 15s,
                { text = "You see this button?\nDo whatever it says" }
            }):await()

            ButtonsModule.setButtons(player, {{ idx = 1, text = "Press me!" }})

            local _, clicked = ButtonsModule.waitForClick(player, 15):await() -- 30s

            ButtonsModule.setButtons(player, {})
            if clicked then
                TextModule.showTextSequence(player, {
                    { text = "Nice, looks like it's working", delay = 4 }, -- 34s
                    { text = "See the timer?", delay = 3 }, -- 37s
                    { text = "Good", delay = 3 }, -- 40s
                }):await()
            else
                TextModule.showTextSequence(player, {
                    { text = "Ignoring me huh?", delay = 2 }, -- 27s
                    { text = "That's not nice...", delay = 3 } -- 30s
                }):await()
                GameState.kill(player)
            end
        end):await()

        TimerModule.setTime(10)

        GameState.runPromisePerAlive(function(player)
            return TextModule.showTextSequence(player, {
                { text = "Before we start you should remember", delay = 2 }, -- 2s
                { text = "1. NEVER TRUST ANYONE", delay = 2 }, -- 4s
                { text = "2. NEVER TRUST ME", delay = 2 }, -- 6s
                { text = "3. NEVER TRUST YOUR EYES", delay = 2 }, -- 8s
                { text = "Let's start", delay = 2 }, -- 10s
            })
        end):await()

        resolve()
    end)
end

return StartEvent