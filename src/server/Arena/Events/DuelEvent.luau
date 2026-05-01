--!strict
--!optimize 2

-- Description:
-- Event where players have to click the button first to survive
-- The last one to click will be eliminated
-- There is cooldown so people won't be able to use auto-clicker or just click really fast
-- So the ones with good reaction will have more chance to survive
-- Time to wait is random so timer is hidden

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local Arena = game:GetService("ServerScriptService").Server.Arena
local PlayersModule = require(ServerScriptService.Server.Arena.PlayersModule)
local RewardsModule = require(ServerScriptService.Server.Arena.RewardsModule)
local EventTypeModule = require(Arena.Events.EventType)
local TextModule = require(Arena.TextModule)
local ButtonsModule = require(Arena.ButtonsModule)
local TimerModule = require(Arena.TimerModule)
local AmbienceModule = require(Arena.AmbienceModule)
local Promise = require(ReplicatedStorage.Shared.Promise)

local logAction = require(ServerScriptService.Server.Shared.QuestsModule).logAction
local resetAction = require(ServerScriptService.Server.Shared.QuestsModule).resetAction

type EventType = EventTypeModule.Event

local COOLDOWN = 1

local Event = {} :: EventType

local clickSound = ReplicatedStorage
    :WaitForChild("Sounds")
    :WaitForChild("LoudClickSound") :: Sound

Event.name = "duel"
Event.category = "reaction"
Event.chance = 0.08
Event.minPlayers = 2
Event.maxPerGame = 15
Event.minRound = 5

local explained = false

function Event.check()
    return true
end

function Event.onEvent()
    local randomPlayers = PlayersModule.pickPlayers(2)
    local p1 = randomPlayers[1]
    local p2 = randomPlayers[2]

    PlayersModule.runFuncPerDead(function(player)
        return TextModule.setText(player, "to_play", {p1 = p1, p2 = p2})
    end)

    if not explained then
        explained = true
        PlayersModule.runPromisePerAlive(function(player, protect)
            if player == p1 or player == p2 then
                local otherPlayer = if player == p1 then p2 else p1
                return protect(TextModule.showTextSequence(player, {
                    { key = "to_play", delay = 6, data = {p1 = "You", p2 = otherPlayer} },
                    { key = "first_one_survives", delay = 6 },
                }))
            else
                return protect(TextModule.showTextSequence(player, {
                    { key = "to_play", delay = 6, data = {p1 = p1, p2 = p2} },
                    { key = "first_one_survives", delay = 6 },
                }))
            end
        end):await()
    else
        PlayersModule.runFuncPerAlive(function(player)
            if player == p1 or player == p2 then
                local otherPlayer = if player == p1 then p2 else p1

                TextModule.setText(player, "to_play", {p1 = "You", p2 = otherPlayer} )
            else
                TextModule.setText(player, "to_play", {p1 = p1, p2 = p2} )
            end
        end)
        task.wait(6)
    end

    PlayersModule.runFuncPerAlive(function(player)
        if player == p1 or player == p2 then
            ButtonsModule.setButtons(player, {
                { idx = 1 }
            })
            TextModule.setText(player, "wait_for_green")
        else
            ButtonsModule.setButtons(player, {
                { idx = 1, inputDisabled = true }
            })
        end
    end)

    local toWait = math.random(15, 60)

    local lastClickPerPlayer: {[Player]: number} = {}

    task.delay(1, function()
        AmbienceModule.playEerieHorrorRising()
    end)
    -- With cooldown of 1 second, so people can't just click really fast
    local promise = PlayersModule.runPromisePerAlive(function(player, protect, await)
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

    PlayersModule.runNewPromisePerAlive(function(player, protect, await)
        if player ~= p1 and player ~= p2 then
            ButtonsModule.updateButtons(player, {
                { idx = 1, inputDisabled = true, showAs = 5 }
            })
            return
        end

        -- Apply cooldown
        local now = os.clock()
        if lastClickPerPlayer[player] and now - lastClickPerPlayer[player] < COOLDOWN then
            ButtonsModule.updateButtons(player, {
                { idx = 1, text = "CLICK ME", disabled = true, showAs = 5 }
            })
            task.wait(COOLDOWN - (now - lastClickPerPlayer[player]))
        end

        ButtonsModule.updateButtons(player, {
            { idx = 1, text = "CLICK ME", showAs = 5 }
        })
        local clicked = await(ButtonsModule.waitForIdxClick(player, 10, 1))

        if not clicked then
            await(TextModule.showTextSequence(player, {
                { key = "you_did_not_click", delay = 3 },
                { key = "you_are_eliminated", delay = 3 },
            }))
            PlayersModule.kill(player)
            return
        end
        ButtonsModule.setButtons(player, {})

        if firstClicked ~= nil then
            return
        else
            firstClicked = player

            local otherPlayer = if player == p1 then p2 else p1
            PlayersModule.cancelPlayerPromises(otherPlayer)
            ButtonsModule.setButtons(otherPlayer, {})
            task.wait()
        end
    end):catch(error):await()

    PlayersModule.runNewPromisePerAll(function(player, protect, await)
        local lost = if firstClicked == p1 then p2 else p1

        if player == firstClicked then
            RewardsModule.addRewardTo(player, 7)
            logAction(player, "duel_win")
            logAction(player, "duel_win_streak")
            await(TextModule.showTextSequence(player, {
                { key = "you_were_fast_enough", delay = 3 },
                { key = "good_job", delay = 3 },
            }))
        elseif player == lost then
            RewardsModule.addRewardTo(player, 3)
            resetAction(player, "duel_win_streak")
            await(TextModule.showTextSequence(player, {
                { key = "you_are_slow", delay = 3 },
                { key = "you_are_eliminated", delay = 3 },
            }))
            PlayersModule.kill(player)
        elseif firstClicked ~= nil then
            await(TextModule.showTextSequence(player, {
                { key = "won", delay = 4, data = {player = firstClicked} },
            }))
        end
    end):await()

    return
end

return Event