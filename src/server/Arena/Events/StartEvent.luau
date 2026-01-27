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
        local promises: {Promise.TypedPromise<nil>} = {}

        TimerModule.setTime(40)
        for _, player in ipairs(GameState.alivePlayers) do
            table.insert(promises, Promise.new(function(resolve2, reject2, onCancel2)
                TextModule.setText(player, "Okay so...")
                task.wait(2) -- 2s
                TextModule.setText(player, "Hey there " .. player.DisplayName .. "!")
                task.wait(3) -- 5s
                TextModule.setText(player, "This is a Button Experiment")
                task.wait(3) -- 8s
                TextModule.setText(player, "Very obvious what it means, huh?")

                task.wait(3) -- 11s
                TextModule.setText(player, "Let's start with something simple then")
                task.wait(4) -- 15s
                TextModule.setText(player, "You see this button?\nDo whatever it says")
                ButtonsModule.setButtons(player, {{ idx = 1, text = "Press me!" }})

                local conn
                local _, clicked = Promise.race(  -- 30s
                    {
                        Promise.new(
                            function(resolve3, reject3, onCancel3)
                                conn = ButtonsModule.buttonClickedEvent.OnServerEvent:Connect(
                                    function(playerWhoClicked, idx: number)
                                        if playerWhoClicked == player then
                                            resolve3(true)
                                            conn:Disconnect()
                                        end
                                    end
                                )

                                onCancel3(function()
                                    conn:Disconnect()
                                end)
                            end
                        ),
                        Promise.new(
                            function(resolve3, reject3, onCancel3)
                                task.wait(15)
                                resolve3(false)
                            end
                        )
                    }
                ):await()

                ButtonsModule.setButtons(player, {})
                if clicked then
                    TextModule.setText(player, "Nice, looks like it's working")
                    task.wait(4) -- 34s
                    TextModule.setText(player, "See the timer?")
                    task.wait(3) -- 37s
                    TextModule.setText(player, "Good")
                    task.wait(3) -- 40s
                else
                    TextModule.setText(player, "Ignoring me huh?")
                    task.wait(1.5) -- 26.5s
                    TextModule.setText(player, "That's not nice...")
                    task.wait(3.5) -- 30s
                    GameState.kill(player)
                end
                resolve2()
            end))
        end

        Promise.all(promises):await()
        table.clear(promises)
        TimerModule.setTime(10)

        for _, player in ipairs(GameState.alivePlayers) do
            table.insert(promises, Promise.new(function(resolve2, reject2, onCancel2)
                task.wait(2) -- 2s
                TextModule.setText(player, "Before we start you should remember")
                task.wait(2) -- 4s
                TextModule.setText(player, "1. NEVER TRUST ANYONE")
                task.wait(2) -- 6s
                TextModule.setText(player, "2. NEVER TRUST ME")
                task.wait(2) -- 8s
                TextModule.setText(player, "3. NEVER TRUST YOUR EYES")
                task.wait(2) -- 10s
                resolve2()
            end))
        end

        Promise.all(promises):await()
        resolve()
    end)
end

return StartEvent