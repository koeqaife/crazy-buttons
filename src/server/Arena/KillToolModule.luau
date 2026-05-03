--!strict
--!optimize 2
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local Sounds = require(ServerScriptService.Server.Shared.Sounds)
local IconModule = require(script.Parent.IconModule)
local PlayersModule = require(script.Parent.PlayersModule)

-- To add or remove tool from player
local ActivateKillTool = Instance.new("RemoteEvent", ReplicatedStorage)
ActivateKillTool.Name = "ActivateKillTool"

-- When player does action
local KillToolAction = Instance.new("RemoteEvent", ReplicatedStorage)
KillToolAction.Name = "KillToolAction"

local GuiSpace = IconModule.reserveSpace(-2, "KillTool")

local logAction = require(ServerScriptService.Server.Shared.QuestsModule).logAction

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

local function showLight(player: Player, visible: boolean)
    local character = player.Character
    if not character then
        return
    end

    local rootPart = character:FindFirstChild("HumanoidRootPart") :: Part

    local light = rootPart:FindFirstChild("KillToolLight") :: PointLight?

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
    else
        if light ~= nil then
            light:Destroy()
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
        GuiSpace.addIcon(player, "skull", SKULL_ICON)
    else
        GuiSpace.removeIcon(player, "skull")
    end

    local isActive = getMeta(player).active
    if isActive then
        GuiSpace.addIcon(player, "cursor", SKULL_ICON_WITH_CURSOR)
    else
        GuiSpace.removeIcon(player, "cursor")
    end

    showLight(player, isActive or isSelected)
end

function KillToolModule.giveTool(player: Player)
    if not table.find(playersWithTool, player) then
        table.insert(playersWithTool, player)
    end
    ActivateKillTool:FireClient(player, true)
end

function KillToolModule.removeTool(player: Player)
    task.wait()
    local idx = table.find(playersWithTool, player)
    if idx then
        table.remove(playersWithTool, idx)
    end
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
        logAction(player, "kill")
        local ok, err = pcall(function()
            if player:IsFriendsWithAsync(action.killPlayer.UserId) then
                logAction(player, "kill_friend")
            end
        end)
        if not ok then
            warn(err)
        end

        PlayersModule.kill(action.killPlayer, "byKillTool")
        Sounds.serverEvent:FireClient(player, "rbxassetid://140721035016341")
        KillToolModule.removeTool(player)

        selectPlayer(action.killPlayer, false)
        updateIcon(action.killPlayer)
    end
end

function KillToolModule.init()
    KillToolAction.OnServerEvent:Connect(onAction)
    PlayersModule.OnPlayerDied.Event:Connect(function(player: Player)
        task.wait(3)  -- Give player some time to kill someone else
        KillToolModule.removeTool(player)
        selectPlayer(player, false)
        updateIcon(player)
    end)
end

return KillToolModule