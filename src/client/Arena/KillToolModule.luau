--!strict
--!optimize 2
local ContentProvider = game:GetService("ContentProvider")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local ActivateKillTool: RemoteEvent = ReplicatedStorage:WaitForChild("ActivateKillTool")
local KillToolAction: RemoteEvent = ReplicatedStorage:WaitForChild("KillToolAction")

local KillToolButton: ImageButton = Players.LocalPlayer
    :WaitForChild("PlayerGui")
    :WaitForChild("ScreenGui")
    :WaitForChild("KillToolButton")
KillToolButton.Visible = false


local INACTIVE_BUTTON_ID = "rbxassetid://137034209932466"
local ACTIVE_BUTTON_ID = "rbxassetid://107748515360604"

-- for preloading
local SKULL_ICON_WITH_CURSOR = "rbxassetid://138006806112694"
local SKULL_ICON = "rbxassetid://124245040180153"

type ActionType = {
    name: string,
    selectPlayer: Player?,
    killPlayer: Player?,
    showTool: boolean?
}

local Player = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local DEBOUNCE_TIME = 0.06

local debounce = false
local active = false
local currentTarget = nil

local KillToolModule = {}

local function getCharacterFromPart(part): Model?
    if not part then return end
    local model = part:FindFirstAncestorOfClass("Model")
    if model and model:FindFirstChild("Humanoid") then
        return model
    end
    return
end

local function checkTargetFromScreenPos(screenPos: Vector2)
    local ray = Camera:ScreenPointToRay(screenPos.X, screenPos.Y)
    local result = workspace:Raycast(ray.Origin, ray.Direction * 60)
    if result and result.Instance then
        local character = getCharacterFromPart(result.Instance)
        return character
    end
    return nil
end

local function fireServer(action: ActionType)
    KillToolAction:FireServer(action)
end

local function toggleActive()
    active = not active
    if active then
        KillToolButton.Image = ACTIVE_BUTTON_ID
    else
        KillToolButton.Image = INACTIVE_BUTTON_ID
    end
    fireServer({
        name = "showTool",
        showTool = active
    })
end

function KillToolModule.connect()
    ActivateKillTool.OnClientEvent:Connect(function(visible)
        KillToolButton.Visible = visible
        if not visible then
            active = false
            KillToolButton.Image = INACTIVE_BUTTON_ID
        end
    end)

    -- Keybinds
    UserInputService.InputBegan:Connect(function(input, processed)
        if processed then return end
        if not KillToolButton.Visible then return end

        if input.KeyCode == Enum.KeyCode.Q or input.KeyCode == Enum.KeyCode.ButtonL2 then
            toggleActive()
        end
    end)


    -- When button clicked
    KillToolButton.MouseButton1Click:Connect(function()
        toggleActive()
    end)

    -- Mouse player selection
    local mouse = Player:GetMouse()
    mouse.Move:Connect(function()
        if debounce then return end
        if not active then return end
        if not KillToolButton.Visible then return end
        debounce = true

        local newTarget = checkTargetFromScreenPos(Vector2.new(mouse.X, mouse.Y))
        if newTarget ~= currentTarget then
            currentTarget = newTarget
            local targetPlayer = Players:GetPlayerFromCharacter(currentTarget)
            if targetPlayer ~= Player then
                fireServer({ name = "selectPlayer", selectPlayer = targetPlayer })
            end
        end

        task.delay(DEBOUNCE_TIME, function()
            debounce = false
        end)
    end)

    -- Gamepad player selection (not tested)
    UserInputService.InputChanged:Connect(function(input)
        if not active then return end
        if not KillToolButton.Visible then return end
        if input.UserInputType == Enum.UserInputType.Gamepad1 then
            if debounce then return end
            debounce = true

            local newTarget = checkTargetFromScreenPos(input.Position)
            if newTarget ~= currentTarget then
                currentTarget = newTarget
                local targetPlayer = Players:GetPlayerFromCharacter(currentTarget)
                if targetPlayer ~= Player then
                    fireServer({ name = "selectPlayer", selectPlayer = targetPlayer })
                end
            end

            task.delay(DEBOUNCE_TIME, function()
                debounce = false
            end)
        end
    end)

    -- When clicked on player
    UserInputService.InputBegan:Connect(function(input, processed)
        if processed then return end
        if not active then return end
        if not KillToolButton.Visible then return end

        if (input.UserInputType == Enum.UserInputType.Gamepad1
            and input.KeyCode == Enum.KeyCode.ButtonR2)
            or input.UserInputType == Enum.UserInputType.MouseButton1
        then
            local target = checkTargetFromScreenPos(input.Position)
            if target then
                local targetPlayer = Players:GetPlayerFromCharacter(target)
                if targetPlayer ~= Player then
                    fireServer({ name = "killPlayer", killPlayer = targetPlayer })
                end
            end
        end
    end)

    local preload = {
        INACTIVE_BUTTON_ID,
        ACTIVE_BUTTON_ID,
        SKULL_ICON_WITH_CURSOR,
        SKULL_ICON
    }

    -- Preload images
    local preloadImages: {ImageLabel} = {}
    for i, id in ipairs(preload) do
        local instance = Instance.new("ImageLabel")
        instance.Image = id
        table.insert(preloadImages, instance)
    end

    ContentProvider:PreloadAsync(preloadImages)
end

return KillToolModule