--!strict
--!optimize 2

-- Description:
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Arena = game:GetService("ServerScriptService").Server.Arena
local KillToolModule = require(ServerScriptService.Server.Arena.KillToolModule)
local TimerModule = require(ServerScriptService.Server.Arena.TimerModule)
local IndicesType = require(ReplicatedStorage.Shared.IndicesType)
local ButtonsModule = require(Arena.ButtonsModule)
local GameState = require(Arena.GameStateModule)
local EventTypeModule = require(Arena.Events.EventType)
local TextModule = require(Arena.TextModule)
local Helpers = require(ReplicatedStorage.Shared.Helpers)
local Promise = require(ReplicatedStorage.Shared.Promise)

type EventType = EventTypeModule.Event

local Event = {} :: EventType

Event.chance = 0.08
Event.minRound = 3
Event.minPlayers = 3
Event.maxPerGame = 1
Event.name = "maze"
Event.category = "rare"

function Event.check()
    return true
end

function Event.onEvent()
    local playerSpawnLocation = workspace:WaitForChild("SpawnLocation") :: SpawnLocation

    local maze = ReplicatedStorage:WaitForChild("Maze"):Clone() :: Model
    maze.Parent = workspace
    GameState.registerInstance(maze)

    local mazeSpawns = maze:WaitForChild("Spawns") :: Folder
    local spawns: {Part} = {}
    local idx: {number} = {}

    for i, buttonSpawn in mazeSpawns:GetChildren() do
        buttonSpawn.Parent = workspace
        buttonSpawn.Name = "ButtonSpawn_" .. tostring(i)
        table.insert(spawns, buttonSpawn :: Part)
        table.insert(idx, i)

        GameState.registerInstance(buttonSpawn)
    end
    Helpers.shuffleTable(spawns)

    local kills = math.random(1, 6)
    local reward = math.random(1, 5)
    if reward >= kills then
        reward += 1
    end

    GameState.runFuncPerAlive(function(player)
        local buttons: IndicesType.Indices = {}
        for i, buttonSpawn in ipairs(spawns) do
            if i > 6 then
                break
            end

            table.insert(buttons, { idx = i, spawnAt = buttonSpawn.Name })
        end
        ButtonsModule.setButtons(player, buttons, nil, false)

        local character = player.Character
        if character then
            character:MoveTo(playerSpawnLocation.Position + Vector3.new(math.random(-6, 6), 10, math.random(-6, 6)))
        end
    end)

    GameState.runPromisePerAll(function(player, protect, await)
        return protect(TextModule.showTextSequence(player, {
            { text = "I just spawned a maze", delay = 4 },
            { text = "There are 6 buttons", delay = 4 },
            { text = "One of them kills, one gives reward", delay = 4 },
            { text = "Good luck searching", delay = 4 },
        }))
    end)

    local awardedResolved = false
    local killResolved = false
    local counter = 6
    local resolved = false

    TimerModule.setTime(150)
    GameState.runPromisePerAlive(function(player, protect, await)
        return protect(Promise.new(function(resolve, reject, onCancel)
            while task.wait(3) and not resolved do -- for debouncing
                local clickPromise = ButtonsModule.waitForClick(player, 150)
                onCancel(function()
                    resolved = true
                    clickPromise:cancel()
                end)

                local clicked = await(clickPromise)

                GameState.addRewardTo(player, 0.25)
                GameState.runFuncPerAlive(function(player2)
                    ButtonsModule.updateButtons(player2, {{ idx = clicked, disabled = true }})
                end)
                counter -= 1

                if clicked == reward and not awardedResolved then
                    awardedResolved = true
                    GameState.addRewardTo(player, 2)
                    KillToolModule.giveTool(player)
                elseif clicked == kills and not killResolved then
                    killResolved = true
                    GameState.kill(player)
                end

                if counter <= 0 then
                    resolved = true
                    return resolve()
                end
            end
        end))
    end):timeout(150):catch(function(e)
        if Promise.Error.isKind(e, Promise.Error.Kind.TimedOut) then
            return
        else
            error(e)
        end
    end):await()
    TimerModule.setTime(-1)

    GameState.destroyInstances()

    GameState.runFuncPerAlive(function(player)
        ButtonsModule.setButtons(player, {})
        if awardedResolved then
            TextModule.setText(player, "Somebody was awarded")
        else
            TextModule.setText(player, "No one was awarded")
        end
    end)
    task.wait(10)

    return
end

return Event