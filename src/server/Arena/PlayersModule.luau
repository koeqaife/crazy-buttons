--!strict
--!optimize 2
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local TextChatService = game:GetService("TextChatService")
local IconModule = require(script.Parent.IconModule)
local LinksModule = require(script.Parent.LinksModule)
local Helpers = require(ReplicatedStorage.Shared.Helpers)
local Promise = require(ReplicatedStorage.Shared.Promise)

local GameState = {}

local GuiSpace = IconModule.reserveSpace(0, "lives")

local DisableChatEvent = Instance.new("RemoteEvent", ReplicatedStorage)
DisableChatEvent.Name = "DisableChatEvent"

local SyncDeadEvent = Instance.new("RemoteEvent", ReplicatedStorage)
SyncDeadEvent.Name = "SyncDeadEvent"

local LifeEvent = Instance.new("RemoteEvent", ReplicatedStorage)
LifeEvent.Name = "LifeEvent"

local OnPlayerDied: BindableEvent = Instance.new("BindableEvent")
local OnPlayerLostLife: BindableEvent = Instance.new("BindableEvent")

local alivePlayers: {Player} = {}
local deadPlayers: {Player} = {}
local lives: {[Player]: number} = {}
local playerRevivedTimes: {[Player]: number} = {}
local runningPromises: {[Player]: {Promise.TypedPromise<any>}} = {}
local LIFE_COUNT_FOR_PLAYER = 3
local HEART_ICON = "rbxassetid://135523015698113"
local NO_HEART_ICON = "rbxassetid://79783468789350"

GameState.OnPlayerDied = OnPlayerDied
GameState.OnPlayerLostLife = OnPlayerLostLife
GameState.alivePlayers = alivePlayers
GameState.deadPlayers = deadPlayers
GameState.playerRevivedTimes = playerRevivedTimes

-- track how many revives have occurred during the current run
local revivesThisGame = 0

local logAction = require(ServerScriptService.Server.Shared.QuestsModule).logAction
local resetAction = require(ServerScriptService.Server.Shared.QuestsModule).resetAction

local function updateIcons(player: Player)
    local playerLives = lives[player]
    if playerLives == nil then
        playerLives = LIFE_COUNT_FOR_PLAYER
    end

    GuiSpace.clearIcons(player)

    for i = 1, LIFE_COUNT_FOR_PLAYER, 1 do
        GuiSpace.addIcon(player, "heart" .. i, if i > playerLives then NO_HEART_ICON else HEART_ICON)
    end

    if playerLives <= 0 then
        task.delay(3, function()
            GuiSpace.clearIcons(player)
        end)
        return
    end
end

function GameState.disableChat(value: boolean)
    print("Disable chat was called, value", value)
	value = value ~= false

	TextChatService.TextChannels.RBXGeneral.ShouldDeliverCallback = function()
        print("Should deliver was called, returned", not value)
        return not value
    end
	TextChatService.BubbleChatConfiguration.Enabled = not value

	for _, player in Players:GetPlayers() do
		local audioDeviceInput = player:FindFirstChildOfClass("AudioDeviceInput")
		if audioDeviceInput then
			audioDeviceInput.Muted = value
		end

		DisableChatEvent:FireClient(player, value)
	end
end

function GameState.setLivesPerPlayer(amount: number)
    LIFE_COUNT_FOR_PLAYER = amount
    for player, _ in pairs(lives) do
        lives[player] = amount
    end
    task.defer(function()
        for _, player in Players:GetPlayers() do
            updateIcons(player)
        end
    end)
end

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
            if promise then
                promise:cancel()
            end
        end
        table.clear(playerRunningPromises)
    end):catch(warn)
end

local function protect<T>(player: Player, promise: Promise.TypedPromise<T?>): Promise.TypedPromise<T>
    local newPromise = Promise.new(function(resolve, reject, onCancel)
        promise:andThen(resolve):catch(reject)
        onCancel(function()
            promise:cancel()
        end)
    end) :: Promise.TypedPromise<T>

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
GameState.cancelPlayerPromises = cancelPlayerPromises

function GameState.forceReviveIsAllowed(player: Player?)
    local base = revivesThisGame < 1 and #alivePlayers >= 3 and #deadPlayers > 0
    if player then
        return (
            base
            and table.find(deadPlayers, player)
            and (playerRevivedTimes[player] or 0) < 1
        )
    else
        return base
    end
end

function GameState.updateLists()
    table.clear(alivePlayers)
    table.clear(deadPlayers)
    LifeEvent:FireAllClients(false)
    for _, player in Players:GetPlayers() do
        local playerLives = lives[player]
        if playerLives == nil then
            playerLives = LIFE_COUNT_FOR_PLAYER
        end

        if playerLives > 0 then
            table.insert(alivePlayers, player)
        else
            table.insert(deadPlayers, player)
        end
    end
end

function GameState.kill(player: Player, reason: string?)
    if not player or not player.Parent then
        return
    end

    local playerLives = lives[player]
    if playerLives == nil then
        playerLives = LIFE_COUNT_FOR_PLAYER
    end
    playerLives -= 1
    lives[player] = playerLives

    for i, p in ipairs(alivePlayers) do
        if p == player then
            table.remove(alivePlayers, i)
            break
        end
    end
    table.insert(deadPlayers, player)

    OnPlayerLostLife:Fire(player)
    updateIcons(player)
    if playerLives > 0 then
        LifeEvent:FireClient(player, true)
        return
    else
        LifeEvent:FireClient(player, true, true)
    end

    SyncDeadEvent:FireAllClients(true, player, deadPlayers, alivePlayers, reason)
    OnPlayerDied:Fire(player)

    logAction(player, "die")
    resetAction(player, "press_streak")
    resetAction(player, "survive_streak")
    cancelPlayerPromises(player)

    Promise.defer(function(resolve)

        task.wait(0.25)

        -- Kill other linked player
        local linked = LinksModule.clearLinks(player)
        if linked then
            GameState.kill(linked)
        end
        resolve()
    end):catch(warn)
end

function GameState.revive(player: Player, reason: string?)
    if not player or not player.Parent then
        return
    end

    lives[player] = LIFE_COUNT_FOR_PLAYER
    if playerRevivedTimes[player] == nil then
        playerRevivedTimes[player] = 0
    end
    playerRevivedTimes[player] += 1

    -- count global revive usage
    revivesThisGame += 1
    GameState.revivesThisGame = revivesThisGame

    for i, p in ipairs(deadPlayers) do
        if p == player then
            table.remove(deadPlayers, i)
            break
        end
    end
    table.insert(alivePlayers, player)

    SyncDeadEvent:FireAllClients(false, player, deadPlayers, alivePlayers, reason)

    updateIcons(player)
    cancelPlayerPromises(player)
end

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

function GameState.connect()
    GuiSpace.PlayerLoaded.Event:Connect(function(player: Player)
        updateIcons(player)
    end)
    Players.PlayerRemoving:Connect(function(player: Player, reason)
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

        LinksModule.clearLinks(player)

        cancelPlayerPromises(player)
    end)
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

function GameState.isDead(player: Player)
    return table.find(deadPlayers, player) ~= nil
end

function GameState.cancelAll()
    for i, player in ipairs(Players:GetPlayers()) do
        cancelPlayerPromises(player)
    end
end

return GameState