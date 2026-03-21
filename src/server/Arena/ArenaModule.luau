--!strict
--!optimize 2
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local Arena = game:GetService("ServerScriptService").Server.Arena

local ArenaModule = {}

local loadedPlayers = {}
local PlayerLoaded = Instance.new("RemoteEvent", ReplicatedStorage)
PlayerLoaded.Name = "PlayerLoaded"

local SyncVolumesEvent = Instance.new("RemoteEvent", ReplicatedStorage)
SyncVolumesEvent.Name = "SyncVolumesEvent"

local DataStoreModule = require(ServerScriptService.Server.Shared.DataStoreModule)
local MusicModule = require(ServerScriptService.Server.Shared.MusicModule)
local QuestsModule = require(ServerScriptService.Server.Shared.QuestsModule)
local IconModule = require(script.Parent.IconModule)
local KillToolModule = require(script.Parent.KillToolModule)
local PlayersModule = require(script.Parent.PlayersModule)
local RewardsModule = require(script.Parent.RewardsModule)
local UIModule = require(script.Parent.UIModule)
local GameLoopModule = require(Arena.GameLoopModule)
local ButtonsModule = require(Arena.ButtonsModule)
local TimerModule = require(Arena.TimerModule)
local TextModule = require(Arena.TextModule)

local logAction = require(ServerScriptService.Server.Shared.QuestsModule).logAction

require(Arena.TextModule)

local mainText: TextLabel = workspace
    :WaitForChild("TerminalScreen")
    :WaitForChild("SurfaceGui")
    :WaitForChild("mainText")

local function allPlayersLoaded()
    local playersCount = #Players:GetPlayers()
    for _, player in Players:GetPlayers() do
        local joinData = player:GetJoinData()
        if joinData and joinData.TeleportData then
            if (joinData.TeleportData.playersCount or -1) > playersCount then
                return false
            end
        end
        if not loadedPlayers[player] then
            return false
        end
    end
    return true
end

function ArenaModule.init()
    DataStoreModule.init()
    ButtonsModule.init()
    KillToolModule.init()
    TimerModule.start()
    PlayersModule.connect()
    MusicModule.init()
    UIModule.init()
    TextModule.init()
    QuestsModule.init()
    IconModule.init()

    mainText.Text = "Waiting for players..."

    DataStoreModule.getSignal("volume").Event:Connect(function(player: Player, value: any)
        SyncVolumesEvent:FireClient(player, value)
    end)

    PlayerLoaded.OnServerEvent:Connect(function(player)
        if loadedPlayers[player] == true then
            -- To make sure nobody will abuse this event
            return
        end

        logAction(player, "play")
        DataStoreModule.continueStreak(player)
        table.insert(PlayersModule.alivePlayers, player)
        loadedPlayers[player] = true

        player:SetAttribute("death", DataStoreModule.getString(player, "currentDeathEffect") or "default")
        player:SetAttribute("aura", DataStoreModule.getString(player, "currentAura") or "default")
    end)

    DataStoreModule.getSignal("currentDeathEffect").Event:Connect(function(player: Player, value: string)
        print("Death animation set for", player.DisplayName, "to", value)
        player:SetAttribute("death", value)
    end)

    DataStoreModule.getSignal("currentAura").Event:Connect(function(player: Player, value: string)
        print("Aura set for", player.DisplayName, "to", value)
        player:SetAttribute("aura", value)
    end)

    Players.PlayerRemoving:Connect(function(player)
        loadedPlayers[player] = nil
    end)

    task.spawn(function()
        TimerModule.setTime(-1)
        local waited = 0

        while task.wait(1) do
            TimerModule.setTime(30 - waited)
            if #Players:GetPlayers() > 0 then
                waited += 1
                if waited >= 30 then
                    break
                elseif allPlayersLoaded() then
                    break
                end
            end
        end

        TimerModule.setTime(5)
        task.wait(5)

        RewardsModule.setupMultipliersAndFriendQuest()
        UIModule.sendMultipliers()

        print("loaded")
        GameLoopModule.start()
    end)
end

return ArenaModule
