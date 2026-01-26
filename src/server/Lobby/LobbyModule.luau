--!strict
--!optimize 2

local LobbyModule = {}

local MAX_PLAYERS = 20
local MIN_PLAYERS = 10
local COUNTDOWN_SECONDS = 30
local TELEPORT_PLACE_ID = 137127365503309

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TeleportService = game:GetService("TeleportService")

local pad: Part = workspace:WaitForChild("TeleportPadTrigger")
local active: {[Player]: boolean} = {}
local queue: {Player} = {}

local UpdatePadCount = Instance.new("RemoteEvent", ReplicatedStorage)
UpdatePadCount.Name = "UpdatePadCount"

local InQueueLabel = Instance.new("RemoteEvent", ReplicatedStorage)
InQueueLabel.Name = "InQueueLabel"

local PadCountdown = Instance.new("RemoteEvent", ReplicatedStorage)
PadCountdown.Name = "PadCountdown"

local timerActive = false
local timerEndTime = 0

local function countActive()
    local count = 0
    for _ in pairs(active) do
        count += 1
    end
    return count
end

local function addHighlight(player: Player)
    if player.Character and not player.Character:FindFirstChild("PadHighlight") then
        local highlight = Instance.new("Highlight")
        highlight.Name = "PadHighlight"
        highlight.Adornee = player.Character
        highlight.FillColor = Color3.fromRGB(209, 123, 86)
        highlight.FillTransparency = 0.7
        highlight.OutlineTransparency = 1.0
        highlight.DepthMode = Enum.HighlightDepthMode.Occluded
        highlight.Parent = player.Character
    end
end

local function removeHighlight(player: Player)
    if player.Character then
        local highlight = player.Character:FindFirstChild("PadHighlight")
        if highlight then
            highlight:Destroy()
        end
    end
end

local function promoteFromQueue(limit)
    local promoted = 0
    while promoted < limit and #queue > 0 do
        local nextPlayer = table.remove(queue, 1)
        if nextPlayer and Players:FindFirstChild(nextPlayer.Name) then
            active[nextPlayer] = true
            addHighlight(nextPlayer)
            InQueueLabel:FireClient(nextPlayer, true)
            promoted += 1
        end
    end
end

local function startGame()
    local playersToTeleport = {}

    for player, _ in pairs(active) do
        if Players:FindFirstChild(player.Name) then
            table.insert(playersToTeleport, player)
        end
    end

    if #playersToTeleport < MIN_PLAYERS then
        return
    end

    active = {}
    UpdatePadCount:FireAllClients(0, MAX_PLAYERS)

    local ok, err = pcall(function()
        TeleportService:TeleportAsync(
            TELEPORT_PLACE_ID,
            playersToTeleport
        )
    end)

    if not ok then
        warn("TeleportAsync failed:", err)

        local spawn: SpawnLocation? = workspace:FindFirstChild("SpawnLocation")
        if spawn then
            for _, player in ipairs(playersToTeleport) do
                removeHighlight(player)
                InQueueLabel:FireClient(player, false)

                if player.Character then
                    local humanoidRootPart = player.Character:FindFirstChild("HumanoidRootPart") :: Part?

                    if player.Character and humanoidRootPart then
                        humanoidRootPart.CFrame = spawn.CFrame + Vector3.new(0, 3, 0)
                    end
                end
            end
        end
    end

    promoteFromQueue(MAX_PLAYERS)
    UpdatePadCount:FireAllClients(countActive(), MAX_PLAYERS)
end

local function stopCountdown(reason)
    if not timerActive then
        return
    end
    timerActive = false
    timerEndTime = 0
    PadCountdown:FireAllClients("cancel", reason)
end

local function startCountdown()
    if timerActive then
        return
    end

    timerActive = true
    timerEndTime = tick() + COUNTDOWN_SECONDS

    PadCountdown:FireAllClients("started", COUNTDOWN_SECONDS)

    task.spawn(function()
        while timerActive do
            local remaining = math.max(0, math.ceil(timerEndTime - tick()))

            if countActive() < MIN_PLAYERS then
                stopCountdown("not_enough_players")
                return
            end

            PadCountdown:FireAllClients("update", remaining)

            if remaining <= 0 then
                break
            end

            task.wait(1)
        end

        if timerActive then
            timerActive = false
            PadCountdown:FireAllClients("finished")
            startGame()
            if countActive() >= MIN_PLAYERS then
                startCountdown()
            end
        end
    end)
end

local function checkStartConditions()
    if countActive() >= MIN_PLAYERS then
        startCountdown()
    else
        if timerActive then
            stopCountdown("not_enough_players")
        end
    end
end


local function onPlayerEnter(player: Player)
    if active[player] then
        return
    end

    for _, queuedPlayer in ipairs(queue) do
        if queuedPlayer == player then
            return
        end
    end

    if countActive() < MAX_PLAYERS then
        active[player] = true
        addHighlight(player)
        InQueueLabel:FireClient(player, true)
    else
        table.insert(queue, player)
        InQueueLabel:FireClient(player, false)
    end

    UpdatePadCount:FireAllClients(countActive(), MAX_PLAYERS)
    checkStartConditions()
end

local function onPlayerExit(player: Player)
    if active[player] then
        active[player] = nil
        removeHighlight(player)
        InQueueLabel:FireClient(player, false)

        local nextPlayer = table.remove(queue, 1)
        if nextPlayer then
            active[nextPlayer] = true
            addHighlight(nextPlayer)
            InQueueLabel:FireClient(nextPlayer, true)
        end
    else
        for i, queuedPlayer in ipairs(queue) do
            if queuedPlayer == player then
                table.remove(queue, i)
                break
            end
        end
    end

    UpdatePadCount:FireAllClients(countActive(), MAX_PLAYERS)
    checkStartConditions()
end

function LobbyModule.init()
    -- On touched
    pad.Touched:Connect(function(hit)
        local character = hit.Parent
        local player = Players:GetPlayerFromCharacter(character)
        if player then
            onPlayerEnter(player)
        end
    end)

    -- On touch ended
    pad.TouchEnded:Connect(function(hit)
        local character = hit.Parent
        local player = Players:GetPlayerFromCharacter(character)
        if player then
            onPlayerExit(player)
        end
    end)

    -- Player left
    Players.PlayerRemoving:Connect(function(player)
        onPlayerExit(player)
    end)

    -- Player joined
    Players.PlayerAdded:Connect(function(player)
        UpdatePadCount:FireClient(player, countActive(), MAX_PLAYERS)
    end)

    TeleportService:SetTeleportSetting("ShouldReserveServer", true)
end

return LobbyModule
