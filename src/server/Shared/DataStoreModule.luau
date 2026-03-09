--!strict
--!optimize 2

local DataStoreService = game:GetService("DataStoreService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Promise = require(ReplicatedStorage.Shared.Promise)
local PlayerDataStore = DataStoreService:GetDataStore("PlayerData")

local SurvivesUpdated = Instance.new("BindableEvent")
local StreakUpdated = Instance.new("BindableEvent")
local NeverJoinedBeforeUpdated = Instance.new("BindableEvent")
local DeathAnimationUpdated = Instance.new("BindableEvent")
local OwnsUpdated = Instance.new("BindableEvent")
local CashUpdated = Instance.new("BindableEvent")
local VolumeUpdated = Instance.new("BindableEvent")

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
    neverJoinedBefore: boolean?,
    currentDeathEffect: string?,
    owns: { string },
    cash: number,
    volume: Volume
}

local defaultData: PlayerData = {
    survives = 0,
    streak = 0,
    topStreak = 0,
    streakLastUpdated = 0,
    pendingRevives = 0,
    neverJoinedBefore = true,
    currentDeathEffect = "default",
    owns = {},
    cash = 0,
    volume = {
        music = 0.5,
        ambient = 1
    }
}

local dataPerPlayer: { [Player]: PlayerData } = {}

DataStoreModule.dataPerPlayer = dataPerPlayer
DataStoreModule.SurvivesUpdatedEvent = SurvivesUpdated
DataStoreModule.StreakUpdatedEvent = StreakUpdated
DataStoreModule.NeverJoinedBeforeUpdated = NeverJoinedBeforeUpdated
DataStoreModule.DeathAnimationUpdated = DeathAnimationUpdated
DataStoreModule.OwnsUpdated = OwnsUpdated
DataStoreModule.CashUpdated = CashUpdated
DataStoreModule.VolumeUpdated = VolumeUpdated

-- Pending changes (debounce / coalesce)
type PendingChange = {
    survives: number?,
    streak: number?,
    topStreak: number?,
    streakLastUpdated: number?,
    pendingRevives: number?,
    neverJoinedBefore: boolean?,
    currentDeathEffect: string?,
    owns: { string }?,
    cash: number?,
    volume: Volume?
}
local pendingChanges: { [Player]: PendingChange } = {}
local dirtyTimers: { [Player]: boolean } = {}

local FLUSH_DELAY = 5
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

local function mergeOwns(target: { string }?, toAdd: { string }?)
    target = target or {}
    if toAdd and target ~= nil then
        for _, v in ipairs(toAdd) do
            table.insert(target, v)
        end
    end
    return target
end

local function flushPlayer(player: Player)
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

                if changes.survives then
                    data.survives = (data.survives or 0) + changes.survives
                end

                if changes.cash then
                    data.cash = math.max(0, (data.cash or 0) + changes.cash)
                end

                if changes.pendingRevives then
                    data.pendingRevives = math.max(0, (data.pendingRevives or 0) + changes.pendingRevives)
                end

                if changes.owns then
                    data.owns = mergeOwns(data.owns, changes.owns) or {}
                end

                if changes.volume then
                    data.volume = changes.volume
                end

                if changes.currentDeathEffect then
                    data.currentDeathEffect = changes.currentDeathEffect
                end

                if changes.neverJoinedBefore ~= nil then
                    data.neverJoinedBefore = changes.neverJoinedBefore
                end

                if changes.streak then
                    data.streak = changes.streak
                end

                if changes.streakLastUpdated then
                    data.streakLastUpdated = changes.streakLastUpdated
                end

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

            pendingChanges[player] = pendingChanges[player] or {}
            pendingChanges[player] = pendingChanges[player] or changes

            if pendingChanges[player] and changes then
                for k, v in pairs(changes) do
                    if type(v) == "number" then
                        pendingChanges[player][k] = (pendingChanges[player][k] or 0) + v
                    elseif k == "owns_add" then
                        pendingChanges[player][k] = pendingChanges[player][k] or {}
                        for _, vv in ipairs(v) do
                            table.insert(pendingChanges[player][k], vv)
                        end
                    else
                        pendingChanges[player][k] = v
                    end
                end
            end
            return
        end

        dataPerPlayer[player] = result

        local ok2, err2 = pcall(function()
            survivesStore:SetAsync(tostring(player.UserId), result.survives)
            streakStore:SetAsync(tostring(player.UserId), result.topStreak)
        end)
        if not ok2 then
            warn("Failed to set ordered stores:", err2)
        end

        SurvivesUpdated:Fire(player, result.survives)
        StreakUpdated:Fire(player, result.streak)
        NeverJoinedBeforeUpdated:Fire(player, result.neverJoinedBefore)
        DeathAnimationUpdated:Fire(player, result.currentDeathEffect)
        OwnsUpdated:Fire(player, result.owns)
        CashUpdated:Fire(player, result.cash)
        VolumeUpdated:Fire(player, result.volume)
    end)
end

local function markDirty(player: Player, changeTable: PendingChange)
    pendingChanges[player] = pendingChanges[player] or {}

    if changeTable.survives then
        pendingChanges[player].survives = (pendingChanges[player].survives or 0) + changeTable.survives
    end
    if changeTable.cash then
        pendingChanges[player].cash = (pendingChanges[player].cash or 0) + changeTable.cash
    end
    if changeTable.pendingRevives then
        pendingChanges[player].pendingRevives = (pendingChanges[player].pendingRevives or 0) + changeTable.pendingRevives
    end

    if changeTable.owns then
        pendingChanges[player].owns = pendingChanges[player].owns or {}
        for _, v in ipairs(changeTable.owns) do
            table.insert(pendingChanges[player].owns or {}, v)
        end
    end

    -- replace/overwrite fields
    if changeTable.volume then
        pendingChanges[player].volume = changeTable.volume
    end
    if changeTable.currentDeathEffect then
        pendingChanges[player].currentDeathEffect = changeTable.currentDeathEffect
    end
    if changeTable.neverJoinedBefore ~= nil then
        pendingChanges[player].neverJoinedBefore = changeTable.neverJoinedBefore
    end
    if changeTable.streak then
        pendingChanges[player].streak = changeTable.streak
        pendingChanges[player].streakLastUpdated = changeTable.streakLastUpdated or os.time()
    end

    dataPerPlayer[player] = dataPerPlayer[player] or table.clone(defaultData)
    if changeTable.survives then
        dataPerPlayer[player].survives = (dataPerPlayer[player].survives or 0) + changeTable.survives
        SurvivesUpdated:Fire(player, dataPerPlayer[player].survives)
    end
    if changeTable.cash then
        dataPerPlayer[player].cash = math.max(0, (dataPerPlayer[player].cash or 0) + changeTable.cash)
        CashUpdated:Fire(player, dataPerPlayer[player].cash)
    end
    if changeTable.pendingRevives then
        dataPerPlayer[player].pendingRevives = math.max(0, (dataPerPlayer[player].pendingRevives or 0) + changeTable.pendingRevives)
    end
    if changeTable.owns then
        dataPerPlayer[player].owns = dataPerPlayer[player].owns or {}
        for _, v in ipairs(changeTable.owns) do
            table.insert(dataPerPlayer[player].owns, v)
        end
        OwnsUpdated:Fire(player, dataPerPlayer[player].owns)
    end
    if changeTable.volume then
        dataPerPlayer[player].volume = changeTable.volume
        VolumeUpdated:Fire(player, dataPerPlayer[player].volume)
    end
    if changeTable.currentDeathEffect then
        dataPerPlayer[player].currentDeathEffect = changeTable.currentDeathEffect
        DeathAnimationUpdated:Fire(player, dataPerPlayer[player].currentDeathEffect)
    end
    if changeTable.neverJoinedBefore ~= nil then
        dataPerPlayer[player].neverJoinedBefore = changeTable.neverJoinedBefore
        NeverJoinedBeforeUpdated:Fire(player, dataPerPlayer[player].neverJoinedBefore)
    end
    if changeTable.streak then
        dataPerPlayer[player].streak = changeTable.streak
        dataPerPlayer[player].streakLastUpdated = changeTable.streakLastUpdated or os.time()
        StreakUpdated:Fire(player, dataPerPlayer[player].streak)
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

function DataStoreModule.increaseSurvives(player: Player)
    return Promise.promisify(function()
        markDirty(player, { survives = 1 })
        return dataPerPlayer[player]
    end)():catch(function()
        warn("Failed to mark increase survives for", player.Name)
    end)
end

function DataStoreModule.addCash(player: Player, amount: number)
    return Promise.promisify(function()
        markDirty(player, { cash = amount })
        return dataPerPlayer[player]
    end)():catch(function()
        warn("Failed to mark add cash for", player.Name)
    end)
end

function DataStoreModule.appendOwns(player: Player, value: string)
    return Promise.promisify(function()
        markDirty(player, { owns_add = { value } })
        return dataPerPlayer[player]
    end)():catch(function()
        warn("Failed to mark append owns for", player.Name)
    end)
end

function DataStoreModule.setVolume(player: Player, value: Volume)
    return Promise.promisify(function()
        markDirty(player, { volume = value })
        return dataPerPlayer[player]
    end)():catch(function()
        warn("Failed to mark set volume for", player.Name)
    end)
end

function DataStoreModule.setDeathEffect(player: Player, value: string)
    return Promise.promisify(function()
        markDirty(player, { currentDeathEffect = value })
        return dataPerPlayer[player]
    end)():catch(function()
        warn("Failed to mark set death effect for", player.Name)
    end)
end

function DataStoreModule.setNeverJoinedBefore(player: Player, value: boolean)
    return Promise.promisify(function()
        markDirty(player, { neverJoinedBefore = value })
        return dataPerPlayer[player]
    end)():catch(function()
        warn("Failed to mark neverJoinedBefore for", player.Name)
    end)
end

function DataStoreModule.addPendingRevives(player: Player, amount: number)
    return Promise.promisify(function()
        markDirty(player, { pendingRevives = amount })
        return dataPerPlayer[player]
    end)():catch(function()
        warn("Failed to mark add pending revives for", player.Name)
    end)
end

function DataStoreModule.setNewTopStreak(player: Player)
    return Promise.promisify(function()
        return PlayerDataStore:UpdateAsync(tostring(player.UserId), function(data: PlayerData?)
            local finalData: PlayerData

            if data == nil then
                finalData = table.clone(defaultData)
            else
                finalData = data
            end

            if finalData.streak and finalData.streak > (finalData.topStreak or 0) then
                finalData.topStreak = finalData.streak
            end

            dataPerPlayer[player] = dataPerPlayer[player] or table.clone(defaultData)
            dataPerPlayer[player].topStreak = finalData.topStreak
            print("Changed top streak counter for", player.Name, "to", finalData.topStreak)

            local ok, err = pcall(function()
                streakStore:SetAsync(tostring(player.UserId), finalData.topStreak)
            end)

            if not ok then
                warn(err)
            end

            return finalData
        end)
    end)():catch(function()
        warn("Failed to set new top streak for", player.Name)
    end)
end

function DataStoreModule.continueStreak(player: Player)
    return Promise.promisify(function()
        return PlayerDataStore:UpdateAsync(tostring(player.UserId), function(data: PlayerData?)
            local finalData: PlayerData

            if data == nil then
                finalData = table.clone(defaultData)
            else
                finalData = data
            end

            if finalData.streak == nil then
                finalData.streak = 0
            end

            local currentTime = os.time()
            local timePassed = currentTime - (finalData.streakLastUpdated or 0)
            if timePassed <= 24 * 60 * 60 then
                dataPerPlayer[player] = dataPerPlayer[player] or table.clone(defaultData)
                dataPerPlayer[player].streak = finalData.streak
                StreakUpdated:Fire(player, finalData.streak)
                return finalData
            elseif timePassed <= 48 * 60 * 60 then
                finalData.streak += 1
            else
                finalData.streak = 1
            end

            finalData.streakLastUpdated = currentTime
            dataPerPlayer[player] = dataPerPlayer[player] or table.clone(defaultData)
            dataPerPlayer[player].streak = finalData.streak
            print("Changed streak counter for", player.Name, "to", finalData.streak)
            StreakUpdated:Fire(player, finalData.streak)

            DataStoreModule.setNewTopStreak(player):await()

            return finalData
        end)
    end)():catch(function()
        warn("Failed to continue streak for", player.Name)
    end)
end

function DataStoreModule.getOwns(player: Player): { string }?
    if not dataPerPlayer[player] then
        return nil
    end
    return dataPerPlayer[player].owns
end

function DataStoreModule.getSurvives(player: Player): number?
    if not dataPerPlayer[player] then
        return nil
    end
    return dataPerPlayer[player].survives
end

function DataStoreModule.getStreak(player: Player): number?
    if not dataPerPlayer[player] then
        return nil
    end
    return dataPerPlayer[player].streak
end

function DataStoreModule.getCash(player: Player): number?
    if not dataPerPlayer[player] then
        return nil
    end
    return dataPerPlayer[player].cash or 0
end

function DataStoreModule.getPendingRevives(player: Player): number
    if not dataPerPlayer[player] then
        return 0
    end
    return dataPerPlayer[player].pendingRevives or 0
end

function DataStoreModule.getNeverJoinedBefore(player: Player): boolean
    if not dataPerPlayer[player] then
        return true
    end
    return dataPerPlayer[player].neverJoinedBefore or false
end

function DataStoreModule.getDeathEffect(player: Player): string
    if not dataPerPlayer[player] then
        return "default"
    end
    return dataPerPlayer[player].currentDeathEffect or "default"
end

function DataStoreModule.getVolume(player: Player): Volume?
    if not dataPerPlayer[player] then
        return nil
    end
    return dataPerPlayer[player].volume
end

local function getTop(from: OrderedDataStore)
    return Promise.promisify(function(): {{ name: string, value: number }}?
        local pages = from:GetSortedAsync(false, 100, 1)
        local top = pages:GetCurrentPage()[1]
        if top then
            local result: {{ name: string, value: number }} = {}

            for rank, entry in ipairs(pages:GetCurrentPage()) do
                if tonumber(entry.key) < 0 then
                    continue
                end

                local ok, name = pcall(function()
                    return Players:GetNameFromUserIdAsync(entry.key)
                end)
                if ok and name then
                    table.insert(result, { name = name, value = entry.value })
                else
                    warn("Failed to get name for userId", entry.key, name)
                end
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
    game.Players.PlayerAdded:Connect(function(player: Player)
        local success, data: PlayerData? = Promise.retryWithDelay(function()
            return Promise.promisify(function()
                return PlayerDataStore:GetAsync(tostring(player.UserId))
            end)()
        end, 5, 3):await()

        if success then
            local finalData = setData(player, data)

            DataStoreModule.setNewTopStreak(player):await()
            local ok, err = pcall(function()
                survivesStore:SetAsync(tostring(player.UserId), finalData.survives)
                streakStore:SetAsync(tostring(player.UserId), finalData.topStreak)
            end)
            if not ok then
                warn(err)
            end

            SurvivesUpdated:Fire(player, finalData.survives)
            StreakUpdated:Fire(player, finalData.streak)
            NeverJoinedBeforeUpdated:Fire(player, finalData.neverJoinedBefore)
            DeathAnimationUpdated:Fire(player, finalData.currentDeathEffect)
            OwnsUpdated:Fire(player, finalData.owns)
            CashUpdated:Fire(player, finalData.cash)
            VolumeUpdated:Fire(player, finalData.volume)
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
end

return DataStoreModule
