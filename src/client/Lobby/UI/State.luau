--!strict
--!optimize 2

local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Colors = require(localPlayer.PlayerScripts.Client.Lobby.UI.Colors)

local State = {}

State.SyncEvent = ReplicatedStorage:WaitForChild("SyncEvent") :: RemoteEvent
State.BuyEvent = ReplicatedStorage:WaitForChild("BuyEvent") :: RemoteEvent

State.CashUpdated = Instance.new("BindableEvent")
State.OwnsUpdated = Instance.new("BindableEvent")
State.PricesUpdated = Instance.new("BindableEvent")
State.DeathAnimUpdated = Instance.new("BindableEvent")
State.SurvivesUpdated = Instance.new("BindableEvent")
State.StreakUpdated = Instance.new("BindableEvent")

type PriceType = {
    currency: "cash" | "robux",
    amount: number
}

State.owns = {} :: {string}
State.cash = 0
State.deathAnim = nil :: string?
State.prices = {} :: {[string]: PriceType}
State.streak = 0
State.survives = 0

State.currentShopPage = "deaths" :: "deaths" | "coins"

State.SyncEvent.OnClientEvent:Connect(function(key: string, value: any)
    print("Got sync event. Key:", key, ", Value:", value)
    if key == "owns" then
        local oldValue = State.owns
        State.owns = value
        State.OwnsUpdated:Fire(oldValue, value)
    elseif key == "cash" then
        local oldValue = State.cash
        State.cash = value
        State.CashUpdated:Fire(oldValue, value)
    elseif key == "prices" then
        local oldValue = State.prices
        State.prices = value
        State.PricesUpdated:Fire(oldValue, value)
    elseif key == "death" then
        local oldValue = State.deathAnim
        State.deathAnim = value
        State.DeathAnimUpdated:Fire(oldValue, value)
    elseif key == "streak" then
        local oldValue = State.streak
        State.streak = value
        State.StreakUpdated:Fire(oldValue, value)
    elseif key == "survives" then
        local oldValue = State.survives
        State.survives = value
        State.SurvivesUpdated:Fire(oldValue, value)
    end
end)

export type Widget = {}

export type DeathsWidget = {
    itemType: "death",
    frame: Frame & {
        TextButton: TextButton & {
            TextLabel: TextLabel
        }
    },
} & Widget

export type HeaderButtonWidget = {
    itemType: "header_button",
    button: TextButton & {
        TextLabel: TextLabel
    },
    page: string,
} & Widget

export type ShopViewWidget = {
    itemType: "shop_view",
    frame: Frame,
    page: string
} & Widget

local itemsWidgets: {[string]: Widget} = {}

local invalidatedItems: {string} = {}
local scheduled = false

function State.invalidate(id: string)
    if not table.find(invalidatedItems, id) then
        table.insert(invalidatedItems, id)
    end
    if scheduled then
        return
    end
    scheduled = true

    task.defer(function()
        local invalidatedSnapshot = invalidatedItems
        invalidatedItems = {}
        scheduled = false

        local owns = State.owns
        local prices = State.prices
        local deathAnim = State.deathAnim
        local currentShopPage = State.currentShopPage

        for _, itemId in ipairs(invalidatedSnapshot) do
            local widgetBase = itemsWidgets[itemId] :: any
            if widgetBase == nil then
                continue
            end

            local itemType = widgetBase.itemType

            if itemType == "death" then
                local deathsWidget = widgetBase :: DeathsWidget
                local button = deathsWidget.frame.TextButton
                local buttonText = deathsWidget.frame.TextButton.TextLabel

                if itemId == deathAnim then
                    button.BackgroundColor3 = Colors.greenContainerHigh
                    buttonText.TextColor3 = Colors.onGreenContainer
                    buttonText.Text = "Equipped"
                elseif table.find(owns, itemId) then
                    button.BackgroundColor3 = Colors.redContainerHigh
                    buttonText.TextColor3 = Colors.onRedContainer
                    buttonText.Text = "Equip"
                else
                    button.BackgroundColor3 = Colors.containerHigh
                    buttonText.TextColor3 = Colors.text
                    buttonText.Text = "Buy (" .. tostring(prices[itemId].amount) .. ")"
                end
            elseif itemType == "header_button" then
                local headerWidget = widgetBase :: HeaderButtonWidget
                local label = headerWidget.button.TextLabel

                if headerWidget.page == currentShopPage then
                    headerWidget.button.BackgroundColor3 = Colors.containerHigh
                    label.FontFace = Font.new(label.FontFace.Family, Enum.FontWeight.Bold, label.FontFace.Style)
                else
                    headerWidget.button.BackgroundColor3 = Colors.container
                    label.FontFace = Font.new(label.FontFace.Family, Enum.FontWeight.Medium, label.FontFace.Style)
                end
            elseif itemType == "shop_view" then
                local shopViewWidget = widgetBase :: ShopViewWidget
                shopViewWidget.frame.Visible = currentShopPage == shopViewWidget.page
            else
                warn("Wrong item type", itemType, "for id", itemId)
            end
        end
    end)
end

function State.addWidget(id: string, widget: Widget)
    itemsWidgets[id] = widget
    State.invalidate(id)
end

return State