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
local GameStateModule = require(script.Parent.GameStateModule)
local KillToolModule = require(script.Parent.KillToolModule)
local UIModule = require(script.Parent.UIModule)
local GameLoopModule = require(Arena.GameLoopModule)
local ButtonsModule = require(Arena.ButtonsModule)
local TimerModule = require(Arena.TimerModule)
local TextModule = require(Arena.TextModule)

require(Arena.TextModule)

local mainText: TextLabel = workspace
    :WaitForChild("TerminalScreen")
    :WaitForChild("SurfaceGui")
    :WaitForChild("mainText")

local function allPlayersLoaded()
    for _, player in Players:GetPlayers() do
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
    GameStateModule.connect()
    MusicModule.init()
    UIModule.init()
    TextModule.init()

    mainText.Text = "Waiting for players..."

    DataStoreModule.VolumeUpdated.Event:Connect(function(player: Player, value: any)
        SyncVolumesEvent:FireClient(player, value)
    end)

    PlayerLoaded.OnServerEvent:Connect(function(player)
        DataStoreModule.continueStreak(player)
        loadedPlayers[player] = true

        local gui = player:WaitForChild("PlayerGui"):WaitForChild("ScreenGui")
        local loadingLabel = gui:WaitForChild("loadingLabel") :: TextLabel
        loadingLabel.Visible = false

        player:SetAttribute("death", DataStoreModule.getDeathEffect(player) or "default")
        player:SetAttribute("aura", DataStoreModule.getAura(player) or "default")
    end)

    DataStoreModule.DeathAnimationUpdated.Event:Connect(function(player: Player, value: string)
        print("Death animation set for", player.DisplayName, "to", value)
        player:SetAttribute("death", value)
    end)

    DataStoreModule.AuraUpdated.Event:Connect(function(player: Player, value: string)
        print("Aura set for", player.DisplayName, "to", value)
        player:SetAttribute("aura", value)
    end)

    Players.PlayerRemoving:Connect(function(player)
        loadedPlayers[player] = nil
    end)

    task.spawn(function()
        TimerModule.setTime(-1)
        local waited = 0

        task.wait(10)
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

        GameStateModule.setupMultipliers()
        UIModule.sendMultipliers()

        print("loaded")
        GameLoopModule.start()
    end)
end

return ArenaModule
