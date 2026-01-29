local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Promise = require(ReplicatedStorage.Shared.Promise)
local GameState = {}

local alivePlayers: {Player} = {}
local deadPlayers: {Player} = {}

GameState.alivePlayers = alivePlayers
GameState.deadPlayers = deadPlayers

function GameState.kill(player: Player)
    local character = player.Character
    if character then
        local humanoid = character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            humanoid.Health = 0
        end
    end

    for i, p in ipairs(alivePlayers) do
        if p == player then
            table.remove(alivePlayers, i)
            break
        end
    end
    table.insert(deadPlayers, player)
end

local function runNewPromisePer(array: {Player}, func: (player: Player) -> nil)
    local promises = {}
    for _, player in ipairs(array) do
        table.insert(promises, Promise.new(function(resolve)
            func(player)
            resolve()
        end))
    end
    return Promise.all(promises)
end

local function runPromisePer(array: {Player}, promise: (player: Player) -> Promise.TypedPromise<nil>)
    local promises = {}
    for _, player in ipairs(array) do
        table.insert(promises, promise(player))
    end
    return Promise.all(promises)
end

function GameState.runNewPromisePerAlive(func: (player: Player) -> nil)
    return runNewPromisePer(alivePlayers, func)
end

function GameState.runNewPromisePerDead(func: (player: Player) -> nil)
    return runNewPromisePer(deadPlayers, func)
end

function GameState.runPromisePerAlive(promise: (player: Player) -> Promise.TypedPromise<nil>)
    return runPromisePer(alivePlayers, promise)
end

function GameState.runPromisePerDead(promise: (player: Player) -> Promise.TypedPromise<nil>)
    return runPromisePer(deadPlayers, promise)
end

return GameState