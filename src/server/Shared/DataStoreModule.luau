--!strict
--!optimize 2

local DataStoreService = game:GetService("DataStoreService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Promise = require(ReplicatedStorage.Shared.Promise)
local PlayerDataStore = DataStoreService:GetDataStore("PlayerData")

local DataStoreModule = {}

type PlayerData = {
    survives: number
}

local defaultData: PlayerData = {
    survives = 0
}

local dataPerPlayer: {[Player]: PlayerData} = {}

DataStoreModule.dataPerPlayer = dataPerPlayer

local function setData(player: Player, data: PlayerData?)
    local finalData: PlayerData

    if not data then
        finalData = table.clone(defaultData)
    else
        for key, value in pairs(defaultData) do
            if data[key] == nil then
                data[key] = value
            end
        end
    end

    dataPerPlayer[player] = finalData
end

function DataStoreModule.increaseSurvives(player: Player)
    return Promise.promisify(function()
        return PlayerDataStore:UpdateAsync(player.UserId, function(data: PlayerData?)
            local finalData: PlayerData

            if not data then
                finalData = table.clone(defaultData)
            end

            finalData.survives += 1
            dataPerPlayer[player].survives = finalData.survives

            return finalData
        end)
    end)():catch(function(err)
        warn("Failed to increase survives for", player.Name)
    end)
end

function DataStoreModule.getSurvives(player: Player): number?
    if not dataPerPlayer[player] then
        return nil
    end
    return dataPerPlayer[player].survives
end

function DataStoreModule.init()
    game.Players.PlayerAdded:Connect(function(player: Player)
        local success, data: PlayerData? = Promise.retryWithDelay(function()
            return Promise.promisify(function()
                return PlayerDataStore:GetAsync(player.UserId)
            end)()
        end, 5, 3)

        if success then
            setData(player, data)
        else
            warn("Failed to load data for", player.Name, data)
        end
    end)
end

return DataStoreModule