--!strict
--!optimize 2
local Shop = {}

local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer

local State = require(localPlayer.PlayerScripts.Client.Lobby.UI.State)

local window = localPlayer:WaitForChild("PlayerGui"):WaitForChild("ScreenGui"):WaitForChild("ShopFrame") :: Frame

local header = window:WaitForChild("Header")
local closeButton = header:WaitForChild("CloseButton") :: TextButton

local categories = header:WaitForChild("Categories") :: Frame
local categoryTemplate = categories:WaitForChild("Template") :: TextButton
categoryTemplate.Visible = false

-- DEATHS --
local deaths = window:WaitForChild("Deaths") :: Frame
local itemsDeaths = deaths:WaitForChild("Items") :: ScrollingFrame
local gridDeaths = itemsDeaths:WaitForChild("Grid") :: Frame
local deathsItemTemplate = gridDeaths:WaitForChild("Template") :: Frame
deathsItemTemplate.Visible = false

-- COINS --
local coins = window:WaitForChild("Coins") :: Frame
local gridCoins = coins:WaitForChild("Grid") :: Frame
local coinsItemTemplate = gridCoins:WaitForChild("Template") :: TextButton
coinsItemTemplate.Visible = false

type DeathsItem = {
    image: string,
    id: string,
}

type CoinsItem = {
    value: number,
    id: string,
}

type PageItem = {
    frame: Frame?,
    name: string,
    page: string
}

local deathsItems: {DeathsItem} = {
    {
        image = "rbxassetid://139098299189373",
        id = "white",
    },
    {
        image = "rbxassetid://121265139873257",
        id = "purple",
    },
    {
        image = "rbxassetid://104809033146354",
        id = "green",
    },
    {
        image = "rbxassetid://88691291915491",
        id = "incognito",
    },
    {
        image = "rbxassetid://110065419392232",
        id = "explosion",
    },
}

local coinsItems: {CoinsItem} = {
    {
        value = 100,
        id = "coins_100"
    },
    {
        value = 250,
        id = "coins_250"
    },
    {
        value = 500,
        id = "coins_500"
    },
    {
        value = 1000,
        id = "coins_1000"
    },
}

local pages: {PageItem} = {
    {
        frame = deaths,
        name = "Deaths",
        page = "deaths"
    },
    {
        frame = coins,
        name = "Coins",
        page = "coins"
    },
}

function Shop.showWindow()
    window.Visible = true
end

function Shop.hideWindow()
    window.Visible = false
end

function Shop.setPage(page: string)
    local oldPage = State.currentShopPage

    local oldButtonId = "page_button_" .. oldPage
    local oldPageId = "page_" .. oldPage
    local buttonId = "page_button_" .. page
    local pageId = "page_" .. page

    State.currentShopPage = page
    State.invalidate(buttonId)
    State.invalidate(pageId)
    State.invalidate(oldButtonId)
    State.invalidate(oldPageId)
end

function Shop.initialize()
    for _, item in ipairs(deathsItems) do
        local clone = deathsItemTemplate:Clone()
        clone.Name = item.id
        clone.Parent = gridDeaths
        clone.Visible = true

        local image = clone:WaitForChild("ImageButton") :: ImageButton
        local button = clone:WaitForChild("TextButton") :: TextButton
        local buttonText = button:WaitForChild("TextLabel") :: TextLabel

        buttonText.Text = "..."

        image.Image = item.image
        local widget: State.DeathsWidget = {
            itemType = "death" :: "death",
            frame = clone :: any
        }
        State.addWidget(item.id, widget)

        -- If I'm right, connection will be automatically destroyed when item destroys
        button.Activated:Connect(function(inputObject, clickCount)
            if table.find(State.owns, item.id) then
                State.SyncEvent:FireServer("equip_death", item.id)
            else
                State.BuyEvent:FireServer(item.id)
            end
        end)
    end

    for _, item in ipairs(coinsItems) do
        local clone = coinsItemTemplate:Clone()
        clone.Name = item.id
        clone.Parent = gridCoins
        clone.Visible = true

        local text = clone:WaitForChild("TextLabel") :: TextLabel
        text.Text = tostring(item.value) .. "$"

        clone.Activated:Connect(function(inputObject, clickCount)
            State.BuyEvent:FireServer(item.id)
        end)
    end

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

        local buttonWidget: State.HeaderButtonWidget = {
            itemType = "header_button" :: "header_button",
            button = categoryButton :: any,
            page = item.page
        }
        State.addWidget(buttonId, buttonWidget)

        if item.frame then
            local viewWidget: State.ShopViewWidget = {
                itemType = "shop_view" :: "shop_view",
                frame = item.frame :: any,
                page = item.page
            }
            State.addWidget(pageId, viewWidget)
        end
    end

    State.DeathAnimUpdated.Event:Connect(function(oldValue: string?, newValue: string)
        if oldValue ~= nil then
            State.invalidate(oldValue)
        end
        State.invalidate(newValue)
    end)

    State.OwnsUpdated.Event:Connect(function(oldValue: {string}, newValue: {string})
        oldValue = oldValue or {}
        newValue = newValue or {}

        local oldSet = {}
        for _, id in ipairs(oldValue) do
            oldSet[id] = true
        end

        local newSet = {}
        for _, id in ipairs(newValue) do
            newSet[id] = true
        end

        for id in pairs(oldSet) do
            if not newSet[id] then
                State.invalidate(id)
            end
        end

        for id in pairs(newSet) do
            if not oldSet[id] then
                State.invalidate(id)
            end
        end
    end)

    State.PricesUpdated.Event:Connect(function(_, newValue: {[string]: any})
        for key, value in newValue do
            State.invalidate(key)
        end
    end)

    closeButton.Activated:Connect(function(inputObject, clickCount)
        Shop.hideWindow()
    end)
end

return Shop