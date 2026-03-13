--!strict
--!optimize 2
local AurasView = {}

local Players = game:GetService("Players")
local StarterPlayer = game:GetService("StarterPlayer")
local localPlayer = Players.LocalPlayer

local AuraModule = require(StarterPlayer.StarterPlayerScripts.Client.Shared.AuraModule)

local Dialog = require(localPlayer.PlayerScripts.Client.Lobby.UI.Dialog)
local State = require(localPlayer.PlayerScripts.Client.Lobby.UI.State)
local Colors = require(localPlayer.PlayerScripts.Client.Lobby.UI.Colors)
local stateInvalidate = State.invalidate

local testCounter = 0

local function invalidate(id: string)
    return stateInvalidate("auras_" .. id)
end

type AuraItem = {
    image: string,
    id: string,
}

export type AuraWidget = {
    item_id: string,
    frame: Frame & {
        TextButton: TextButton & {
            TextLabel: TextLabel
        }
    },
} & State.Widget

local function updateAuras(id: string, widget: AuraWidget)
    local button = widget.frame.TextButton
    local buttonText = widget.frame.TextButton.TextLabel
    local item_id = widget.item_id
    local price = State.prices[item_id] or { amount = "..." }

    if item_id == (State.aura or "default") then
        button.BackgroundColor3 = Colors.greenContainerHigh
        buttonText.TextColor3 = Colors.onGreenContainer
        buttonText.Text = "Equipped"
    elseif item_id == "default" or table.find(State.owns, item_id) then
        button.BackgroundColor3 = Colors.redContainerHigh
        buttonText.TextColor3 = Colors.onRedContainer
        buttonText.Text = "Equip"
    elseif price["unlockMsg"] ~= nil then
        button.BackgroundColor3 = Colors.grayContainerHigh
        buttonText.TextColor3 = Colors.onGrayContainer
        buttonText.Text = "Unlock"
    else
        button.BackgroundColor3 = Colors.containerHigh
        buttonText.TextColor3 = Colors.text
        buttonText.Text = "Buy (" .. tostring(price.amount) .. ")"
    end
end

local auraItems: {AuraItem} = {
    {
        image = "rbxassetid://115117619730575",
        id = "default"
    },
    {
        image = "rbxassetid://98821392682951",
        id = "bubblesAura",
    },
    {
        image = "rbxassetid://109775822265749",
        id = "purpleAura",
    },
    {
        image = "rbxassetid://80662372384936",
        id = "greenAura",
    },
    {
        image = "rbxassetid://120310251799900",
        id = "incognitoFace",
    },
    {
        image = "rbxassetid://131459982994900",
        id = "magicAura",
    },
}

local function testAura(id: string)
    testCounter += 1
    local counter = testCounter
    AuraModule.loadAura(localPlayer, id)
    task.wait(30)
    if counter ~= testCounter then
        return
    end
    AuraModule.loadAura(localPlayer, nil)
end

function AurasView.initialize(window: State.WindowWidget)
    local auras = window.canvas:WaitForChild("Auras") :: Frame
    local items = auras:WaitForChild("Items") :: ScrollingFrame
    local grid = items:WaitForChild("Grid") :: Frame
    local itemTemplate = grid:WaitForChild("Template") :: Frame
    itemTemplate.Visible = false

    for _, item in ipairs(auraItems) do
        local clone = itemTemplate:Clone()
        clone.Name = item.id
        clone.Parent = grid
        clone.Visible = true

        local image = clone:WaitForChild("ImageButton") :: ImageButton
        local button = clone:WaitForChild("TextButton") :: TextButton
        local buttonText = button:WaitForChild("TextLabel") :: TextLabel

        buttonText.Text = "..."

        image.Image = item.image
        local widget: AuraWidget = {
            customHandler = updateAuras,
            item_id = item.id,
            frame = clone :: any
        }
        State.addWidget("auras_" .. item.id, widget)

        -- If I'm right, connection will be automatically destroyed when item destroys
        button.Activated:Connect(function(inputObject, clickCount)
            if table.find(State.owns, item.id) then
                State.SyncEvent:FireServer("equip_aura", item.id)
            elseif State.prices[item.id].currency == "badge" then
                Dialog.showDialog(State.prices[item.id].unlockMsg, {
                    { text = "OK" }
                })
            else
                State.BuyEvent:FireServer(item.id)
            end
        end)

        image.Activated:Connect(function(inputObject, clickCount)
            Dialog.showDialog("Do you want to test this aura? (not visible to others in lobby)", {
                { text = "No" },
                {
                    text = "Yes",
                    func = function()
                        State.hideAllWindows()
                        task.wait(0.3)
                        testAura(item.id)
                    end
                },
            })
        end)
    end

    State.AuraUpdated.Event:Connect(function(oldValue: string?, newValue: string)
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

    return auras
end

return AurasView