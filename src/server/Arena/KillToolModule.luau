--!strict
--!optimize 2
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local GameModule = require(script.Parent.GameStateModule)

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
    lastSelected: Player?
}} = {}

type ActionType = {
    name: string,
    selectPlayer: Player?,
    killPlayer: Player?,
    showTool: boolean?
}

local KillToolModule = {}

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
            imageLabel.Parent = newGui
            imageLabel.BackgroundTransparency = 1
            imageLabel.Size = UDim2.new(1, 0, 1, 0)
            if icon then
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

function KillToolModule.giveTool(player: Player)
    table.insert(playersWithTool, player)
    ActivateKillTool:FireClient(player, true)
end

function KillToolModule.removeTool(player: Player)
    task.wait()
    table.remove(playersWithTool, table.find(playersWithTool, player))
    ActivateKillTool:FireClient(player, false)

    showIcon(player, false)
    local meta = toolMeta[player]
    if meta then
        if meta.lastSelected then
            showIcon(meta.lastSelected, false)
        end
    end

    toolMeta[player] = nil
end

local function onAction(player: Player, action: ActionType)
    if not table.find(playersWithTool, player) then
        return
    end

    if action.name == "selectPlayer" then
        local meta = toolMeta[player]
        if meta then
            if meta.lastSelected then
                showIcon(meta.lastSelected, false)
            end
        else
            toolMeta[player] = {}
            meta = toolMeta[player]
        end

        if action.selectPlayer then
            meta.lastSelected = action.selectPlayer
            showIcon(action.selectPlayer, true, SKULL_ICON)
        end
    elseif action.name == "showTool" then
        showIcon(player, action.showTool or false, SKULL_ICON_WITH_CURSOR)
        if not action.showTool then
            local meta = toolMeta[player]
            if meta then
                if meta.lastSelected then
                    showIcon(meta.lastSelected, false)
                end
            end
        end
    elseif action.name == "killPlayer" and action.killPlayer then
        GameModule.kill(action.killPlayer, "byKillTool")
        KillToolModule.removeTool(player)
    end
end

function KillToolModule.init()
    KillToolAction.OnServerEvent:Connect(onAction)
end

return KillToolModule