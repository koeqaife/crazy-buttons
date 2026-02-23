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

local OnPlayerDied: BindableEvent = Instance.new("BindableEvent")

GameState.alivePlayers = alivePlayers
GameState.deadPlayers = deadPlayers
GameState.round = 0
GameState.OnPlayerDied = OnPlayerDied

local function ensureRunningPromises(player: Player)
    if runningPromises[player] == nil then
        runningPromises[player] = {}
    end
    return runningPromises[player]
end

local function cancelPlayerPromises(player: Player)
    Promise.defer(function(resolve, reject, onCancel)
        local playerRunningPromises = ensureRunningPromises(player)
        for i = #playerRunningPromises, 1, -1 do
            print("Cancelling promise for", player.Name)
            local promise = playerRunningPromises[i]
            promise:cancel()
        end
        table.clear(playerRunningPromises)
    end):catch(warn)
end

GameState.cancelPlayerPromises = cancelPlayerPromises

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

    SyncDeadEvent:FireAllClients(true, player, deadPlayers, alivePlayers, reason)
    OnPlayerDied:Fire(player)

    cancelPlayerPromises(player)
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

    cancelPlayerPromises(player)
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
    local snapshot = table.clone(array)
    local promises = {}
    for _, player in ipairs(snapshot) do
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
    local snapshot = table.clone(array)
    local promises = {}
    for _, player in ipairs(snapshot) do
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
    local snapshot = table.clone(Players:GetPlayers())
    for _, player in ipairs(snapshot) do
        func(player)
    end
end

function GameState.runFuncPerAlive(func: (player: Player) -> nil)
    local snapshot = table.clone(alivePlayers)
    for _, player in ipairs(snapshot) do
        func(player)
    end
end

function GameState.runFuncPerDead(func: (player: Player) -> nil)
    local snapshot = table.clone(deadPlayers)
    for _, player in ipairs(snapshot) do
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

function GameState.pickOnePlayer(from: {Player}?): Player
    local fromArray = from or alivePlayers

    Helpers.shuffleTable(fromArray)

    return fromArray[1]
end

local function addHighlightToOne(player: Player, color: Color3?, outlineColor: Color3?)
    local colorToPut = color or Color3.fromRGB(255, 140, 91)
    if player.Character and not player.Character:FindFirstChild("EventHighlight") then
        local highlight = Instance.new("Highlight")
        highlight.Name = "EventHighlight"
        highlight.Adornee = player.Character
        highlight.FillColor = colorToPut
        highlight.FillTransparency = 0.5
        highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        highlight.Parent = player.Character

        if outlineColor then
            highlight.OutlineTransparency = 0.0
            highlight.OutlineColor = outlineColor
        else
            highlight.OutlineTransparency = 1.0
        end
    end
end

local function removeHighlightFromOne(player: Player)
    if player.Character then
        local highlight = player.Character:FindFirstChild("EventHighlight")
        if highlight then
            highlight:Destroy()
        end
    end
end

GameState.addHighlightToOne = addHighlightToOne
GameState.removeHighlightFromOne = removeHighlightFromOne

function GameState.addHighlightTo(players: {Player}, color: Color3?, outlineColor: Color3?)
    for _, player in players do
        addHighlightToOne(player, color, outlineColor)
    end
end

function GameState.removeHighlightFrom(players: {Player})
    for _, player in players do
        removeHighlightFromOne(player)
    end
end

function GameState.removeHighlightFromAll()
    for _, player in Players:GetPlayers() do
        removeHighlightFromOne(player)
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
            if not BadgeService:UserHasBadgeAsync(player.UserId, id) then
                BadgeService:AwardBadgeAsync(player.UserId, id)
            end
        end)()
    end, 5, withJitter(15))
end

function GameState.isDead(player: Player)
    return table.find(deadPlayers, player) ~= nil
end

function GameState.cancelAll()
    for i, player in ipairs(Players:GetPlayers()) do
        cancelPlayerPromises(player)
    end
end

return GameState