--!strict
--!optimize 2

-- Description:
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Arena = game:GetService("ServerScriptService").Server.Arena
local KillToolModule = require(ServerScriptService.Server.Arena.KillToolModule)
local MiscModule = require(ServerScriptService.Server.Arena.MiscModule)
local PlayersModule = require(ServerScriptService.Server.Arena.PlayersModule)
local RewardsModule = require(ServerScriptService.Server.Arena.RewardsModule)
local TimerModule = require(ServerScriptService.Server.Arena.TimerModule)
local ButtonsModule = require(Arena.ButtonsModule)
local EventTypeModule = require(Arena.Events.EventType)
local TextModule = require(Arena.TextModule)
local Promise = require(ReplicatedStorage.Shared.Promise)

type EventType = EventTypeModule.Event

local Event = {} :: EventType

local logAction = require(ServerScriptService.Server.Shared.QuestsModule).logAction
local applyTimeBonus = require(Arena.SideEffects).applyTimeBonus

Event.chance = 0.1
Event.minRound = 2
Event.minPlayers = 3
Event.maxPerGame = 1
Event.name = "obby"
Event.category = "rare"

function Event.check()
    return true
end

function Event.onEvent()
    local playerSpawnLocation = workspace:WaitForChild("StandingPad") :: Part

    local obby = ReplicatedStorage:WaitForChild("Obby"):Clone() :: Model
    obby.Parent = workspace
    MiscModule.registerInstance(obby)

    local obbyButtonSpawn = obby:WaitForChild("ObbyButtonSpawn")
    obbyButtonSpawn.Parent = workspace
    MiscModule.registerInstance(obbyButtonSpawn)

    PlayersModule.runFuncPerAlive(function(player)
        ButtonsModule.setButtons(player, {{ idx = 5, spawnAt = "ObbyButtonSpawn" }}, false)

        local character = player.Character
        if character then
            character:MoveTo(playerSpawnLocation.Position + Vector3.new(math.random(-6, 6), 10, math.random(-6, 6)))
        end
    end)

    PlayersModule.runPromisePerAll(function(player, protect, await)
        return protect(TextModule.showTextSequence(player, {
            { key = "intro_part1", delay = 4 },
            { key = "intro_part2", delay = 4 },
            { key = "intro_part3", delay = 4 },
            { key = "intro_part4", delay = 4 },
            { key = "intro_part5", delay = 4 },
        }))
    end)

    local awardedResolved = false
    local killResolved = false
    local counter = 0

    local clicked: {Player} = {}

    TimerModule.setTime(80)
    PlayersModule.runPromisePerAlive(function(player, protect, await)
        return protect(Promise.new(function(resolve, reject, onCancel)
            local idx = await(ButtonsModule.waitForClick(player, 80))
            if idx == nil then
                return resolve()
            end

            logAction(player, "complete_obby")
            table.insert(clicked, player)
            RewardsModule.addRewardTo(player, 10)
            counter += 1

            if not awardedResolved then
                awardedResolved = true
                RewardsModule.addRewardTo(player, 20)
                KillToolModule.giveTool(player)
            elseif counter >= #PlayersModule.alivePlayers - 1 and not killResolved then
                killResolved = true
                PlayersModule.kill(player)
            end

            if awardedResolved and killResolved then
                PlayersModule.cancelAll()
            end

            if counter >= #PlayersModule.alivePlayers - 1 then
                PlayersModule.cancelAll()
                return resolve()
            end
        end))
    end):timeout(applyTimeBonus(80)):catch(function(e)
        if Promise.Error.isKind(e, Promise.Error.Kind.TimedOut) then
            return
        else
            error(e)
        end
    end):await()
    TimerModule.setTime(-1)

    if counter < 2 then
        PlayersModule.runFuncPerAlive(function(player)
            if not table.find(clicked, player) then
                PlayersModule.kill(player)
            end
        end)
    end

    PlayersModule.runFuncPerAlive(function(player)
        ButtonsModule.setButtons(player, {})
    end)

    MiscModule.destroyInstances()

    return
end

return Event