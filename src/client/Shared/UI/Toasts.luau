--!strict
--!optimize 2
local Dialog = {}

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local localPlayer = Players.LocalPlayer
local Spring = require(ReplicatedStorage.Shared.spr)

local screenGui = localPlayer:WaitForChild("PlayerGui"):WaitForChild("ScreenGui")
local toast = screenGui:WaitForChild("Toast") :: TextLabel

local shownToasts: {[string]: TextLabel} = {}

local originalPos = toast.Position
local hiddenPos = UDim2.new(
    originalPos.X.Scale,
    originalPos.X.Offset,
    originalPos.Y.Scale + 0.2,
    originalPos.Y.Offset
)

function Dialog.show(id: string, text: string)
    if (shownToasts[id] :: TextLabel?) ~= nil then
        print("Toast already exists:", id)
        return
    end
    print("Create toast:", id)
    local newToast = toast:Clone()
    local toastStroke = newToast:WaitForChild("UIStroke") :: UIStroke
    newToast.Visible = true
    newToast.Text = text
    newToast.BackgroundTransparency = 1
    newToast.TextTransparency = 1
    newToast.Parent = screenGui
    toastStroke.Transparency = 1
    newToast.Position = hiddenPos

    print("Running toast animations:", id)
    Spring.target(newToast, 0.6, 4, {
        Position = originalPos,
        BackgroundTransparency = 0,
        TextTransparency = 0
    })
    Spring.target(toastStroke, 0.6, 4, {
        Transparency = 0
    })

    shownToasts[id] = newToast
end

function Dialog.hide(id: string)
    if not shownToasts[id] then
        return
    end
    local oldToast = shownToasts[id]
    local toastStroke = oldToast:WaitForChild("UIStroke") :: UIStroke

    Spring.target(oldToast, 0.75, 7, {
        Position = hiddenPos,
        BackgroundTransparency = 1,
        TextTransparency = 1
    })
    Spring.target(toastStroke, 0.75, 6, {
        Transparency = 1
    })
    Spring.completed(oldToast, function()
        oldToast:Destroy()
    end)
    shownToasts[id] = nil
end

return Dialog