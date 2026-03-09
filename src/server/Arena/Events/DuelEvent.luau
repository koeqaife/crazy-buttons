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

Event.category = "reaction"
Event.chance = 0.08
Event.minPlayers = 2
Event.maxPerGame = 15

function Event.check()
    return true
end

function Event.onEvent()
    local randomPlayers = GameState.pickPlayers(2)
    local p1 = randomPlayers[1]
    local p2 = randomPlayers[2]

    GameState.runFuncPerDead(function(player)
        return TextModule.setText(player, p1.DisplayName .. " and " .. p2.DisplayName .. " will play a duel now", "click_button_icon")
    end)

    GameState.runPromisePerAlive(function(player, protect)
        if player == p1 or player == p2 then
            local otherPlayer = if player == p1 then p2 else p1
            return protect(TextModule.showTextSequence(player, {
                { text = "You and " .. otherPlayer.DisplayName .. " will play a duel now", delay = 6, face = "click_button_icon" },
                { text = "The first one to click survives", delay = 6, face = "normal" },
            }))
        else
            return protect(TextModule.showTextSequence(player, {
                { text = p1.DisplayName .. " and " .. p2.DisplayName .. " will play a duel now", delay = 6, face = "click_button_icon" },
                { text = "The first one to click survives", delay = 6, face = "normal" },
            }))
        end
    end):await()

    GameState.runFuncPerAlive(function(player)
        if player == p1 or player == p2 then
            ButtonsModule.setButtons(player, {
                { idx = 1 }
            })
            TextModule.setText(player, "Wait until the button turns green", { text = "..." })
        end
    end)

    local toWait = math.random(15, 60)

    local lastClickPerPlayer: {[Player]: number} = {}

    task.delay(1, function()
        AmbienceModule.playEerieHorrorRising()
    end)
    -- With cooldown of 1 second, so people can't just click really fast
    local promise = GameState.runPromisePerAlive(function(player, protect, await)
        if player ~= p1 and player ~= p2 then
            ButtonsModule.updateButtons(player, {
                { idx = 1, inputDisabled = true }
            })
            return Promise.resolve()
        end

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

    local firstClicked: Player? = nil

    GameState.runNewPromisePerAlive(function(player, protect, await)
        if player ~= p1 and player ~= p2 then
            ButtonsModule.updateButtons(player, {
                { idx = 5, inputDisabled = true }
            })
            return
        end

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
                { text = "You didn't click the button", delay = 2.5, face = "angry" },
                { text = "You will be eliminated", delay = 2.5, face = "dead" },
            }))
            GameState.kill(player)
            return
        end
        ButtonsModule.setButtons(player, {})

        if firstClicked ~= nil then
            return
        else
            firstClicked = player

            local otherPlayer = if player == p1 then p2 else p1
            GameState.cancelPlayerPromises(otherPlayer)
            ButtonsModule.setButtons(otherPlayer, {})
            task.wait()
        end
    end):catch(error):await()

    GameState.runNewPromisePerAlive(function(player, protect, await)
        local lost = if firstClicked == p1 then p2 else p1
        GameState.addRewardTo(player, 3)

        if player == firstClicked then
            GameState.addRewardTo(player, 4)
            await(TextModule.showTextSequence(player, {
                { text = "You were fast enough", delay = 3, face = "happy" },
                { text = "Good job", delay = 2.5, face = "shy" },
            }))
        elseif player == lost then
            await(TextModule.showTextSequence(player, {
                { text = "The other player clicked faster", delay = 3, face = "laughing" },
                { text = "You're eliminated", delay = 2, face = "dead" },
            }))
            GameState.kill(player)
        elseif firstClicked ~= nil then
            await(TextModule.showTextSequence(player, {
                { text = firstClicked.Name .. " won this duel", delay = 4, face = "happy" },
            }))
        end
    end):await()

    return
end

return Event