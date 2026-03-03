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

local survivesStore = DataStoreService:GetOrderedDataStore("Survives")
local streakStore = DataStoreService:GetOrderedDataStore("Streak")

local DataStoreModule = {}

type PlayerData = {
    survives: number,
    streak: number,
    topStreak: number,
    streakLastUpdated: number,
    pendingRevives: number,
    neverJoinedBefore: boolean?
}

local defaultData: PlayerData = {
    survives = 0,
    streak = 0,
    topStreak = 0,
    streakLastUpdated = 0,
    pendingRevives = 0,
    neverJoinedBefore = true
}

local dataPerPlayer: {[Player]: PlayerData} = {}

DataStoreModule.dataPerPlayer = dataPerPlayer
DataStoreModule.SurvivesUpdatedEvent = SurvivesUpdated
DataStoreModule.StreakUpdatedEvent = StreakUpdated
DataStoreModule.NeverJoinedBeforeUpdated = NeverJoinedBeforeUpdated

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
        return PlayerDataStore:UpdateAsync(player.UserId, function(data: PlayerData?)
            local finalData: PlayerData

            if data == nil then
                finalData = table.clone(defaultData)
            else
                finalData = data
            end

            finalData.survives += 1
            dataPerPlayer[player].survives = finalData.survives
            print("Changed survives counter for", player.Name, "to", finalData.survives)
            SurvivesUpdated:Fire(player, finalData.survives)

            local ok, err = pcall(function()
                survivesStore:SetAsync(player.UserId, finalData.survives)
            end)

            if not ok then
                warn(err)
            end

            return finalData
        end)
    end)():catch(function(err)
        warn("Failed to increase survives for", player.Name)
    end)
end

function DataStoreModule.setNewTopStreak(player: Player)
    return Promise.promisify(function()
        return PlayerDataStore:UpdateAsync(player.UserId, function(data: PlayerData?)
            local finalData: PlayerData

            if data == nil then
                finalData = table.clone(defaultData)
            else
                finalData = data
            end

            if finalData.streak and finalData.streak > (finalData.topStreak or 0) then
                finalData.topStreak = finalData.streak
            end

            dataPerPlayer[player].topStreak = finalData.topStreak
            print("Changed top streak counter for", player.Name, "to", finalData.topStreak)

            local ok, err = pcall(function()
                streakStore:SetAsync(player.UserId, finalData.topStreak)
            end)

            if not ok then
                warn(err)
            end

            return finalData
        end)
    end)():catch(function(err)
        warn("Failed to set new top streak for", player.Name)
    end)
end

function DataStoreModule.continueStreak(player: Player)
    return Promise.promisify(function()
        return PlayerDataStore:UpdateAsync(player.UserId, function(data: PlayerData?)
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
                -- do nothing, keep the streak
                dataPerPlayer[player].streak = finalData.streak
                StreakUpdated:Fire(finalData.streak)
                return finalData
            elseif timePassed <= 48 * 60 * 60 then
                finalData.streak += 1
            else
                finalData.streak = 1
            end

            finalData.streakLastUpdated = currentTime
            dataPerPlayer[player].streak = finalData.streak
            print("Changed streak counter for", player.Name, "to", finalData.streak)
            StreakUpdated:Fire(player, finalData.streak)

            DataStoreModule.setNewTopStreak(player):await()

            return finalData
        end)
    end)():catch(function(err)
        warn("Failed to continue streak for", player.Name)
    end)
end

function DataStoreModule.addPendingRevives(player: Player, amount: number)
    return Promise.promisify(function()
        return PlayerDataStore:UpdateAsync(player.UserId, function(data: PlayerData?)
            local finalData: PlayerData

            if data == nil then
                finalData = table.clone(defaultData)
            else
                finalData = data
            end

            if finalData.pendingRevives == nil then
                finalData.pendingRevives = 0
            end

            finalData.pendingRevives += amount

            if finalData.pendingRevives < 0 then
                finalData.pendingRevives = 0
            end

            dataPerPlayer[player].pendingRevives = finalData.pendingRevives

            return finalData
        end)
    end)():catch(function(err)
        warn("Failed to add pending revives for", player.Name)
    end)
end

function DataStoreModule.setNeverJoinedBefore(player: Player, value: boolean)
    return Promise.promisify(function()
        return PlayerDataStore:UpdateAsync(player.UserId, function(data: PlayerData?)
            local finalData: PlayerData

            if data == nil then
                finalData = table.clone(defaultData)
            else
                finalData = data
            end

            finalData.neverJoinedBefore = value

            dataPerPlayer[player].neverJoinedBefore = value
            NeverJoinedBeforeUpdated:Fire(player, value)

            return finalData
        end)
    end)():catch(function(err)
        warn("Failed to set neverJoinedBefore for", player.Name)
    end)
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
                return PlayerDataStore:GetAsync(player.UserId)
            end)()
        end, 5, 3):await()

        if success then
            local finalData = setData(player, data)

            local ok, err = pcall(function()
                survivesStore:SetAsync(player.UserId, finalData.survives)
                streakStore:SetAsync(player.UserId, finalData.topStreak)
            end)
            if not ok then
                warn(err)
            end

            SurvivesUpdated:Fire(player, finalData.survives)
            StreakUpdated:Fire(player, finalData.streak)
            NeverJoinedBeforeUpdated:Fire(player, finalData.neverJoinedBefore)
        else
            warn("Failed to load data for", player.Name, data)
        end
    end)
end

return DataStoreModule