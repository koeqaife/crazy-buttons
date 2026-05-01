local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer
local camera = workspace.CurrentCamera
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local tweenInfo = TweenInfo.new(
    0.2,
    Enum.EasingStyle.Quad,
    Enum.EasingDirection.Out
)

local sprinting = false
local lastTween: Tween = nil

local function setSprint(state: boolean)
    sprinting = state
    local character = localPlayer.Character or localPlayer.CharacterAdded:Wait()
    local humanoid = character:WaitForChild("Humanoid")

    humanoid.WalkSpeed = state and 32 or 16

    if lastTween then
        lastTween:Cancel()
    end

    lastTween = TweenService:Create(
        camera,
        tweenInfo,
        { FieldOfView = state and 80 or 70 }
    )
    lastTween:Play()
end

UserInputService.InputBegan:Connect(function(input, gpe)
    if input.KeyCode == Enum.KeyCode.ButtonL3 then
        setSprint(not sprinting)
    elseif input.KeyCode == Enum.KeyCode.LeftShift then
        setSprint(true)
    end
end)

UserInputService.InputEnded:Connect(function(input, gpe)
    if input.KeyCode == Enum.KeyCode.LeftShift then
        setSprint(false)
    end
end)

local function setupSprintButton(
    button: TextButton,
    parentFrame: GuiObject
): ()
    local function apply()
        -- Inspired by standard roblox code :P
        local parentSize = parentFrame.AbsoluteSize
        local minAxis = math.min(parentSize.X, parentSize.Y)
        local isSmall = minAxis <= 500

        local size = isSmall and 45 or 75

        button.Size = UDim2.new(0, size, 0, size)
        button.AnchorPoint = Vector2.new(1, 1)

        local pos = if isSmall
            then UDim2.new(1, -(size * 2.4), 1, -(size * 2))
            else UDim2.new(1, -(size * 2.4), 1, -(size * 2.4))

        button.Position = pos
    end

    apply()

    parentFrame:GetPropertyChangedSignal("AbsoluteSize"):Connect(apply)
end

if UserInputService.TouchEnabled then
    local frame = localPlayer:WaitForChild("PlayerGui"):WaitForChild("TouchGui"):WaitForChild("TouchControlFrame")

    local button = Instance.new("ImageButton")
    button.Size = UDim2.new(0, 75, 0, 75)
    button.Position = UDim2.new(1, -240, 1, -240)
    button.Parent = frame
    button.Image = "rbxassetid://118709768438655"
    button.BackgroundTransparency = 1

    setupSprintButton(button, frame)

    button.TouchTap:Connect(function()
        setSprint(not sprinting)
        if sprinting == false then
            button.Image = "rbxassetid://118709768438655"
        elseif sprinting == true then
            button.Image = "rbxassetid://111778431619800"
        end
    end)
end
