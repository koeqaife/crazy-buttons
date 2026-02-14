--!strict
--!optimize 2
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local GameState = require(script.Parent.GameStateModule)

-- To add or remove tool from player
local ActivateKillTool = Instance.new("RemoteEvent", ReplicatedStorage)
ActivateKillTool.Name = "ActivateKillTool"

-- When player does action
local KillToolAction = Instance.new("RemoteEvent", ReplicatedStorage)
KillToolAction.Name = "KillToolAction"

local SKULL_ICON_WITH_CURSOR = "rbxassetid://138006806112694"
local SKULL_ICON = "rbxassetid://124245040180153"

local playersWithTool: {Player} = {}
local toolMeta: {[Player]: {
    lastSelected: Player?,
    active: boolean?
}} = {}
local selectedPlayers: { [Player]: number } = {}  -- Player: counter

type ActionType = {
    name: string,
    selectPlayer: Player?,
    killPlayer: Player?,
    showTool: boolean?
}

local KillToolModule = {}

local function getMeta(player: Player)
    local meta = toolMeta[player]
    if meta then
        return meta
    else
        toolMeta[player] = {}
        return toolMeta[player]
    end
end

local function showIcon(player: Player, visible: boolean, icon: string?)
    local character = player.Character
    if not character then
        return
    end

    local rootPart = character:FindFirstChild("HumanoidRootPart") :: Part

    local light = rootPart:FindFirstChild("KillToolLight") :: PointLight?
    local gui = character:FindFirstChild("KillToolGui") :: BillboardGui?

    if visible then
        if light == nil then
            local newLight = Instance.new("PointLight")
            newLight.Name = "KillToolLight"
            newLight.Parent = rootPart
            newLight.Brightness = 5.6
            newLight.Range = 6
            newLight.Shadows = true
            newLight.Color = Color3.fromRGB(255, 255, 0)
        end

        if gui == nil then
            local newGui = Instance.new("BillboardGui")
            newGui.Name = "KillToolGui"
            newGui.Adornee = character
            newGui.Parent = character
            newGui.Size = UDim2.new(2, 0, 2, 0)
            newGui.SizeOffset = Vector2.new(0, 0)
            newGui.ExtentsOffsetWorldSpace = Vector3.new(0, 1.5, 0)

            local imageLabel = Instance.new("ImageLabel")
            imageLabel.Name = "icon"
            imageLabel.Parent = newGui
            imageLabel.BackgroundTransparency = 1
            imageLabel.Size = UDim2.new(1, 0, 1, 0)
            if icon then
                imageLabel.Image = icon
            end
        else
            local imageLabel = gui:FindFirstChild("icon") :: ImageLabel?
            if imageLabel and icon then
                imageLabel.Image = icon
            end
        end
    else
        if light ~= nil then
            light:Destroy()
        end
        if gui ~= nil then
            gui:Destroy()
        end
    end
end

local function selectPlayer(player: Player?, select: boolean)
    if not player then
        return
    end
    if selectedPlayers[player] == nil then
        selectedPlayers[player] = 0
    end
    if selectedPlayers[player] < 0 then
        selectedPlayers[player] = 0
    end

    if select then
        selectedPlayers[player] += 1
    else
        selectedPlayers[player] -= 1
    end
end

local function updateIcon(player: Player?)
    if not player then
        return
    end
    local isSelected = (selectedPlayers[player] or 0) > 0
    if isSelected then
        showIcon(player, true, SKULL_ICON)
    else
        local meta = getMeta(player)
        if meta.active then
            showIcon(player, true, SKULL_ICON_WITH_CURSOR)
        else
            showIcon(player, false)
        end
    end
end

function KillToolModule.giveTool(player: Player)
    table.insert(playersWithTool, player)
    ActivateKillTool:FireClient(player, true)
end

function KillToolModule.removeTool(player: Player)
    task.wait()
    table.remove(playersWithTool, table.find(playersWithTool, player))
    ActivateKillTool:FireClient(player, false)

    local meta = getMeta(player)
    meta.active = false
    updateIcon(player)

    selectPlayer(meta.lastSelected, false)
    updateIcon(meta.lastSelected)

    toolMeta[player] = nil
end

local function onAction(player: Player, action: ActionType)
    if not table.find(playersWithTool, player) then
        return
    end

    if action.name == "selectPlayer" then
        local meta = getMeta(player)
        if meta.lastSelected then
            selectPlayer(meta.lastSelected, false)
            updateIcon(meta.lastSelected)
        end

        if action.selectPlayer then
            meta.lastSelected = action.selectPlayer
            selectPlayer(meta.lastSelected, true)
            updateIcon(meta.lastSelected)
        end
    elseif action.name == "showTool" then
        local meta = getMeta(player)
        meta.active = not meta.active
        updateIcon(player)
        if not action.showTool then
            selectPlayer(meta.lastSelected, false)
            updateIcon(meta.lastSelected)
        end
    elseif action.name == "killPlayer" and action.killPlayer then
        GameState.kill(action.killPlayer, "byKillTool")
        KillToolModule.removeTool(player)

        selectPlayer(action.killPlayer, false)
        updateIcon(action.killPlayer)
    end
end

function KillToolModule.init()
    KillToolAction.OnServerEvent:Connect(onAction)
    GameState.OnPlayerDied.Event:Connect(function(player: Player)
        KillToolModule.removeTool(player)
        selectPlayer(player, false)
        updateIcon(player)
    end)
end

return KillToolModule