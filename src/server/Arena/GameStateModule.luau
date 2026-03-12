local BadgeService = game:GetService("BadgeService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local TeleportService = game:GetService("TeleportService")
local DataStoreModule = require(ServerScriptService.Server.Shared.DataStoreModule)
local ButtonsModule = require(script.Parent.ButtonsModule)
local Helpers = require(ReplicatedStorage.Shared.Helpers)
local Promise = require(ReplicatedStorage.Shared.Promise)
local GameState = {}

local SyncDeadEvent = Instance.new("RemoteEvent", ReplicatedStorage)
SyncDeadEvent.Name = "SyncDeadEvent"

local rewards: {[Player]: number} = {}
local rewardMultipliers: {[Player]: number} = {}

local alivePlayers: {Player} = {}
local deadPlayers: {Player} = {}
local linkedPlayers: {[Player]: Player} = {}

local registeredInstances: {Instance} = {}

local playerRevivedTimes: {[Player]: number} = {}

-- track how many revives have occurred during the current run
local revivesThisGame = 0

local links: {[string]: {Beam: Beam, Attachment1: Attachment, Attachment2: Attachment}} = {}

local runningPromises: {[Player]: {Promise.TypedPromise<any>}} = {}

local OnPlayerDied: BindableEvent = Instance.new("BindableEvent")
local ForceRevive: BindableEvent = Instance.new("BindableEvent")
local RewardChanged: BindableEvent = Instance.new("BindableEvent")

GameState.alivePlayers = alivePlayers
GameState.deadPlayers = deadPlayers
GameState.linkedPlayers = linkedPlayers
GameState.playerRevivedTimes = playerRevivedTimes
GameState.round = 0
GameState.rewardMultipliers = rewardMultipliers
GameState.OnPlayerDied = OnPlayerDied
GameState.ForceRevive = ForceRevive
GameState.RewardChanged = RewardChanged

local LOBBY_PLACE_ID = 115379867051786

local function createLink(player1: Player, player2: Player)
    if not player1.Character or not player2.Character then return end
    local hrp1 = player1.Character:FindFirstChild("HumanoidRootPart")
    local hrp2 = player2.Character:FindFirstChild("HumanoidRootPart")
    if not hrp1 or not hrp2 then return end

    local attachment1 = Instance.new("Attachment", hrp1)
    local attachment2 = Instance.new("Attachment", hrp2)

    local beam = Instance.new("Beam")
    beam.Attachment0 = attachment1
    beam.Attachment1 = attachment2
    beam.FaceCamera = true
    beam.Color = ColorSequence.new(Color3.fromRGB(56, 138, 245))
    beam.Width0 = 0.2
    beam.Width1 = 0.2
    beam.LightEmission = 1
    beam.LightInfluence = 1
    beam.Parent = hrp1

    -- Transparency: beginning transparent, middle not, end transparent
    beam.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 1),
        NumberSequenceKeypoint.new(0.249, 1),
        NumberSequenceKeypoint.new(0.25, 0),
        NumberSequenceKeypoint.new(0.75, 0),
        NumberSequenceKeypoint.new(0.751, 1),
        NumberSequenceKeypoint.new(1, 1)
    })

    local object = {Beam = beam, Attachment1 = attachment1, Attachment2 = attachment2}
    links[player1.Name .. "_" .. player2.Name] = object
    links[player2.Name .. "_" .. player1.Name] = object
end

local function removeLink(player1: Player, player2: Player)
    local data = links[player1.Name .. "_" .. player2.Name]
    if data then
        data.Beam:Destroy()
        data.Attachment1:Destroy()
        data.Attachment2:Destroy()

        links[player1.Name .. "_" .. player2.Name] = nil
        links[player2.Name .. "_" .. player1.Name] = nil
    end
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

function GameState.runButtonsForDead()
    GameState.runNewPromisePerDead(function(player, protect, await)
        local function clearButtons()
            ButtonsModule.setButtons(player, {})
        end

        GameState.protect(player, Promise.new(function(resolve2, reject, onCancel)
            if GameState.forceReviveIsAllowed(player) then
                local forceReviveText = "Force Random Revive"
                if DataStoreModule.getPendingRevives(player) > 0 then
                    forceReviveText = "Force Random Revive (Bought)"
                end

                ButtonsModule.setButtons(player, {
                    { idx = 3, text = forceReviveText },
                    { idx = 5, text = "Return to lobby" }
                })
            else
                ButtonsModule.setButtons(player, {
                    { idx = 5, text = "Return to lobby" }
                })
            end

            local clickPromise = ButtonsModule.waitForClick(player, -1)
            onCancel(function()
                clickPromise:cancel()
                clearButtons()
            end)

            local _, clickedIdx = clickPromise:catch(error):await()
            clearButtons()

            if clickedIdx == 5 then
                ButtonsModule.setButtons(player, {
                    { idx = 5, text = "Teleporting...", inputDisabled = true }
                })
                TeleportService:Teleport(LOBBY_PLACE_ID, player)
                resolve2()
            elseif clickedIdx == 3 then
                ForceRevive:Fire(player)
                resolve2()
            end
        end)):catch(warn)
    end)
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

    SyncDeadEvent:FireAllClients(true, player, deadPlayers, alivePlayers, reason)
    OnPlayerDied:Fire(player)

    if #alivePlayers < 3 then
        GameState.runFuncPerDead(function(player)
            ButtonsModule.setButtons(player, {
                { idx = 5, text = "Return to lobby" }
            })
        end)
    end

    cancelPlayerPromises(player)

    Promise.defer(function(resolve)
        GameState.flushReward(player)
        task.wait()
        task.wait()
        task.wait()
        task.wait()

        -- Kill other linked player
        local linked = linkedPlayers[player]
        if linked then
            linkedPlayers[linked] = nil
            linkedPlayers[player] = nil
            GameState.kill(linked)
            removeLink(player, linked)
        end
        GameState.runButtonsForDead()
        resolve()
    end):catch(warn)
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
    ButtonsModule.setButtons(player, {})

    cancelPlayerPromises(player)
end

function GameState.linkTogether(player1: Player, player2: Player)
    linkedPlayers[player1] = player2
    linkedPlayers[player2] = player1

    createLink(player1, player2)
end

function GameState.clearLinkedPlayers()
    for player1, player2 in pairs(linkedPlayers) do
        removeLink(player1, player2)
    end
    table.clear(linkedPlayers)
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

        local linked = linkedPlayers[player]
        if linked then
            linkedPlayers[linked] = nil
            linkedPlayers[player] = nil
            removeLink(player, linked)
        end

        cancelPlayerPromises(player)
        GameState.flushReward(player)
    end)
end

local function getFriendsInServer(player: Player): number
    local count = 0

    for _, other: Player in Players:GetPlayers() do
        if other ~= player and player:IsFriendsWithAsync(other.UserId) then
            count += 1
        end
    end

    return count
end

function GameState.getCashMultiplier(player: Player): number
    local friends = getFriendsInServer(player)

    if friends <= 0 then
        return 1
    elseif friends == 1 then
        return 1.15
    elseif friends == 2 then
        return 1.3
    else
        return 1.5
    end
end

function GameState.setupMultipliers()
    for i, player in Players:GetPlayers() do
        rewardMultipliers[player] = GameState.getCashMultiplier(player)
    end
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

function GameState.addRewardTo(player: Player, amount: number)
    amount *= rewardMultipliers[player] or 1
    if rewards[player] == nil then
        rewards[player] = amount
    else
        rewards[player] += amount
    end
    RewardChanged:Fire(player, rewards[player])
end

function GameState.flushReward(player: Player)
    if rewards[player] == nil then
        return
    end
    local cash = rewards[player]
    rewards[player] = nil
    DataStoreModule.addCash(player, math.ceil(cash)):catch(warn)
end

function GameState.registerInstance(instance: Instance)
    table.insert(registeredInstances, instance)
end

function GameState.destroyInstances()
    for i, instance in ipairs(registeredInstances) do
        instance:Destroy()
    end
    table.clear(registeredInstances)
end

return GameState