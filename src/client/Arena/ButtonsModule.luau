--!strict
--!optimize 2

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local IndicesModule = require(ReplicatedStorage.Shared.IndicesType)
type Indices = IndicesModule.Indices

local ButtonClickedEvent: RemoteEvent = ReplicatedStorage:WaitForChild("ButtonClickedEvent")
local UpdateButtonsEvent: RemoteEvent = ReplicatedStorage:WaitForChild("UpdateButtonsEvent")
local ButtonsModule = {}

local buttonSpawn: Part = workspace:WaitForChild("ButtonSpawn")
local buttonTemplate: Model = ReplicatedStorage:WaitForChild("ButtonTemplate")

local GAP = 4;
local BUTTONS = {
    { color = Color3.new(1, 0, 0) },            -- Red
    { color = Color3.new(0, 0.35, 1) },         -- Blue
    { color = Color3.new(1, 0.14, 0.81) },      -- Pink
    { color = Color3.new(0.96, 0.8, 0.19) },    -- Yellow
    { color = Color3.new(0.06, 0.96, 0) },      -- Green

    -- ID>5 is for event "What?"
    { color = Color3.new(1, 0.55, 0) },         -- Orange
    { color = Color3.new(0, 1, 1) },            -- Cyan
    { color = Color3.new(0.6, 0.4, 0.2) },      -- Brown
    { color = Color3.new(0.5, 0, 0.5) },        -- Purple
    { color = Color3.new(0.776, 0.93, 0.427) }, -- Light green
    { color = Color3.new(0.2, 0.8, 0.6) },      -- Mint Green
    { color = Color3.new(0.9, 0.9, 0.9) },      -- Light Gray
    { color = Color3.new(0.3, 0.3, 0.3) },      -- Dark Gray
    { color = Color3.new(0.7, 0, 0) },          -- Dark Red
    { color = Color3.new(0, 0.2, 0.5) },        -- Dark Blue
    { color = Color3.new(1, 1, 0.5) },          -- Light Yellow
    { color = Color3.new(0.8, 0.6, 0) },        -- Gold
    { color = Color3.new(0.5, 1, 0) },          -- Lime Green
    { color = Color3.new(0, 0.5, 0.5) },        -- Teal
    { color = Color3.new(1, 0.5, 0.5) },        -- Salmon
}

local spawnedButtons: { Model } = {}
local spawnedButtonsMap: { [number]: Model } = {}

function ButtonsModule.setButtons(indices: Indices)
    for _, btn in ipairs(spawnedButtons) do
        if btn and btn.Parent then
            btn:Destroy()
        end
    end
    spawnedButtons = {}
    spawnedButtonsMap = {}

    local xOffset = -((#indices - 1) * GAP) / 2

    for _, obj in ipairs(indices) do
        local buttonData = BUTTONS[obj.idx]
        if buttonData then
            local buttonClone: Model = buttonTemplate:Clone()
            buttonClone.Parent = workspace
            buttonClone.Name = "ButtonModel"

            local spawnPos = buttonSpawn.Position + Vector3.new(xOffset, 0, 0)
            buttonClone:MoveTo(spawnPos)

            local buttonPart = buttonClone:FindFirstChild("Button") :: Part

            local text = (buttonPart:FindFirstChild("BillboardGui"):: Part):FindFirstChild("Label") :: TextLabel
            text.Text = obj.text
            text.TextColor3 = buttonData.color

            local surfaceLight = buttonPart:FindFirstChild("SurfaceLight") :: SurfaceLight
            local clickDetector = buttonPart:FindFirstChild("ClickDetector") :: ClickDetector
            local highlight = buttonPart:FindFirstChild("Highlight") :: Highlight

            if obj.highlighted then
                highlight.OutlineTransparency = 0
            else
                highlight.OutlineTransparency = 1
            end

            clickDetector.MouseClick:Connect(function(_)
                ButtonClickedEvent:FireServer(obj.idx)
            end)

            local color
            if obj.disabled then
                color = Color3.new(0.17, 0.17, 0.17)
                clickDetector.MaxActivationDistance = -1
            else
                color = buttonData.color
                clickDetector.MaxActivationDistance = 32
            end

            highlight.FillColor = color
            surfaceLight.Color = color
            buttonPart.Color = color

            table.insert(spawnedButtons, buttonClone)
            spawnedButtonsMap[obj.idx] = buttonClone
            xOffset += GAP
        end
    end
end

function ButtonsModule.updateButtons(indices: Indices)
    for _, obj in ipairs(indices) do
        local buttonData = BUTTONS[obj.idx]
        local button = spawnedButtonsMap[obj.idx]

        if buttonData and button then
            local buttonPart = button:FindFirstChild("Button") :: Part

            local text = (buttonPart:FindFirstChild("BillboardGui"):: Part):FindFirstChild("Label") :: TextLabel
            text.Text = obj.text
            text.TextColor3 = buttonData.color

            local surfaceLight = buttonPart:FindFirstChild("SurfaceLight") :: SurfaceLight
            local clickDetector = buttonPart:FindFirstChild("ClickDetector") :: ClickDetector
            local highlight = buttonPart:FindFirstChild("Highlight") :: Highlight

            if obj.highlighted then
                highlight.OutlineTransparency = 0
            else
                highlight.OutlineTransparency = 1
            end

            local color
            if obj.disabled then
                color = Color3.new(0.17, 0.17, 0.17)
                clickDetector.MaxActivationDistance = -1
            else
                color = buttonData.color
                clickDetector.MaxActivationDistance = 32
            end

            surfaceLight.Color = color
            buttonPart.Color = color
        end
    end
end

function ButtonsModule.connect()
    UpdateButtonsEvent.OnClientEvent:Connect(
        function(type: string, indices: Indices)
            if type == "update" then
                ButtonsModule.updateButtons(indices)
            else
                ButtonsModule.setButtons(indices)
            end
        end
    )
end

return ButtonsModule