--!strict
--!optimize 2

-- Description:
-- 100 buttons will appear, one of them is the god button
-- First one to find it gets a reward

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Arena = game:GetService("ServerScriptService").Server.Arena
local KillToolModule = require(Arena.KillToolModule)
local GameState = require(Arena.GameStateModule)
local EventTypeModule = require(Arena.Events.EventType)
local TextModule = require(Arena.TextModule)
local ButtonsModule = require(Arena.ButtonsModule)
local TimerModule = require(Arena.TimerModule)
local Promise = require(ReplicatedStorage.Shared.Promise)

type EventType = EventTypeModule.Event

local Event = {} :: EventType

local BADGE_ID = 2055081105258413

Event.category = "rare"
Event.chance = 0.1
Event.maxPerGame = 2
Event.minPlayers = 3

function Event.check()
    return true
end

function Event.onEvent()
    GameState.runFuncPerDead(function(player)
        TextModule.setText(player, "They're searching one button between 100 buttons", "laughing")
    end)

    GameState.runPromisePerAlive(function(player, protect)
        return protect(TextModule.showTextSequence(player, {
            { text = "Are you ready for searching?", delay = 5, face = "happy" },
            { text = "Because now there are gonna be 100 buttons", delay = 5, face = "scared" },
            { text = "First to find it will be awarded", delay = 5, face = "shy" },
        }))
    end):catch(error):await()

    local seed = math.random()
    local godButton = math.random(1, 100)

    TimerModule.setTime(60)
    GameState.runFuncPerAlive(function(player)
        local buttons = {}
        for i = 1, 100 do
            table.insert(buttons, { idx = i })
        end

        ButtonsModule.setButtons(player, buttons, nil, nil, seed)
        TextModule.setText(player, "Good luck finding it", "laughing")
    end)

    local awardedPlayer: Player? = nil
    local awardedResolved = false

    GameState.runPromisePerAlive(function(player, protect, await)
        return protect(Promise.new(function(resolve, reject, onCancel)
            while task.wait(0.3) and not awardedResolved do -- for debouncing
                local clickPromise = ButtonsModule.waitForClick(player, 60)
                onCancel(function()
                    awardedResolved = true
                    clickPromise:cancel()
                end)

                local clicked = await(clickPromise)

                if clicked == godButton then
                    GameState.addRewardTo(player, 2)
                    if not awardedResolved then
                        awardedResolved = true
                        awardedPlayer = player
                        GameState.addHighlightTo({player})
                        GameState.cancelAll()
                        return resolve()
                    elseif awardedPlayer == player then
                        return resolve()
                    end
                    break
                elseif clicked ~= nil and not awardedResolved then
                    GameState.addRewardTo(player, 0.25)
                    GameState.runFuncPerAlive(function(player2)
                        ButtonsModule.updateButtons(player2, {{ idx = clicked, disabled = true }})
                    end)
                end
            end
        end))
    end):timeout(60):catch(function(e)
        if Promise.Error.isKind(e, Promise.Error.Kind.TimedOut) then
            return
        else
            error(e)
        end
    end):await()

    GameState.runFuncPerAll(function(player)
        ButtonsModule.setButtons(player, {})
        if awardedPlayer ~= nil then
            if awardedPlayer == player then
                TextModule.setText(player, "You found the button!", "happy")
                KillToolModule.giveTool(player)
                GameState.rewardBadge(player, BADGE_ID)
            else
                TextModule.setText(player, awardedPlayer.DisplayName .. " found the button", "scared")
            end
        else
            TextModule.setText(player, "No one found the button...", "laughing")
        end
    end)
    task.wait(10)

    return
end

return Event