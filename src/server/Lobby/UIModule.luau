--!strict
--!optimize 2

local UIModule = {}
local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local DataStoreModule = require(ServerScriptService.Server.Shared.DataStoreModule)
local PurchaseProcessor = require(ServerScriptService.Server.Shared.PurchaseProcessor)

local BuyEvent = Instance.new("RemoteEvent", ReplicatedStorage)
BuyEvent.Name = "BuyEvent"

local SyncEvent = Instance.new("RemoteEvent", ReplicatedStorage)
SyncEvent.Name = "SyncEvent"

local debounceFor: {Player} = {}

type PriceType = {
    currency: "cash",
    amount: number
} | {
    currency: "robux",
    productId: number
} | {
    currency: "badge",
    unlockMsg: string
}

local COINS_100_PRODUCT = 3551873361
local COINS_250_PRODUCT = 3551873921
local COINS_500_PRODUCT = 3551875059
local COINS_1000_PRODUCT = 3551875445

local priceList: {[string]: PriceType} = {
    white = { currency = "cash", amount = 100 },
    smoke = { currency = "cash", amount = 100 },
    purple = { currency = "cash", amount = 200 },
    green = { currency = "cash", amount = 200 },
    hearts = { currency = "cash", amount = 300 },
    incognito = { currency = "cash", amount = 300 },
    magic = { currency = "cash", amount = 400 },
    explosion = { currency = "cash", amount = 3000 },

    bubblesAura = { currency = "cash", amount = 50 },
    purpleAura = { currency = "cash", amount = 150 },
    greenAura = { currency = "cash", amount = 150 },
    incognitoFace = { currency = "cash", amount = 350 },
    magicAura = { currency = "cash", amount = 600 },
    starsAura = { currency = "cash", amount = 600 },
    dangerousAura = { currency = "badge", unlockMsg = "Do the sequence with no mistakes on the combo minigame" },

    coins_100 = { currency = "robux", productId = COINS_100_PRODUCT },
    coins_250 = { currency = "robux", productId = COINS_250_PRODUCT },
    coins_500 = { currency = "robux", productId = COINS_500_PRODUCT },
    coins_1000 = { currency = "robux", productId = COINS_1000_PRODUCT },
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

local function processReceipt(receiptInfo: {PlayerId: number, ProductId: number})
    print("Got receipt", receiptInfo)
    local player = Players:GetPlayerByUserId(receiptInfo.PlayerId)
    if player then
        if receiptInfo.ProductId == COINS_100_PRODUCT then
            DataStoreModule.addCash(player, 100):catch(error):await()
            return Enum.ProductPurchaseDecision.PurchaseGranted
        elseif receiptInfo.ProductId == COINS_250_PRODUCT then
            DataStoreModule.addCash(player, 250):catch(error):await()
            return Enum.ProductPurchaseDecision.PurchaseGranted
        elseif receiptInfo.ProductId == COINS_500_PRODUCT then
            DataStoreModule.addCash(player, 500):catch(error):await()
            return Enum.ProductPurchaseDecision.PurchaseGranted
        elseif receiptInfo.ProductId == COINS_1000_PRODUCT then
            DataStoreModule.addCash(player, 1000):catch(error):await()
            return Enum.ProductPurchaseDecision.PurchaseGranted
        end
    end
    return Enum.ProductPurchaseDecision.NotProcessedYet
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
    DataStoreModule.StreakUpdatedEvent.Event:Connect(function(player: Player, value: number)
        SyncEvent:FireClient(player, "streak", value)
    end)
    DataStoreModule.SurvivesUpdatedEvent.Event:Connect(function(player: Player, value: number)
        SyncEvent:FireClient(player, "survives", value)
    end)
    DataStoreModule.VolumeUpdated.Event:Connect(function(player: Player, value: any)
        SyncEvent:FireClient(player, "volume", value)
    end)
    DataStoreModule.AuraUpdated.Event:Connect(function(player: Player, value: string)
        SyncEvent:FireClient(player, "aura", value)
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
        if price.currency == "badge" then
            return
        elseif price.currency == "cash" then
            if playerBalance >= price.amount then
                DataStoreModule.appendOwns(player, id):catch(error):await()
                DataStoreModule.addCash(player, -price.amount):catch(error):await()
            end
        elseif price.currency == "robux" then
            MarketplaceService:PromptProductPurchase(player, price.productId)
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
            if value == "default" or table.find(owns, value) then
                local newValue = if value == DataStoreModule.getDeathEffect(player) then "default" else value
                DataStoreModule.setDeathEffect(player, newValue):catch(warn):await()
            end
        elseif action == "equip_aura" then
            if value == "default" or table.find(owns, value) then
                local newValue = if value == DataStoreModule.getAura(player) then "default" else value
                DataStoreModule.setAura(player, newValue):catch(warn):await()
            end
        elseif action == "set_volume" then
            local copy = {
                music = value.music,
                ambient = value.ambient
            }
            DataStoreModule.setVolume(player, copy)
        end
    end)

    PurchaseProcessor.addProcessor("shop", 5, processReceipt)
end

return UIModule