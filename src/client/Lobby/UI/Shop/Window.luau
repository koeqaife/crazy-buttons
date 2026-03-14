--!strict
--!optimize 2
local Shop = {}

local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer

local SharedUI = localPlayer.PlayerScripts.Client.Shared.UI
local UI = localPlayer.PlayerScripts.Client.Lobby.UI
local State = require(SharedUI.State)
local Colors = require(UI.Colors)

local canvas = localPlayer:WaitForChild("PlayerGui"):WaitForChild("ScreenGui"):WaitForChild("ShopCanvas") :: CanvasGroup
local window = State.createWindow("shop_window", canvas)
Shop.window = window

local header = canvas:WaitForChild("Header")
local closeButton = header:WaitForChild("CloseButton") :: TextButton

local categories = header:WaitForChild("Categories") :: Frame
local categoryTemplate = categories:WaitForChild("Template") :: TextButton
categoryTemplate.Visible = false

local initialized = false
local currentShopPage = "deaths"

type PageItem = {
    name: string,
    page: string,
    module: {
        ["initialize"]: (window: State.WindowWidget) -> Frame
    }
}

export type HeaderButtonWidget = {
    button: TextButton & {
        TextLabel: TextLabel
    },
    page: string,
} & State.Widget

export type ShopViewWidget = {
    frame: Frame,
    page: string
} & State.Widget


local function updateHeaderBtn(id: string, widget: HeaderButtonWidget)
    local label = widget.button.TextLabel

    if widget.page == currentShopPage then
        widget.button.BackgroundColor3 = Colors.containerHigh
        label.FontFace = Font.new(label.FontFace.Family, Enum.FontWeight.Bold, label.FontFace.Style)
    else
        widget.button.BackgroundColor3 = Colors.container
        label.FontFace = Font.new(label.FontFace.Family, Enum.FontWeight.Medium, label.FontFace.Style)
    end
end

local function updateShopView(id: string, widget: ShopViewWidget)
    widget.frame.Visible = currentShopPage == widget.page
end

local pages: {PageItem} = {
    {
        name = "Deaths",
        page = "deaths",
        module = require(UI.Shop.DeathsView)
    },
    {
        name = "Auras",
        page = "auras",
        module = require(UI.Shop.AurasView)
    },
    {
        name = "Coins",
        page = "coins",
        module = require(UI.Shop.CoinsView)
    },
}

function Shop.setPage(page: string)
    local oldPage = currentShopPage

    local oldButtonId = "page_button_" .. oldPage
    local oldPageId = "page_" .. oldPage
    local buttonId = "page_button_" .. page
    local pageId = "page_" .. page

    currentShopPage = page
    State.invalidate(buttonId)
    State.invalidate(pageId)
    State.invalidate(oldButtonId)
    State.invalidate(oldPageId)
end

function Shop.initialize()
    if initialized then
        return
    end

    initialized = true

    for _, item in ipairs(pages) do
        local buttonId = "page_button_" .. item.page
        local pageId = "page_" .. item.page

        local categoryButton = categoryTemplate:Clone()
        categoryButton.Name = buttonId
        categoryButton.Parent = categories
        categoryButton.Visible = true

        categoryButton.Activated:Connect(function()
            Shop.setPage(item.page)
        end)

        local textLabel = categoryButton:WaitForChild("TextLabel") :: TextLabel
        textLabel.Text = item.name

        local buttonWidget: HeaderButtonWidget = {
            customHandler = updateHeaderBtn,
            button = categoryButton :: any,
            page = item.page
        }
        State.addWidget(buttonId, buttonWidget)

        local frame = item.module.initialize(window)
        if frame then
            local viewWidget: ShopViewWidget = {
                customHandler = updateShopView,
                frame = frame :: any,
                page = item.page
            }
            State.addWidget(pageId, viewWidget)
        end
    end

    closeButton.Activated:Connect(function(inputObject, clickCount)
        window.hide()
    end)
end

return Shop