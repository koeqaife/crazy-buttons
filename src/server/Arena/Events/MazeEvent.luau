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
local IndicesType = require(ReplicatedStorage.Shared.IndicesType)
local ButtonsModule = require(Arena.ButtonsModule)
local EventTypeModule = require(Arena.Events.EventType)
local TextModule = require(Arena.TextModule)
local Helpers = require(ReplicatedStorage.Shared.Helpers)
local Promise = require(ReplicatedStorage.Shared.Promise)

local logAction = require(ServerScriptService.Server.Shared.QuestsModule).logAction
local applyTimeBonus = require(Arena.SideEffects).applyTimeBonus

type EventType = EventTypeModule.Event

local Event = {} :: EventType

Event.chance = 0.1
Event.minRound = 3
Event.minPlayers = 3
Event.maxPerGame = 1
Event.name = "maze"
Event.category = "rare"

function Event.check()
    return true
end

function Event.onEvent()
    local playerSpawnLocation = workspace:WaitForChild("StandingPad") :: Part

    local maze = ReplicatedStorage:WaitForChild("Maze"):Clone() :: Model
    maze.Parent = workspace
    MiscModule.registerInstance(maze)

    local mazeSpawns = maze:WaitForChild("Spawns") :: Folder
    local spawns: {Part} = {}
    local idx: {number} = {}

    for i, buttonSpawn in mazeSpawns:GetChildren() do
        buttonSpawn.Parent = workspace
        buttonSpawn.Name = "ButtonSpawn_" .. tostring(i)
        table.insert(spawns, buttonSpawn :: Part)
        table.insert(idx, i)

        MiscModule.registerInstance(buttonSpawn)
    end
    Helpers.shuffleTable(spawns)

    local kills = math.random(1, 6)
    local reward = math.random(1, 5)
    if reward >= kills then
        reward += 1
    end

    PlayersModule.runFuncPerAlive(function(player)
        local buttons: IndicesType.Indices = {}
        for i, buttonSpawn in ipairs(spawns) do
            if i > 6 then break end
            table.insert(buttons, { idx = i, spawnAt = buttonSpawn.Name })
        end
        ButtonsModule.setButtons(player, buttons, false)

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
        }))
    end)

    local awardedResolved = false
    local killResolved = false
    local counter = 6
    local resolved = false

    TimerModule.setTime(150)
    PlayersModule.runPromisePerAlive(function(player, protect, await)
        return protect(Promise.new(function(resolve, reject, onCancel)
            while task.wait(3) and not resolved do -- for debouncing
                local clickPromise = ButtonsModule.waitForClick(player, 150)

                local clicked = await(clickPromise)

                RewardsModule.addRewardTo(player, 0.25)
                logAction(player, "press_maze")

                PlayersModule.runFuncPerAlive(function(player2)
                    ButtonsModule.updateButtons(player2, {{ idx = clicked, disabled = true }})
                end)
                counter -= 1

                if clicked == reward and not awardedResolved then
                    awardedResolved = true
                    RewardsModule.addRewardTo(player, 2)
                    KillToolModule.giveTool(player)
                elseif clicked == kills and not killResolved then
                    killResolved = true
                    PlayersModule.kill(player)
                end

                if awardedResolved and killResolved then
                    PlayersModule.cancelAll()
                end

                if counter <= 0 then
                    resolved = true
                    PlayersModule.cancelAll()
                    return resolve()
                end
            end
        end))
    end):timeout(applyTimeBonus(150)):catch(function(e)
        if Promise.Error.isKind(e, Promise.Error.Kind.TimedOut) then
            return
        else
            error(e)
        end
    end):await()
    TimerModule.setTime(-1)

    PlayersModule.runButtonsForDead()
    MiscModule.destroyInstances()

    PlayersModule.runFuncPerAlive(function(player)
        ButtonsModule.setButtons(player, {})
        if awardedResolved then
            TextModule.setText(player, "somebody_awarded")
        else
            TextModule.setText(player, "no_one_awarded")
        end
    end)
    task.wait(10)

    return
end

return Event