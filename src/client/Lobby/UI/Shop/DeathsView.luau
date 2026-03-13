--!strict
--!optimize 2
local DeathsView = {}

local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer

local showDieEffect = require(localPlayer.PlayerScripts.Client.Shared.DieEffectModule)

local Dialog = require(localPlayer.PlayerScripts.Client.Lobby.UI.Dialog)
local State = require(localPlayer.PlayerScripts.Client.Lobby.UI.State)
local Colors = require(localPlayer.PlayerScripts.Client.Lobby.UI.Colors)
local stateInvalidate = State.invalidate

local function invalidate(id: string)
    return stateInvalidate("deaths_" .. id)
end

type DeathsItem = {
    image: string,
    id: string,
}

export type DeathsWidget = {
    item_id: string,
    frame: Frame & {
        TextButton: TextButton & {
            TextLabel: TextLabel
        }
    },
} & State.Widget

local function updateDeaths(id: string, widget: DeathsWidget)
    local button = widget.frame.TextButton
    local buttonText = widget.frame.TextButton.TextLabel
    local item_id = widget.item_id
    local price = State.prices[item_id] or { amount = "..." }

    if item_id == State.deathAnim then
        button.BackgroundColor3 = Colors.greenContainerHigh
        buttonText.TextColor3 = Colors.onGreenContainer
        buttonText.Text = "Equipped"
    elseif table.find(State.owns, item_id) then
        button.BackgroundColor3 = Colors.redContainerHigh
        buttonText.TextColor3 = Colors.onRedContainer
        buttonText.Text = "Equip"
    elseif price["unlockMsg"] ~= nil then
        button.BackgroundColor3 = Colors.containerHigh
        buttonText.TextColor3 = Colors.text
        buttonText.Text = "Unlock"
    else
        button.BackgroundColor3 = Colors.containerHigh
        buttonText.TextColor3 = Colors.text
        buttonText.Text = "Buy (" .. tostring(price.amount) .. ")"
    end
end

local deathsItems: {DeathsItem} = {
    {
        image = "rbxassetid://139098299189373",
        id = "white",
    },
    {
        image = "rbxassetid://139364940882309",
        id = "smoke",
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
        image = "rbxassetid://140523309655719",
        id = "hearts",
    },
    {
        image = "rbxassetid://88691291915491",
        id = "incognito",
    },
    {
        image = "rbxassetid://116357703440514",
        id = "magic",
    },
    {
        image = "rbxassetid://110065419392232",
        id = "explosion",
    },
}

local function testDeathAnimation(id: string)
    showDieEffect(localPlayer, false, false, "test", id, function()
        showDieEffect(localPlayer, true, false, "test", id)
    end)
end

function DeathsView.initialize(window: State.WindowWidget)
    local deaths = window.canvas:WaitForChild("Deaths") :: Frame
    local itemsDeaths = deaths:WaitForChild("Items") :: ScrollingFrame
    local gridDeaths = itemsDeaths:WaitForChild("Grid") :: Frame
    local deathsItemTemplate = gridDeaths:WaitForChild("Template") :: Frame
    deathsItemTemplate.Visible = false

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
        local widget: DeathsWidget = {
            customHandler = updateDeaths,
            item_id = item.id,
            frame = clone :: any
        }
        State.addWidget("deaths_" .. item.id, widget)

        -- If I'm right, connection will be automatically destroyed when item destroys
        button.Activated:Connect(function(inputObject, clickCount)
            if table.find(State.owns, item.id) then
                State.SyncEvent:FireServer("equip_death", item.id)
            else
                State.BuyEvent:FireServer(item.id)
            end
        end)

        image.Activated:Connect(function(inputObject, clickCount)
            Dialog.showDialog("Do you want to test this animation?", {
                { text = "No" },
                {
                    text = "Yes",
                    func = function()
                        State.hideAllWindows()
                        task.wait(0.3)
                        testDeathAnimation(item.id)
                    end
                },
            })
        end)
    end

    State.DeathAnimUpdated.Event:Connect(function(oldValue: string?, newValue: string)
        if oldValue ~= nil then
            invalidate(oldValue)
        end
        invalidate(newValue)
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
                invalidate(id)
            end
        end

        for id in pairs(newSet) do
            if not oldSet[id] then
                invalidate(id)
            end
        end
    end)

    State.PricesUpdated.Event:Connect(function(_, newValue: {[string]: any})
        for key, value in newValue do
            invalidate(key)
        end
    end)

    return deaths
end

return DeathsView