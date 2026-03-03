--!strict
--!optimize 2

local LobbyModule = {}

local MAX_PLAYERS = 20
local MIN_PLAYERS = 5
local COUNTDOWN_SECONDS = 75
local TELEPORT_PLACE_ID = 137127365503309

local playerBoardText: TextLabel = workspace
    :WaitForChild("TerminalScreen")
    :WaitForChild("SurfaceGui")
    :WaitForChild("mainText")

local boardText = {
    players="",
    countdown=""
}

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local TeleportService = game:GetService("TeleportService")
local LeaderboardModule = require(script.Parent.LeaderboardModule)
local DataStoreModule = require(ServerScriptService.Server.Shared.DataStoreModule)

local pad: Part = workspace:WaitForChild("TeleportPadTrigger")
local active: {[Player]: boolean} = {}
local queue: {Player} = {}

local InQueueLabel = Instance.new("RemoteEvent", ReplicatedStorage)
InQueueLabel.Name = "InQueueLabel"

local FirstTimeJoined = Instance.new("RemoteEvent", ReplicatedStorage)
FirstTimeJoined.Name = "FirstTimeJoined"

local timerActive = false
local timerTimeLeft = 0
local globalTimerTimeLeft = 0

local function updateBoardText()
    if #boardText.countdown > 0 then
        playerBoardText.Text = boardText.players .. "\n" .. boardText.countdown
    else
        playerBoardText.Text = boardText.players
    end
end

local function updatePadCount(count: number, max: number)
    if count >= MIN_PLAYERS then
        boardText.players = "Players " .. count .. "/" .. max
    else
        boardText.players = "Waiting for " .. (MIN_PLAYERS - count) .. " more player(s)..."
    end
    updateBoardText()
end

local function updatePadCountdown(state: string, reason_or_num: any)
    if state == "finished" or state == "cancel" then
        boardText.countdown = ""
    elseif state == "started" or state == "update" then
        boardText.countdown = "Starting in " .. reason_or_num .. "..."
    end
    updateBoardText()
end

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
    updatePadCount(0, MAX_PLAYERS)

    local teleportOptions = Instance.new("TeleportOptions")
    teleportOptions.ShouldReserveServer = true
    local ok, err = pcall(function()
        TeleportService:TeleportAsync(
            TELEPORT_PLACE_ID,
            playersToTeleport,
            teleportOptions
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
    updatePadCount(countActive(), MAX_PLAYERS)
end

local function stopCountdown(reason: string)
    if not timerActive then
        return
    end
    timerActive = false
    timerTimeLeft = 0
    updatePadCountdown("cancel", reason)
end

local function startCountdown()
    if timerActive then
        return
    end

    timerActive = true
    timerTimeLeft = COUNTDOWN_SECONDS
    globalTimerTimeLeft = 150

    updatePadCountdown("started", COUNTDOWN_SECONDS)

    task.spawn(function()
        while timerActive do
            if countActive() < MIN_PLAYERS then
                stopCountdown("not_enough_players")
                return
            end

            timerTimeLeft -= 1
            globalTimerTimeLeft -= 1
            if timerTimeLeft <= 0 then
                break
            end
            if globalTimerTimeLeft <= 0 then
                stopCountdown("server_timeout")
                break
            end

            updatePadCountdown("update", timerTimeLeft)

            task.wait(1)
        end

        if timerActive then
            timerActive = false
            updatePadCountdown("finished")
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

    local activeCount = countActive()

    if activeCount >= MAX_PLAYERS and timerTimeLeft > 10 then
        timerTimeLeft = 10
    elseif activeCount >= 10 and timerTimeLeft > 45 then
        timerTimeLeft = 45
    elseif activeCount >= 5 and timerTimeLeft > 60 then
        timerTimeLeft = 60
    end

    if activeCount < MAX_PLAYERS then
        active[player] = true
        addHighlight(player)
        InQueueLabel:FireClient(player, true)
    else
        table.insert(queue, player)
        InQueueLabel:FireClient(player, false)
    end

    updatePadCount(countActive(), MAX_PLAYERS)
    checkStartConditions()
end

local function onPlayerExit(player: Player)
    if active[player] then
        active[player] = nil
        removeHighlight(player)
        InQueueLabel:FireClient(player, false)

        if countActive() < MIN_PLAYERS then
            stopCountdown("not_enough_players")
        end

        if countActive() < 10 and timerTimeLeft < 10 then
            timerTimeLeft = 30
        end

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

    updatePadCount(countActive(), MAX_PLAYERS)
    checkStartConditions()
end

function LobbyModule.init()
    DataStoreModule.init()

    game.Players.PlayerAdded:Connect(function(player: Player)
        local leaderstats = Instance.new("Folder")
        leaderstats.Name = "leaderstats"
        leaderstats.Parent = player

        local survives = Instance.new("StringValue")
        survives.Name = "Survives"
        survives.Value = "—"
        survives.Parent = leaderstats

        local streak = Instance.new("StringValue")
        streak.Name = "Day Streak"
        streak.Value = "—"
        streak.Parent = leaderstats

        if DataStoreModule.getSurvives(player) == nil then
            DataStoreModule.SurvivesUpdatedEvent.Event:Wait()
        end

        if DataStoreModule.getStreak(player) == nil then
            DataStoreModule.StreakUpdatedEvent.Event:Wait()
        end

        survives.Value = tostring(DataStoreModule.getSurvives(player) or "—")
        streak.Value = tostring(DataStoreModule.getStreak(player) or "—")
    end)

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

    updatePadCount(0, MAX_PLAYERS)

    DataStoreModule.NeverJoinedBeforeUpdated.Event:Connect(function(player, value)
        if not value then
            return
        end
        FirstTimeJoined:FireClient(player)
        return
    end)

    FirstTimeJoined.OnServerEvent:Connect(function(player)
        DataStoreModule.setNeverJoinedBefore(player, false):await()
    end)

    LeaderboardModule.initFor("streak", workspace:WaitForChild("StreakLeaderboard"))
    LeaderboardModule.initFor("survives", workspace:WaitForChild("SurvivesLeaderboard"))
end

return LobbyModule
