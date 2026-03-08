--!strict
--!optimize 2

local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Colors = require(localPlayer.PlayerScripts.Client.Lobby.UI.Colors)
local Spring = require(ReplicatedStorage.Shared.spr)

local State = {}

State.SyncEvent = ReplicatedStorage:WaitForChild("SyncEvent") :: RemoteEvent
State.BuyEvent = ReplicatedStorage:WaitForChild("BuyEvent") :: RemoteEvent

-- SERVER VARIABLES --
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

-- WIDGET SYSTEM --
export type Widget = {
    customHandler: (id: string, widget: any) -> ()?
}

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

export type WindowWidget = {
    itemType: "window",
    hide: () -> (),
    show: () -> (),
    toggle: () -> (),
    isVisible: () -> boolean,
    canvas: CanvasGroup,
    originalPos: UDim2,
    originalTransparency: number
} & Widget

export type OverlayWidget = {
    itemType: "overlay",
    frame: Frame
} & Widget

local itemsWidgets: {[string]: Widget} = {}

local invalidatedItems: {string} = {}
local scheduled = false

local function updateDeaths(id: string, widget: DeathsWidget)
    local button = widget.frame.TextButton
    local buttonText = widget.frame.TextButton.TextLabel

    if id == State.deathAnim then
        button.BackgroundColor3 = Colors.greenContainerHigh
        buttonText.TextColor3 = Colors.onGreenContainer
        buttonText.Text = "Equipped"
    elseif table.find(State.owns, id) then
        button.BackgroundColor3 = Colors.redContainerHigh
        buttonText.TextColor3 = Colors.onRedContainer
        buttonText.Text = "Equip"
    else
        button.BackgroundColor3 = Colors.containerHigh
        buttonText.TextColor3 = Colors.text
        buttonText.Text = "Buy (" .. tostring(State.prices[id].amount) .. ")"
    end
end

local function updateHeaderBtn(id: string, widget: HeaderButtonWidget)
    local label = widget.button.TextLabel

    if widget.page == State.currentShopPage then
        widget.button.BackgroundColor3 = Colors.containerHigh
        label.FontFace = Font.new(label.FontFace.Family, Enum.FontWeight.Bold, label.FontFace.Style)
    else
        widget.button.BackgroundColor3 = Colors.container
        label.FontFace = Font.new(label.FontFace.Family, Enum.FontWeight.Medium, label.FontFace.Style)
    end
end

local function updateShopView(id: string, widget: ShopViewWidget)
    widget.frame.Visible = State.currentShopPage == widget.page
end

local function updateWindow(id: string, widget: WindowWidget)
    local canvas = widget.canvas
    local usedSpring = false
    local hiddenPos = UDim2.new(
        widget.originalPos.X.Scale,
        widget.originalPos.X.Offset,
        widget.originalPos.Y.Scale - 0.2,
        widget.originalPos.Y.Offset
    )

    if widget.isVisible() then
        canvas.Position = hiddenPos
        canvas.GroupTransparency = 1

        canvas.Visible = true
        Spring.target(canvas, 0.6, 4, {
            Position = widget.originalPos,
            GroupTransparency = widget.originalTransparency
        })
        usedSpring = true
    else
        if canvas.Visible == false then
            canvas.Position = hiddenPos
            canvas.GroupTransparency = 1
        else
            Spring.target(canvas, 0.75, 6, { Position = hiddenPos, GroupTransparency = 1 })
            usedSpring = true
        end
    end

    if usedSpring then
        Spring.completed(canvas, function()
            if canvas.GroupTransparency == 1 then
                canvas.Visible = false
            end
        end)
    end
end

local invalidateMap = {
    death = updateDeaths,
    header_button = updateHeaderBtn,
    shop_view = updateShopView,
    window = updateWindow
}

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

        for _, itemId in ipairs(invalidatedSnapshot) do
            local widgetBase = itemsWidgets[itemId] :: any
            if widgetBase == nil then
                continue
            end

            if widgetBase.customHandler then
                widgetBase.customHandler(itemId, widgetBase)
                continue
            end

            local itemType = widgetBase.itemType :: string
            if itemType == nil then
                warn("Item type is nil for id", itemId)
            else
                local handler = invalidateMap[itemType]
                if handler then
                    handler(itemId, widgetBase)
                else
                    warn("Wrong item type", itemType, "for id", itemId)
                end
            end
        end
    end)
end

function State.addWidget(id: string, widget: Widget)
    if itemsWidgets[id] ~= nil then
        error("Widget \"" .. "\" already exists.")
    end
    itemsWidgets[id] = widget
    State.invalidate(id)
end

-- WINDOW MANAGEMENT --
function State.createWindow(id: string, canvas: CanvasGroup): WindowWidget
    local window: WindowWidget

    local function onWindowShow()
        State.addToStack(window)
        State.invalidate(id)
    end

    local function onWindowHide()
        State.removeFromStack(window)
        State.invalidate(id)
    end

    local function onWindowToggle()
        local isVisible = State.stackHas(window)
        if isVisible then
            onWindowHide()
        else
            onWindowShow()
        end
    end

    local function isVisible()
        return State.stackHas(window)
    end

    window = {
        itemType = "window" :: "window",
        canvas = canvas,
        show = onWindowShow,
        hide = onWindowHide,
        toggle = onWindowToggle,
        isVisible = isVisible,
        originalPos = canvas.Position,
        originalTransparency = canvas.GroupTransparency
    }

    State.addWidget(id, window)

    return window
end

-- WINDOW STACK / CLOSE ANY HANDLER --
local windowsStack: {WindowWidget} = {}
local screenGui = localPlayer:WaitForChild("PlayerGui"):WaitForChild("ScreenGui")
local overlayFrame = screenGui:WaitForChild("OverlayFrame") :: Frame
overlayFrame.BackgroundTransparency = 1

local function updateIndexesAndOverlay(id: string, widget: OverlayWidget)
    local item = windowsStack[#windowsStack]
    if item ~= nil then
        item.canvas.ZIndex = (#windowsStack + 1) * 2
        overlayFrame.Visible = true
        Spring.target(overlayFrame, 0.75, 6, { BackgroundTransparency = 0.5 })
        overlayFrame.ZIndex = item.canvas.ZIndex - 1
    else
        Spring.target(overlayFrame, 0.75, 6, { BackgroundTransparency = 1 })
    end

    Spring.completed(overlayFrame, function()
        if overlayFrame.BackgroundTransparency == 1 then
            overlayFrame.Visible = false
        end
    end)
end

function State.addToStack(window: WindowWidget)
    table.insert(windowsStack, window)
    State.invalidate("overlay")
end

function State.hideLastInStack()
    local window = windowsStack[#windowsStack]
    if window then
        window.hide()
    end
    State.invalidate("overlay")
    return window
end

function State.removeFromStack(window: WindowWidget)
    local idx = table.find(windowsStack, window)
    if idx then
        table.remove(windowsStack, idx)
    end
    State.invalidate("overlay")
    return window
end

function State.stackHas(window: WindowWidget)
    return table.find(windowsStack, window) ~= nil
end

function State.hideAllWindows()
    for _, window in table.clone(windowsStack) do
        if window then
            window.hide()
        end
    end
    State.invalidate("overlay")
end

State.addWidget("overlay", {
    customHandler = updateIndexesAndOverlay
})
State.invalidate("overlay")

return State