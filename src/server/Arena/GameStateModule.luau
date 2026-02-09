local BadgeService = game:GetService("BadgeService")
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
    if not player or not player.Parent then
        return
    end

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
    if not player or not player.Parent then
        return
    end

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
        if not player or not player.Parent then
            continue
        end

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
        if not player or not player.Parent then
            continue
        end

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

function GameState.pickPlayers(amount: number, from: {Player}?): {Player}
    local fromArray = from or alivePlayers

    Helpers.shuffleTable(fromArray)

    local result = {}
    local count = math.min(amount, #fromArray)

    for i = 1, count do
        result[i] = fromArray[i]
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

function GameState.connect()
    Players.PlayerRemoving:Connect(function(player, reason)
        for i, p in ipairs(alivePlayers) do
            if p == player then
                table.remove(alivePlayers, i)
                break
            end
        end

        for i, p in ipairs(deadPlayers) do
            if p == player then
                table.remove(deadPlayers, i)
                break
            end
        end
    end)
end

local function withJitter(baseDelay)
    return baseDelay + math.random() * 2.0
end

function GameState.rewardBadge(player: Player, id: number): Promise.TypedPromise<nil>
    return Promise.retryWithDelay(function()
        return Promise.promisify(function()
            return BadgeService:AwardBadgeAsync(player.UserId, id)
        end)()
    end, 5, withJitter(15))
end

return GameState