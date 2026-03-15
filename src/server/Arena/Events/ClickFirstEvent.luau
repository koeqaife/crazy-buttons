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
local AmbienceModule = require(Arena.AmbienceModule)
local Promise = require(ReplicatedStorage.Shared.Promise)

type EventType = EventTypeModule.Event

local COOLDOWN = 1

local Event = {} :: EventType

local clickSound = ReplicatedStorage
    :WaitForChild("Sounds")
    :WaitForChild("LoudClickSound") :: Sound

Event.name = "click_first"
Event.category = "reaction"
Event.chance = 0.08
Event.minPlayers = 4
Event.maxPerGame = 3
Event.minRound = 5

function Event.check()
    return true
end

function Event.onEvent()
    GameState.runPromisePerDead(function(player, protect)
        return protect(TextModule.showTextSequence(player, {
            { key = "they_have_to_click", delay = 5 },
            { key = "last_num_eliminate", delay = 7, data = {num = 1} },
        }))
    end):andThen(function() end)

    GameState.runPromisePerAlive(function(player, protect)
        return protect(TextModule.showTextSequence(player, {
            { key = "you_have_to_click", delay = 6 },
            { key = "click_faster", delay = 5 },
            { key = "last_num_eliminate", delay = 7, data = {num = 1} },
        }))
    end):await()

    GameState.runFuncPerAlive(function(player)
        ButtonsModule.setButtons(player, {
            { idx = 1 }
        })
        TextModule.setText(player, "wait_for_green")
    end)

    local counter = #GameState.alivePlayers - 1

    local toWait = math.random(25, 60)
    local lastClickPerPlayer: {[Player]: number} = {}

    task.delay(1, function()
        AmbienceModule.playEerieHorrorRising()
    end)
    -- With cooldown of 1 second, so people can't just click really fast
    local promise = GameState.runPromisePerAlive(function(player, protect, await)
        return Promise.new(function(resolve2, reject2, onCancel2)
            while task.wait() do
                local promise = ButtonsModule.waitForClick(player, toWait)
                onCancel2(function()
                    promise:cancel()
                end)

                local clicked = await(promise)

                if clicked then
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
    end):catch(error)

    task.wait(toWait)
    promise:cancel()

    AmbienceModule.stopEerieHorrorRising()

    TimerModule.setTime(-1)
    local sound = clickSound:Clone()
    sound.Parent = workspace
    sound.PlayOnRemove = true
    sound:Destroy()

    GameState.runNewPromisePerAlive(function(player, protect, await)
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
        local clicked = await(ButtonsModule.waitForIdxClick(player, 10, 5))

        if not clicked then
            await(TextModule.showTextSequence(player, {
                { key = "you_did_not_click", delay = 4 },
                { key = "you_are_eliminated", delay = 4 },
            }))
            counter -= 1
            GameState.kill(player)
            return
        end
        ButtonsModule.setButtons(player, {})

        counter -= 1
        if counter < 0 then
            await(TextModule.showTextSequence(player, {
                { key = "you_clicked_too_slow", delay = 4},
                { key = "you_are_eliminated", delay = 4 },
            }))
            GameState.addRewardTo(player, 1)
            GameState.kill(player)
        else
            await(TextModule.showTextSequence(player, {
                { key = "you_survived", delay = 4 },
                { key = "wait_for_others", delay = 4 },
            }))
            GameState.addRewardTo(player, 5)
        end
    end):catch(error):await()

    return
end

return Event