--!strict
--!optimize 2

local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")
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
State.VolumeUpdated = Instance.new("BindableEvent")

type PriceType = {
    currency: "cash" | "robux",
    amount: number,
    unlockMsg: string?
}

State.owns = {} :: {string}
State.cash = 0
State.deathAnim = nil :: string?
State.prices = {} :: {[string]: PriceType}
State.streak = 0
State.survives = 0
State.currentShopPage = "deaths" :: "deaths" | "coins"
State.volume = {
    music = 0.75,
    ambient = 1.0
}

type StateEvent = {
    [string]: {
        stateKey: string,
        event: BindableEvent
    }
}

local events: StateEvent = {
    owns = { stateKey = "owns", event = State.OwnsUpdated },
    cash = { stateKey = "cash", event = State.CashUpdated },
    prices = { stateKey = "prices", event = State.PricesUpdated },
    death = { stateKey = "deathAnim", event = State.DeathAnimUpdated },
    streak = { stateKey = "streak", event = State.StreakUpdated },
    survives = { stateKey = "survives", event = State.SurvivesUpdated },
    volume = { stateKey = "volume", event = State.VolumeUpdated },
}

State.SyncEvent.OnClientEvent:Connect(function(key: string, value: any)
    print("Got sync event. Key:", key, ", Value:", value)

    local entry = events[key]
    if not entry then
        return
    end

    local oldValue = State[entry.stateKey]
    State[entry.stateKey] = value
    entry.event:Fire(oldValue, value)
end)

-- WIDGET SYSTEM --
export type Widget = {
    customHandler: (id: string, widget: any) -> ()?
}

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

-- WINDOW STACK --
local windowsStack: {WindowWidget} = {}
local screenGui = localPlayer:WaitForChild("PlayerGui"):WaitForChild("ScreenGui")
local overlayFrame = Instance.new("Frame", screenGui)
overlayFrame.Name = "OverlayFrame"
overlayFrame.BackgroundColor3 = Color3.new(0, 0, 0)
overlayFrame.Position = UDim2.new(-1.5, 0, -1.5, 0)
overlayFrame.Size = UDim2.new(3, 0, 3, 0)
overlayFrame.Visible = false
overlayFrame.BackgroundTransparency = 1

local function rebuildStackIndexes()
    for i, window in windowsStack do
        window.canvas.ZIndex = (i + 1) * 2
    end
end

local function updateIndexesAndOverlay(id: string, widget: OverlayWidget)
    rebuildStackIndexes()

    local item = windowsStack[#windowsStack]
    if item ~= nil then
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
    local idx = table.find(windowsStack, window)
    if idx then
        table.remove(windowsStack, idx)
    end

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