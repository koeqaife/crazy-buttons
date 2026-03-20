--!strict
--!optimize 2

-- Description:
-- 100 buttons will appear, one of them is the god button
-- First one to find it gets a reward

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local Arena = game:GetService("ServerScriptService").Server.Arena
local MiscModule = require(ServerScriptService.Server.Arena.MiscModule)
local PlayersModule = require(ServerScriptService.Server.Arena.PlayersModule)
local RewardsModule = require(ServerScriptService.Server.Arena.RewardsModule)
local Helpers = require(ReplicatedStorage.Shared.Helpers)
local KillToolModule = require(Arena.KillToolModule)
local EventTypeModule = require(Arena.Events.EventType)
local TextModule = require(Arena.TextModule)
local ButtonsModule = require(Arena.ButtonsModule)
local TimerModule = require(Arena.TimerModule)
local Promise = require(ReplicatedStorage.Shared.Promise)

type EventType = EventTypeModule.Event

local Event = {} :: EventType

local BADGE_ID = 2055081105258413

Event.name = "god_btn"
Event.category = "rare"
Event.chance = 0.08
Event.minRound = 3
Event.maxPerGame = 2
Event.minPlayers = 3

function Event.check()
    return true
end

function Event.onEvent()
    PlayersModule.runFuncPerDead(function(player)
        TextModule.setText(player, "intro_dead")
    end)

    PlayersModule.runPromisePerAlive(function(player, protect)
        return protect(TextModule.showTextSequence(player, {
            { key = "intro_ready", delay = 5 },
            { key = "intro_100_buttons", delay = 5 },
            { key = "intro_first_rewarded", delay = 5 },
        }))
    end):catch(error):await()

    local spawns = ReplicatedStorage.GodButtons :: Folder
    local buttonSpawns: {Part} = {}

    for i, part in spawns:GetChildren() do
        if part:IsA("Part") then
            local clone = part:Clone()
            clone.Parent = workspace
            clone.Name = "GodButtonSpawn_" .. i
            table.insert(buttonSpawns, clone)
            MiscModule.registerInstance(clone)
        end
    end

    Helpers.shuffleTable(buttonSpawns)

    local seed = math.random()
    local godButton = math.random(1, 100)

    TimerModule.setTime(60)
    PlayersModule.runFuncPerAlive(function(player)
        local buttons = {}
        for i = 1, 100 do
            table.insert(buttons, { idx = i, spawnAt = buttonSpawns[i].Name })
        end

        ButtonsModule.setButtons(player, buttons, nil, nil, seed)
        TextModule.setText(player, "good_luck")
    end)

    local awardedPlayer: Player? = nil
    local awardedResolved = false

    PlayersModule.runPromisePerAlive(function(player, protect, await)
        return protect(Promise.new(function(resolve, reject, onCancel)
            while task.wait(0.3) and not awardedResolved do -- for debouncing
                local clickPromise = ButtonsModule.waitForClick(player, 60)

                local clicked = await(clickPromise)

                if clicked == godButton then
                    RewardsModule.addRewardTo(player, 2)
                    if not awardedResolved then
                        awardedResolved = true
                        awardedPlayer = player
                        MiscModule.addHighlightTo({player})
                        PlayersModule.cancelAll()
                        return resolve()
                    elseif awardedPlayer == player then
                        return resolve()
                    end
                    break
                elseif clicked ~= nil and not awardedResolved then
                    RewardsModule.addRewardTo(player, 0.25)
                    PlayersModule.runFuncPerAlive(function(player2)
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
    TimerModule.setTime(-1)

    MiscModule.destroyInstances()
    PlayersModule.runFuncPerAll(function(player)
        ButtonsModule.setButtons(player, {})
        if awardedPlayer ~= nil then
            if awardedPlayer == player then
                TextModule.setText(player, "you_found_god_btn")
                KillToolModule.giveTool(player)
                RewardsModule.rewardBadge(player, BADGE_ID)
            else
                TextModule.setText(player, "someone_found_god_btn", { player = awardedPlayer })
            end
        else
            TextModule.setText(player, "no_one_found_god_btn")
        end
    end)
    task.wait(10)

    return
end

return Event