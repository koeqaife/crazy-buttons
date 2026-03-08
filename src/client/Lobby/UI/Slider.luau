--!strict
--!optimize 2

local Slider = {}

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local localPlayer = Players.LocalPlayer

local State = require(localPlayer.PlayerScripts.Client.Lobby.UI.State)
local Colors = require(localPlayer.PlayerScripts.Client.Lobby.UI.Colors)

local clamp = math.clamp
local max = math.max
local floor = math.floor

export type SliderWidget = State.Widget & {
    id: string,
    value: number,
    setValue: (value: number) -> (),
    inputChanged: BindableEvent,
    valueChanged: BindableEvent,

    thumb: Frame,
    frame: Frame,
    activeFrame: Frame & {
        HalfFiller: Frame & {
            UICorner: UICorner
        }
    },
    inactiveFrame: Frame & {
        HalfFiller: Frame & {
            UICorner: UICorner
        }
    },
}

local function setupUICornerFor(instance: Instance, radius: UDim)
    local newUICorner = Instance.new("UICorner", instance)
    newUICorner.CornerRadius = radius
end

local function setupHandlerForSlider(widget: SliderWidget)
    local id = widget.id
    local dragging = false
    local slider = widget.frame

    local function update(input: InputObject)
        local pos = input.Position.X
        local start = slider.AbsolutePosition.X
        local size = slider.AbsoluteSize.X

        local value = clamp((pos - start) / size, 0, 1)

        widget.value = value
        widget.valueChanged:Fire(value)
        State.invalidate(id)
    end

    slider.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
           or input.UserInputType == Enum.UserInputType.Touch
        then
            dragging = true
            update(input)
        end
    end)

    slider.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
           or input.UserInputType == Enum.UserInputType.Touch
        then
            widget.inputChanged:Fire(widget.value)
            dragging = false
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and (
            input.UserInputType == Enum.UserInputType.MouseMovement
            or input.UserInputType == Enum.UserInputType.Touch
        ) then
            update(input)
        end
    end)
end

local function computeRadius(size: number): UDim
    local t = clamp(size / 4, 0, 1)
    local radius = 4 + (1 - t) * 4
    return UDim.new(0, radius)
end

local function sliderHandler(id: string, widget: SliderWidget)
    local horizontalPadding = 8
    local heightOffset = -32

    local totalWidth = widget.frame and widget.frame.AbsoluteSize.X or 0
    local value = clamp(if widget.value then widget.value else 0, 0, 1)

    local activePixelWidth = max(0, floor(value * totalWidth - horizontalPadding))
    local inactivePixelWidth = max(0, floor((1 - value) * totalWidth - horizontalPadding))

    widget.activeFrame.Size = UDim2.new(0, activePixelWidth, 1, heightOffset)
    widget.activeFrame.Position = UDim2.new(0, 0, 0.5, 0)

    widget.inactiveFrame.Size = UDim2.new(0, inactivePixelWidth, 1, heightOffset)
    widget.inactiveFrame.Position = UDim2.new(1, 0, 0.5, 0)

    widget.thumb.Position = UDim2.new(value, 0, 0.5, 0)

    local activeSize = widget.activeFrame.AbsoluteSize.X
    local inactiveSize = widget.inactiveFrame.AbsoluteSize.X

    widget.activeFrame.HalfFiller.UICorner.CornerRadius = computeRadius(inactiveSize)
    widget.inactiveFrame.HalfFiller.UICorner.CornerRadius = computeRadius(activeSize)
end

function Slider.buildOn(id: string, frame: Frame, initialValue: number)
    frame.BackgroundTransparency = 1

    -- Create elements
    local activeFrame = Instance.new("Frame", frame)
    activeFrame.Name = "ActiveFrame"
    local activeHalfFiller = Instance.new("Frame", activeFrame)
    activeHalfFiller.Name = "HalfFiller"

    local inactiveFrame = Instance.new("Frame", frame)
    inactiveFrame.Name = "InactiveFrame"
    local inactiveHalfFiller = Instance.new("Frame", inactiveFrame)
    inactiveHalfFiller.Name = "HalfFiller"

    local thumb = Instance.new("Frame", frame)

    -- Setup elements
    -- 1. Active frame
    activeFrame.AnchorPoint = Vector2.new(0, 0.5)
    activeFrame.BackgroundColor3 = Colors.accent
    activeFrame.Position = UDim2.new(0, 0, 0.5, 0)
    activeFrame.Size = UDim2.new(0.5, -8, 1, -32)
    activeHalfFiller.BackgroundColor3 = Colors.accent
    activeHalfFiller.Position = UDim2.new(0.5, 0, 0, 0)
    activeHalfFiller.Size = UDim2.new(0.5, 0, 1, 0)

    -- 2. Inactive frame
    inactiveFrame.AnchorPoint = Vector2.new(1, 0.5)
    inactiveFrame.BackgroundColor3 = Colors.containerHigh
    inactiveFrame.Position = UDim2.new(1, 0, 0.5, 0)
    inactiveFrame.Size = UDim2.new(0.5, -8, 1, -32)
    inactiveHalfFiller.AnchorPoint = Vector2.new(1, 0)
    inactiveHalfFiller.BackgroundColor3 = Colors.containerHigh
    inactiveHalfFiller.Position = UDim2.new(0.5, 0, 0, 0)
    inactiveHalfFiller.Size = UDim2.new(0.5, 0, 1, 0)

    -- 3. Thumb
    thumb.AnchorPoint = Vector2.new(0.5, 0.5)
    thumb.BackgroundColor3 = Colors.accent
    thumb.Position = UDim2.new(0.5, 0, 0.5, 0)
    thumb.Size = UDim2.new(0, 4, 1, 0)

    -- Setup corners
    setupUICornerFor(thumb, UDim.new(0, 8))
    setupUICornerFor(activeFrame, UDim.new(0, 8))
    setupUICornerFor(inactiveFrame, UDim.new(0, 8))
    setupUICornerFor(activeHalfFiller, UDim.new(0, 4))
    setupUICornerFor(inactiveHalfFiller, UDim.new(0, 4))

    local widget: SliderWidget
    widget = {
        id = id,
        value = initialValue,
        setValue = function(value)
            widget.value = value
            State.invalidate(id)
        end,
        inputChanged = Instance.new("BindableEvent"),
        valueChanged = Instance.new("BindableEvent"),

        thumb = thumb,
        frame = frame,
        activeFrame = activeFrame :: any,
        inactiveFrame = inactiveFrame :: any,
        customHandler = sliderHandler
    }

    frame:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
        State.invalidate(id)
    end)

    setupHandlerForSlider(widget)
    State.addWidget(id, widget)

    return widget
end

return Slider