--!strict
--!optimize 2

-- Description:
-- Event where players have to click the button first to survive
-- The last one to click will be eliminated
-- There is cooldown so people won't be able to use auto-clicker or just click really fast
-- So the ones with good reaction will have more chance to survive
-- Time to wait is random so timer is hidden

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Arena = game:GetService("ServerScriptService").Server.Arena
local GameState = require(Arena.GameStateModule)
local EventTypeModule = require(Arena.Events.EventType)
local TextModule = require(Arena.TextModule)
local ButtonsModule = require(Arena.ButtonsModule)
local TimerModule = require(Arena.TimerModule)
local Promise = require(ReplicatedStorage.Shared.Promise)

type EventType = EventTypeModule.Event

local COOLDOWN = 1

local Event = {} :: EventType

Event.chance = 0.15
Event.minPlayers = 4
Event.maxPerGame = 3

function Event.check()
    return true
end

function Event.onEvent()
    return Promise.new(function(resolve, reject, onCancel)
        TimerModule.setTime(10)
        GameState.runPromisePerAlive(function(player)
            return TextModule.showTextSequence(player, {
                { text = "Now you will have to click the button", delay = 3.25 },
                { text = "Click faster than the others", delay = 3.25 },
                { text = "The last one to click will be eliminated", delay = 3.5 },
            })
        end):catch(reject):await()

        GameState.runFuncPerAlive(function(player)
            ButtonsModule.setButtons(player, {
                { idx = 1 }
            })
            TextModule.setText(player, "Wait until the button turns green")
        end)
        TimerModule.setTime(-1)

        local counter = #GameState.alivePlayers
        local toWait = math.random(10, 35)
        local lastClickPerPlayer: {[Player]: number} = {}

        -- With cooldown of 1 second, so people can't just click really fast
        local promise = GameState.runPromisePerAlive(function(player)
            return Promise.new(function(resolve2, reject2, onCancel2)
                while task.wait() do
                    local promise = ButtonsModule.waitForClick(player, toWait)
                    onCancel2(function()
                        promise:cancel()
                    end)

                    local ok, clicked = promise:await()
                    if not ok then
                        reject2(clicked)
                        return
                    end

                    if ok and clicked then
                        lastClickPerPlayer[player] = os.clock()
                        ButtonsModule.updateButtons(player, {
                            { idx = 1, disabled = true }
                        })
                        task.wait(COOLDOWN)
                        ButtonsModule.updateButtons(player, {
                            { idx = 1, disabled = false }
                        })
                    end
                end
            end)
        end):catch(reject)

        task.wait(toWait)
        promise:cancel()

        GameState.runNewPromisePerAlive(function(player)
            -- Apply cooldown
            local now = os.clock()
            if lastClickPerPlayer[player] and now - lastClickPerPlayer[player] < COOLDOWN then
                ButtonsModule.setButtons(player, {
                    { idx = 5, text = "CLICK ME", disabled = true }
                })
                task.wait(COOLDOWN - (now - lastClickPerPlayer[player]))
            end

            ButtonsModule.setButtons(player, {
                { idx = 5, text = "CLICK ME" }
            })
            local ok, clicked = ButtonsModule.waitForIdxClick(player, 10, 5):await()
            if not ok then
                reject(clicked)
                return
            end
            if not clicked then
                TextModule.showTextSequence(player, {
                    { text = "You didn't click the button", delay = 2.5 },
                    { text = "You will be eliminated", delay = 2.5 },
                }):await()
                GameState.kill(player)
                return
            end
            ButtonsModule.setButtons(player, {})

            counter -= 1
            if counter <= 0 then
                TextModule.showTextSequence(player, {
                    { text = "You were the last one to click", delay = 2.5 },
                    { text = "You will be eliminated", delay = 2.5 },
                }):await()
                GameState.kill(player)
            else
                TextModule.showTextSequence(player, {
                    { text = "You clicked the button", delay = 2.5 },
                    { text = "Wait for the others to click", delay = 2.5 },
                }):await()
            end
        end):catch(reject):await()

        resolve()
    end)
end

return Event