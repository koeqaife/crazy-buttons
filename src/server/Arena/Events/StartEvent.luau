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

function StartEvent.check()
    return true
end

function StartEvent.onEvent()
    return Promise.new(function(resolve, reject, onCancel)
        TimerModule.setTime(41)

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
                    { text = "Nice, looks like it's working", delay = 3 }, -- 33s
                    { text = "This experiment is pretty easy", delay = 4 }, -- 38s
                    { text = "All what you have to do is press before timer ends", delay = 4 }, -- 41s
                }):await()
            else
                TextModule.showTextSequence(player, {
                    { text = "Ignoring me huh?", delay = 2 }, -- 27s
                    { text = "That's not nice...", delay = 3 } -- 30s
                }):await()
                GameState.kill(player)
            end
        end):await()

        TimerModule.setTime(15)

        GameState.runPromisePerAlive(function(player)
            return TextModule.showTextSequence(player, {
                { text = "So, before we start you should remember a few rules", delay = 3 }, -- 3s
                { text = "1. NEVER TRUST ANYONE", delay = 3 }, -- 6s
                { text = "2. NEVER TRUST ME", delay = 3 }, -- 9s
                { text = "3. NEVER TRUST YOUR EYES", delay = 3 }, -- 12s
                { text = "Let's start", delay = 3 }, -- 15s
            })
        end):await()

        resolve()
    end)
end

return StartEvent