--!strict
--!optimize 2

local UIModule = {}
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local DataStoreModule = require(ServerScriptService.Server.Shared.DataStoreModule)

local BuyEvent = Instance.new("RemoteEvent", ReplicatedStorage)
BuyEvent.Name = "BuyEvent"

local SyncEvent = Instance.new("RemoteEvent", ReplicatedStorage)
SyncEvent.Name = "SyncEvent"

local debounceFor: {Player} = {}

type PriceType = {
    currency: "cash" | "robux",
    amount: number
}

local priceList: {[string]: PriceType} = {
    white = { currency = "cash", amount = 100 },
    purple = { currency = "cash", amount = 200 },
    green = { currency = "cash", amount = 200 },
    incognito = { currency = "cash", amount = 300 },
    explosion = { currency = "cash", amount = 3000 },
}

local function debounced(player: Player)
    if table.find(debounceFor, player) then
        return true
    end

    table.insert(debounceFor, player)

    task.delay(1, function()
        local index = table.find(debounceFor, player)
        if index then
            table.remove(debounceFor, index)
        end
    end)

    return false
end

function UIModule.init()
    DataStoreModule.OwnsUpdated.Event:Connect(function(player: Player, owns: {string})
        SyncEvent:FireClient(player, "owns", owns)
    end)
    DataStoreModule.CashUpdated.Event:Connect(function(player: Player, newAmount: number)
        SyncEvent:FireClient(player, "cash", newAmount)
    end)
    DataStoreModule.DeathAnimationUpdated.Event:Connect(function(player: Player, value: string)
        SyncEvent:FireClient(player, "death", value)
    end)
    Players.PlayerAdded:Connect(function(player)
        SyncEvent:FireClient(player, "prices", priceList)
    end)

    BuyEvent.OnServerEvent:Connect(function(player: Player, id: string)
        if debounced(player) then return end

        local playerBalance = DataStoreModule.getCash(player)
        if playerBalance == nil then
            return
        end

        local price = priceList[id]
        if price.currency == "cash" then
            if playerBalance >= price.amount then
                DataStoreModule.appendOwns(player, id):catch(error):await()
                DataStoreModule.addCash(player, -price.amount):catch(error):await()
            end
        elseif price.currency == "robux" then
            -- TODO
        end
    end)

    SyncEvent.OnServerEvent:Connect(function(player: Player, action: string, value: any)
        if debounced(player) then return end

        local owns = DataStoreModule.getOwns(player)
        if not owns then
            return
        end

        if action == "equip_death" then
            if table.find(owns, value) then
                local newValue = if value == DataStoreModule.getDeathEffect(player) then "default" else value
                DataStoreModule.setDeathEffect(player, newValue):catch(warn):await()
            end
        end
    end)
end

return UIModule