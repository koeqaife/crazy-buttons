--!strict
--!optimize 2

local DataStoreService = game:GetService("DataStoreService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserService = game:GetService("UserService")
local Helpers = require(ReplicatedStorage.Shared.Helpers)
local Promise = require(ReplicatedStorage.Shared.Promise)
local PlayerDataStore = DataStoreService:GetDataStore("PlayerData")

local survivesStore = DataStoreService:GetOrderedDataStore("Survives")
local streakStore = DataStoreService:GetOrderedDataStore("Streak")

local DataStoreModule = {}

export type Volume = {
    music: number,
    ambient: number
}
export type PlayerData = {
    survives: number,
    streak: number,
    topStreak: number,
    streakLastUpdated: number,
    pendingRevives: number,
    notJoinedBefore: boolean?,
    currentDeathEffect: string?,
    currentAura: string?,
    owns: { string },
    shownToasts: { string },
    cash: number,
    cookies: number,
    volume: Volume,
    timesPlayed: number,
    questsDay: number,
    quests: {[string]: number}
}

export type PendingChanges = PlayerData & {
    toReset: {string}?
}

local defaultData: PlayerData = {
    survives = 0,
    streak = 0,
    topStreak = 0,
    timesPlayed = 0,
    streakLastUpdated = 0,
    pendingRevives = 0,
    notJoinedBefore = true,
    currentDeathEffect = "default",
    currentAura = "default",
    shownToasts = {},
    owns = {},
    cash = 0,
    cookies = 0,
    volume = {
        music = 0.5,
        ambient = 1
    },
    questsDay = 0,
    quests = {},
}

local dataPerPlayer: { [Player]: PlayerData } = {}
local updatedSignals: { [string]: BindableEvent } = {}
local usersDisplayName: {[number]: string} = {}

DataStoreModule.dataPerPlayer = dataPerPlayer

local pendingChanges: { [Player]: PendingChanges } = {}
local dirtyTimers: { [Player]: boolean } = {}

local FLUSH_DELAY = 15
local MAX_CONCURRENT_UPDATES = 3
local currentUpdates = 0
local updateQueue: { [number]: () -> any } = {}

local function processQueue()
    if #updateQueue == 0 or currentUpdates >= MAX_CONCURRENT_UPDATES then
        return
    end

    local fn = table.remove(updateQueue, 1)
    if not fn then
        return
    end

    currentUpdates += 1
    task.spawn(function()
        local ok, err = pcall(fn)
        if not ok then
            warn("Update task failed:", err)
        end
        currentUpdates -= 1
        processQueue()
    end)
end

local function enqueueUpdate(fn: () -> ())
    table.insert(updateQueue, fn)
    processQueue()
end

local scheduledSignal = false
local scheduledKeys: {[Player]: {string}} = {}

local function flushSignals()
    for player, keys in pairs(scheduledKeys) do
        if not player then
            continue
        end
        local data = dataPerPlayer[player]
        if data == nil then
            continue
        end
        for _, key in ipairs(keys) do
            local signal2: BindableEvent? = updatedSignals[key]
            if signal2 then
                signal2:Fire(player, data[key])
            end
        end
        scheduledKeys[player] = {}
    end
end

local function ensureSignal(key: string)
    local signal: BindableEvent? = updatedSignals[key]
    if signal == nil then
        local newSignal = Instance.new("BindableEvent")
        updatedSignals[key] = newSignal
        return newSignal
    end
    return signal
end

local function onChangedSignal(player: Player?, key: string, immediate: boolean?)
    if player == nil then
        return
    end

    local signal = ensureSignal(key)

    if immediate then
        signal:Fire(player, dataPerPlayer[player][key])
        return
    end

    if scheduledKeys[player] == nil then
        scheduledKeys[player] = {}
    end

    table.insert(scheduledKeys[player], key)
    if scheduledSignal then
        return
    else
        scheduledSignal = true
    end

    task.defer(function()
        flushSignals()
        scheduledSignal = false
    end)
end

local function mergeTables(original: { any }?, toMerge: { any }?)
    local new = table.clone(original or {})
    local set = {}

    if toMerge then
        for _, v in ipairs(new) do
            set[v] = true
        end
        for _, v in ipairs(toMerge) do
            if not set[v] then
                set[v] = true
                table.insert(new, v)
            end
        end
    end

    return new
end

type IncreaseKey = "survives" | "cash" | "pendingRevives" | "timesPlayed" | "cookies"
type SetMaxKey = "topStreak"
type RewriteKey = "volume" | "currentDeathEffect" | "currentAura" | "notJoinedBefore"
                  | "streak" | "streakLastUpdated" | "questsDay" | "quests"
type MergeKey = "owns" | "shownToasts"
type Key = IncreaseKey | SetMaxKey | RewriteKey | MergeKey

local INCREASE_KEYS = {
    "survives",
    "cash",
    "pendingRevives",
    "timesPlayed",
    "cookies"
}

local SET_MAX_KEYS = {
    "topStreak"
}

local REWRITE_KEYS = {
    "volume",
    "currentDeathEffect",
    "currentAura",
    "notJoinedBefore",
    "streak",
    "streakLastUpdated",
    "lastQuestsReset",
    "quests",
    "questsDay"
}

local MERGE_TABLE_KEYS = {
    "owns",
    "shownToasts"
}

local function mergeChanges(old: {[string]: any}?, new: {[string]: any}?): {[string]: any}
    if not old then
        return new and table.clone(new) or {}
    end
    if not new then
        return table.clone(old)
    end

    local out = table.clone(old)
    local newCopy = table.clone(new)

    -- INCREASE_KEYS
    for _, key in ipairs(INCREASE_KEYS) do
        local v = newCopy[key]
        if v ~= nil then
            out[key] = (out[key] or 0) + v
            newCopy[key] = nil
        end
    end

    -- MERGE_TABLE_KEYS
    for _, key in ipairs(MERGE_TABLE_KEYS) do
        local v = newCopy[key]
        if v ~= nil then
            out[key] = out[key] and table.clone(out[key]) or {}
            out[key] = mergeTables(out[key], v)
            newCopy[key] = nil
        end
    end

    -- REWRITE_KEYS
    for _, key in ipairs(REWRITE_KEYS) do
        local v = newCopy[key]
        if v ~= nil then
            out[key] = v
            newCopy[key] = nil
        end
    end

    -- SET_MAX_KEYS
    for _, key in ipairs(SET_MAX_KEYS) do
        local v = newCopy[key]
        if v ~= nil then
            local outValue = (out[key] or 0)
            if v > outValue then
                out[key] = v
            end
            newCopy[key] = nil
        end
    end

    for k, v in pairs(newCopy) do
        if type(v) == "number" then
            out[k] = (out[k] or 0) + v
        elseif type(v) == "table" then
            out[k] = out[k] and table.clone(out[k]) or {}
            out[k] = mergeTables(out[k], v)
        else
            out[k] = v
        end
    end

    return out
end

local function flushPlayer(player: Player)
    if Helpers.getServerType() == "VIPServer" then
        warn("Skipped flushing player on server with type " .. Helpers.getServerType())
        return
    end
    local changes = pendingChanges[player]
    if not changes then
        return
    end

    pendingChanges[player] = nil

    enqueueUpdate(function()
        local ok, result = pcall(function()
            return PlayerDataStore:UpdateAsync(tostring(player.UserId), function(data: PlayerData)
                if data == nil then
                    data = table.clone(defaultData)
                end

                data = mergeChanges(data, changes)
                local toReset = changes["toReset"]
                if toReset ~= nil then
                    for _, key in ipairs(toReset) do
                        data[key] = defaultData[key]
                    end
                end
                data["toReset"] = nil

                for key, value in pairs(defaultData) do
                    if data[key] == nil then
                        data[key] = value
                    end
                end

                return data
            end)
        end)

        if not ok then
            warn("Failed flush for", player.Name, result)

            pendingChanges[player] = mergeChanges(pendingChanges[player], changes)
            return
        end

        for k, v in pairs(changes) do
            if dataPerPlayer[player] == nil then
                continue
            end
            if v ~= dataPerPlayer[player][k] then
                onChangedSignal(player, k)
            end
        end

        local toReset = changes["toReset"]
        if toReset ~= nil then
            for _, k in pairs(toReset) do
                onChangedSignal(player, k)
            end
        end

        dataPerPlayer[player] = result
    end)
end

local function markDirty(player: Player, changeTable: PendingChanges)
    pendingChanges[player] = mergeChanges(pendingChanges[player] or {}, changeTable)
    dataPerPlayer[player] = mergeChanges(dataPerPlayer[player], changeTable)
    dataPerPlayer[player]["toReset"] = nil

    for k, v in pairs(changeTable) do
        onChangedSignal(player, k)
    end

    if dirtyTimers[player] then
        return
    end
    dirtyTimers[player] = true
    task.delay(FLUSH_DELAY, function()
        dirtyTimers[player] = nil
        if player and player.Parent then
            flushPlayer(player)
        elseif player ~= nil then
            flushPlayer(player)
        end
    end)
end

local function setData(player: Player, data: PlayerData?)
    local finalData: PlayerData

    if data == nil then
        finalData = table.clone(defaultData)
    else
        for key, value in pairs(defaultData) do
            if data[key] == nil then
                data[key] = value
            end
        end
        finalData = data
    end

    dataPerPlayer[player] = finalData
    return finalData
end

-- generate hash table --
-- for O(1) on type checks

local typeHashTable: {[string]: string} = {}
for _, key in INCREASE_KEYS do
    typeHashTable[key] = "increase"
end

for _, key in SET_MAX_KEYS do
    typeHashTable[key] = "set_max"
end

for _, key in REWRITE_KEYS do
    typeHashTable[key] = "rewrite"
end

for _, key in MERGE_TABLE_KEYS do
    typeHashTable[key] = "merge"
end

-------------------------

local function checkKey(player: Player, key: string, value: any, writeType: string)
    if type(defaultData[key]) ~= type(value) then
        error(
            "Failed to check key for " .. player.Name .. ". Key -> '"
            .. key .. "' | Value -> '" .. value .. "'. Due to VARIABLE type difference. "
            .. "Type " .. type(defaultData[key]) .. " != " .. type(value)
        )
    elseif typeHashTable[key] ~= writeType then
        error(
            "Failed to check key for " .. player.Name .. ". Key -> '"
            .. key .. "' | Value -> '" .. value .. "'. Due to WRITE type difference. "
            .. "Write type " .. type(typeHashTable[key]) .. " != " .. writeType
        )
    end
end

function DataStoreModule.continueStreak(player: Player)
    local ok, result = pcall(function()
        return PlayerDataStore:UpdateAsync(tostring(player.UserId), function(data: PlayerData?)
            local finalData: PlayerData = data and table.clone(data) or table.clone(defaultData)

            finalData.streak = finalData.streak or 0

            local currentTime = os.time()
            local lastUpdated = finalData.streakLastUpdated or 0
            local timePassed = currentTime - lastUpdated

            if timePassed <= 24 * 60 * 60 then
                -- ignore
            elseif timePassed <= 48 * 60 * 60 then
                finalData.streak += 1
                finalData.streakLastUpdated = currentTime
            else
                finalData.streak = 1
                finalData.streakLastUpdated = currentTime
            end

            print("Changed streak counter for", player.Name, "to", finalData.streak)

            dataPerPlayer[player] = table.clone(finalData)
            return finalData
        end)
    end)

    if not ok then
        warn(result)
    end
end

function DataStoreModule.rewriteKey(player: Player, key: RewriteKey, value: any)
    checkKey(player, key, value, "rewrite")
    markDirty(player, { [key :: string] = value })
end

function DataStoreModule.increaseKey(player: Player, key: IncreaseKey, value: number)
    checkKey(player, key, value, "increase")
    markDirty(player, { [key :: string] = value :: any })
end

function DataStoreModule.setMaxKey(player: Player, key: SetMaxKey, value: number)
    checkKey(player, key, value, "set_max")
    markDirty(player, { [key :: string] = value :: any })
end

function DataStoreModule.mergeKey(player: Player, key: MergeKey, value: {any})
    checkKey(player, key, value, "merge")
    markDirty(player, { [key :: string] = value :: any })
end

local function expectType(player: Player, key: string, expectedType: string): any
    local value = dataPerPlayer[player][key]
    if value == nil then
        value = defaultData[player][key]
    end
    if type(value) ~= expectedType then
        error("Couldn't get value with key " .. key .. " as " .. expectedType .. ". Original type: " .. type(value))
    end
    return value
end

function DataStoreModule.dataLoaded(player: Player): boolean
    return dataPerPlayer[player] ~= nil
end

function DataStoreModule.getNumber(player: Player, key: Key): number
    return expectType(player, key, "number")
end

function DataStoreModule.getString(player: Player, key: Key): string
    return expectType(player, key, "string")
end

function DataStoreModule.getTable(player: Player, key: Key): {any}
    return expectType(player, key, "table")
end

function DataStoreModule.getBoolean(player: Player, key: Key): boolean
    return expectType(player, key, "boolean")
end

function DataStoreModule.getAny(player: Player, key: Key): any
    return dataPerPlayer[player][key]
end

function DataStoreModule.resetKey(player: Player, key: Key)
    markDirty(player, { toReset = {key} } :: any)
end

function DataStoreModule.getSignal(key: Key): BindableEvent
    return ensureSignal(key)
end

local function getTop(from: OrderedDataStore)
    return Promise.promisify(function(): {{ name: string, value: number }}?
        local pages = from:GetSortedAsync(false, 50, 1)
        local top = pages:GetCurrentPage()[1]
        if top then
            local result: {{ name: string, value: number }} = {}

            local currentPage = pages:GetCurrentPage()
            local userIds: {number} = {}
            for rank, entry in ipairs(currentPage) do
                local id = tonumber(entry.key)
                if id == nil or id < 0 or usersDisplayName[id] ~= nil then
                    continue
                end
                table.insert(userIds, id)
            end

            local ok, users = Promise.retryWithDelay(function()
                return Promise.promisify(function()
                    return UserService:GetUserInfosByUserIdsAsync(userIds)
                end)()
            end, 5, 30):await()
            if not ok then
                error(users)
            end

            for _, userInfo in ipairs(users) do
                local username = userInfo.Username
                local displayName = userInfo.DisplayName or username
                if username:lower() == displayName:lower() then
                    usersDisplayName[userInfo.Id] = displayName
                else
                    usersDisplayName[userInfo.Id] = displayName .. " (" .. username .. ")"
                end
            end

            for rank, entry in ipairs(currentPage) do
                local id = tonumber(entry.key)
                if id == nil or id < 0 then
                    continue
                end
                local name = usersDisplayName[id]
                if not name then
                    continue
                end

                table.insert(result, { name = name, value = entry.value })
            end

            return result
        end
        return nil
    end)()
end

function DataStoreModule.getTopStreak()
    return getTop(streakStore)
end

function DataStoreModule.getTopSurvives()
    return getTop(survivesStore)
end

function DataStoreModule.init()
    _G.DataStore = DataStoreModule  -- For debugging

    Players.PlayerAdded:Connect(function(player: Player)
        local success, data: PlayerData? = Promise.retryWithDelay(function()
            return Promise.promisify(function()
                return PlayerDataStore:GetAsync(tostring(player.UserId))
            end)()
        end, 5, 3):await()

        if success then
            local finalData = setData(player, data)

            DataStoreModule.setMaxKey(player, "topStreak", DataStoreModule.getNumber(player, "streak"))
            local ok, err = pcall(function()
                survivesStore:SetAsync(tostring(player.UserId), finalData.survives)
                streakStore:SetAsync(tostring(player.UserId), finalData.topStreak)
            end)
            if not ok then
                warn(err)
            end

            for key, value in pairs(finalData) do
                onChangedSignal(player, key)
            end
        else
            warn("Failed to load data for", player.Name, data)
        end
    end)

    Players.PlayerRemoving:Connect(function(player: Player)
        if pendingChanges[player] then
            flushPlayer(player)

            local waited = 0
            while pendingChanges[player] and waited < 5 do
                task.wait(0.25)
                waited = waited + 0.25
            end
        end
        dataPerPlayer[player] = nil
        pendingChanges[player] = nil
        dirtyTimers[player] = nil
    end)

    game:BindToClose(function()
        print("Saving datastore")
        local snapshot = {}
        for k, v in pairs(pendingChanges) do
            snapshot[k] = v
        end
        for player, _ in pairs(snapshot) do
            if pendingChanges[player] then
                flushPlayer(player)

                local waited = 0
                while pendingChanges[player] and waited < 5 do
                    task.wait(0.25)
                    waited = waited + 0.25
                end
            end
            dataPerPlayer[player] = nil
            pendingChanges[player] = nil
            dirtyTimers[player] = nil
        end
    end)
end

return DataStoreModule
