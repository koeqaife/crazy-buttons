--!strict
--!optimize 2

local UIModule = {}
local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local DataStoreModule = require(ServerScriptService.Server.Shared.DataStoreModule)
local PurchaseProcessor = require(ServerScriptService.Server.Shared.PurchaseProcessor)

local SyncEvent = Instance.new("RemoteEvent", ReplicatedStorage)
SyncEvent.Name = "SyncEvent"

local debounceFor: {Player} = {}

type PriceType = {
    currency: "cash" | "cookies",
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
    starsAura = { currency = "cookies", amount = 150 },
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

    task.delay(0.3, function()
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
            DataStoreModule.increaseKey(player, "cash", 100)
            return Enum.ProductPurchaseDecision.PurchaseGranted
        elseif receiptInfo.ProductId == COINS_250_PRODUCT then
            DataStoreModule.increaseKey(player, "cash", 250)
            return Enum.ProductPurchaseDecision.PurchaseGranted
        elseif receiptInfo.ProductId == COINS_500_PRODUCT then
            DataStoreModule.increaseKey(player, "cash", 500)
            return Enum.ProductPurchaseDecision.PurchaseGranted
        elseif receiptInfo.ProductId == COINS_1000_PRODUCT then
            DataStoreModule.increaseKey(player, "cash", 1000)
            return Enum.ProductPurchaseDecision.PurchaseGranted
        end
    end
    return Enum.ProductPurchaseDecision.NotProcessedYet
end

local publicFields = {
    owns = "owns",
    cash = "cash",
    currentDeathEffect = "death",
    streak = "streak",
    survives = "survives",
    volume = "volume",
    currentAura = "aura",
    cookies = "cookies",
    quests = "quests"
}

function UIModule.init()
    for dataStoreKey, syncKey in pairs(publicFields) do
        DataStoreModule.getSignal(dataStoreKey).Event:Connect(function(player: Player, value: any)
            SyncEvent:FireClient(player, syncKey, value)
        end)
    end
    Players.PlayerAdded:Connect(function(player)
        SyncEvent:FireClient(player, "prices", priceList)
    end)

    SyncEvent.OnServerEvent:Connect(function(player: Player, action: string, value: any)
        if debounced(player) then return end

        local owns = DataStoreModule.getTable(player, "owns")
        if not owns then
            return
        end

        if action == "equip_death" then
            if value == "default" or table.find(owns, value) then
                local newValue = if value == DataStoreModule.getString(player, "currentDeathEffect") then "default" else value
                DataStoreModule.rewriteKey(player, "currentDeathEffect", newValue)
            end
        elseif action == "equip_aura" then
            if value == "default" or table.find(owns, value) then
                local newValue = if value == DataStoreModule.getString(player, "currentAura") then "default" else value
                DataStoreModule.rewriteKey(player, "currentAura", newValue)
            end
        elseif action == "set_volume" then
            local copy = {
                music = value.music,
                ambient = value.ambient
            }
            DataStoreModule.rewriteKey(player, "volume", copy)
        elseif action == "buy" then

            local price = priceList[value]
            if price == nil then
                return
            end
            if price.currency == "badge" then
                return
            elseif price.currency == "cash" then
                local playerBalance = DataStoreModule.getNumber(player, "cash")
                if playerBalance ~= nil and playerBalance >= price.amount then
                    DataStoreModule.mergeKey(player, "owns", {value})
                    DataStoreModule.increaseKey(player, "cash", -price.amount)
                end
            elseif price.currency == "cookies" then
                local playerCookies = DataStoreModule.getNumber(player, "cookies")
                if playerCookies ~= nil and playerCookies >= price.amount then
                    DataStoreModule.mergeKey(player, "owns", {value})
                    DataStoreModule.increaseKey(player, "cookies", -price.amount)
                end
            elseif price.currency == "robux" then
                MarketplaceService:PromptProductPurchase(player, price.productId)
                -- TODO
            end
        end
    end)

    PurchaseProcessor.addProcessor("shop", 5, processReceipt)
end

return UIModule