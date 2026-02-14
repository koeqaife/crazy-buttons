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

local runningPromises: {[Player]: {Promise.TypedPromise<any>}} = {}

GameState.alivePlayers = alivePlayers
GameState.deadPlayers = deadPlayers
GameState.round = 0

local function ensureRunningPromises(player: Player)
    if runningPromises[player] == nil then
        runningPromises[player] = {}
    end
    return runningPromises[player]
end

function GameState.kill(player: Player, reason: string?)
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

    Promise.defer(function(resolve, reject, onCancel)
        local playerRunningPromises = ensureRunningPromises(player)
        for i = #playerRunningPromises, 1, -1 do
            print("Cancelling promise for", player.Name)
            local promise = playerRunningPromises[i]
            promise:cancel()
        end
        table.clear(playerRunningPromises)
        resolve()
    end):catch(warn)

    SyncDeadEvent:FireAllClients(true, player, deadPlayers, alivePlayers, reason)
end

local function protect<T>(player: Player, promise: Promise.TypedPromise<T?>): Promise.TypedPromise<T>
    local newPromise = Promise.new(function(resolve, reject, onCancel)
        promise:andThen(resolve):catch(reject)
        onCancel(function()
            promise:cancel()
        end)
    end)

    local playerRunningPromises = ensureRunningPromises(player)

    newPromise:finally(function(status)
        local idx = table.find(playerRunningPromises, newPromise)
        if idx ~= nil then table.remove(playerRunningPromises, idx) end
    end)

    if newPromise:getStatus() == "Started" then -- check just in case of UB
        table.insert(playerRunningPromises, newPromise)
    end

    return newPromise
end


local function protectedAwait<T>(player: Player, promise: Promise.TypedPromise<T?>): T
    local protectedPromise = protect(player, promise)
    local ok, result = protectedPromise:await()
    if protectedPromise:getStatus() == "Cancelled" then
        return result
    elseif not ok then
        error(result)
    end
    return result
end

GameState.protect = protect
GameState.protectedAwait = protectedAwait

function GameState.revive(player: Player, reason: string?)
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

    SyncDeadEvent:FireAllClients(false, player, deadPlayers, alivePlayers, reason)
end

type NewPromiseFunc = (
    player: Player,
    protect: <T>(promise: Promise.TypedPromise<T?>) -> Promise.TypedPromise<T>,
    await: <T>(promise: Promise.TypedPromise<T?>) -> T
) -> nil

type PromiseFunc = (
    player: Player,
    protect: <T>(promise: Promise.TypedPromise<T?>) -> Promise.TypedPromise<T>,
    await: <T>(promise: Promise.TypedPromise<T?>) -> T
) -> Promise.TypedPromise<any>

local function runNewPromisePer(
    array: {Player},
    func: NewPromiseFunc
)
    local promises = {}
    for _, player in ipairs(array) do
        if not player or not player.Parent then
            continue
        end

        local function protectForPlayer<T>(promise: Promise.TypedPromise<T?>): Promise.TypedPromise<T>
            return protect(player, promise)
        end

        local function awaitForPlayer<T>(promise: Promise.TypedPromise<T?>): T
            return protectedAwait(player, promise)
        end

        local newPromise = protect(player, Promise.new(function(resolve)
            func(player, protectForPlayer, awaitForPlayer)
            resolve()
        end))

        table.insert(promises, newPromise)
    end
    return Promise.allSettled(promises)
end

local function runPromisePer(array: {Player}, func: PromiseFunc)
    local promises = {}
    for _, player in ipairs(array) do
        if not player or not player.Parent then
            continue
        end

        local function protectForPlayer<T>(promise: Promise.TypedPromise<T?>): Promise.TypedPromise<T>
            return protect(player, promise)
        end

        local function awaitForPlayer<T>(promise: Promise.TypedPromise<T?>): T
            return protectedAwait(player, promise)
        end

        local newPromise = protect(player, func(player, protectForPlayer, awaitForPlayer))

        table.insert(promises, newPromise)
    end
    return Promise.allSettled(promises)
end

-- New
function GameState.runNewPromisePerAll(func: NewPromiseFunc)
    return runNewPromisePer(Players:GetPlayers(), func)
end

function GameState.runNewPromisePerAlive(func: NewPromiseFunc)
    return runNewPromisePer(alivePlayers, func)
end

function GameState.runNewPromisePerDead(func: NewPromiseFunc)
    return runNewPromisePer(deadPlayers, func)
end

-- Existing
function GameState.runPromisePerAll(promise: PromiseFunc)
    return runPromisePer(Players:GetPlayers(), promise)
end

function GameState.runPromisePerAlive(promise: PromiseFunc)
    return runPromisePer(alivePlayers, promise)
end

function GameState.runPromisePerDead(promise: PromiseFunc)
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

function GameState.isDead(player: Player)
    return table.find(deadPlayers, player) ~= nil
end

return GameState