local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Helpers = require(ReplicatedStorage.Shared.Helpers)
local Promise = require(ReplicatedStorage.Shared.Promise)
local GameState = {}

local SyncDeadEvent = Instance.new("RemoteEvent", ReplicatedStorage)
SyncDeadEvent.Name = "SyncDeadEvent"

local alivePlayers: {Player} = {}
local deadPlayers: {Player} = {}

GameState.alivePlayers = alivePlayers
GameState.deadPlayers = deadPlayers
GameState.round = 0


function GameState.kill(player: Player)
    for i, p in ipairs(alivePlayers) do
        if p == player then
            table.remove(alivePlayers, i)
            break
        end
    end
    table.insert(deadPlayers, player)

    SyncDeadEvent:FireAllClients(true, player, deadPlayers, alivePlayers)
end

function GameState.revive(player: Player)
    for i, p in ipairs(deadPlayers) do
        if p == player then
            table.remove(deadPlayers, i)
            break
        end
    end
    table.insert(alivePlayers, player)

    SyncDeadEvent:FireAllClients(false, player, deadPlayers, alivePlayers)
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

-- New
function GameState.runNewPromisePerAll(func: (player: Player) -> nil)
    return runNewPromisePer(Players:GetPlayers(), func)
end

function GameState.runNewPromisePerAlive(func: (player: Player) -> nil)
    return runNewPromisePer(alivePlayers, func)
end

function GameState.runNewPromisePerDead(func: (player: Player) -> nil)
    return runNewPromisePer(deadPlayers, func)
end

-- Existing
function GameState.runPromisePerAll(promise: (player: Player) -> Promise.TypedPromise<nil>)
    return runPromisePer(Players:GetPlayers(), promise)
end

function GameState.runPromisePerAlive(promise: (player: Player) -> Promise.TypedPromise<nil>)
    return runPromisePer(alivePlayers, promise)
end

function GameState.runPromisePerDead(promise: (player: Player) -> Promise.TypedPromise<nil>)
    return runPromisePer(deadPlayers, promise)
end

-- Func
function GameState.runFuncPerAll(func: (player: Player) -> nil)
    for _, player in ipairs(Players:GetPlayers()) do
        func(player)
    end
end

function GameState.runFuncPerAlive(func: (player: Player) -> nil)
    for _, player in ipairs(alivePlayers) do
        func(player)
    end
end

function GameState.runFuncPerDead(func: (player: Player) -> nil)
    for _, player in ipairs(alivePlayers) do
        func(player)
    end
end
-- End

function GameState.pickPlayers(amount: number)
    Helpers.shuffleTable(alivePlayers)

    local result = {}
    local count = math.min(amount, #alivePlayers)

    for i = 1, count do
        result[i] = alivePlayers[i]
    end

    return result
end

function GameState.addHighlightTo(players: {Player})
    for _, player in players do
        if player.Character and not player.Character:FindFirstChild("EventHighlight") then
            local highlight = Instance.new("Highlight")
            highlight.Name = "EventHighlight"
            highlight.Adornee = player.Character
            highlight.FillColor = Color3.fromRGB(255, 140, 91)
            highlight.FillTransparency = 0.6
            highlight.OutlineTransparency = 1.0
            highlight.DepthMode = Enum.HighlightDepthMode.Occluded
            highlight.Parent = player.Character
        end
    end
end

function GameState.removeHighlightFrom(players: {Player})
    for _, player in players do
        if player.Character then
            local highlight = player.Character:FindFirstChild("EventHighlight")
            if highlight then
                highlight:Destroy()
            end
        end
    end
end

function GameState.removeHighlightFromAll()
    for _, player in Players:GetPlayers() do
        if player.Character then
            local highlight = player.Character:FindFirstChild("EventHighlight")
            if highlight then
                highlight:Destroy()
            end
        end
    end
end

return GameState