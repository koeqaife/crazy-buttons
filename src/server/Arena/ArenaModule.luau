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
local GameLoopModule = require(Arena.GameLoopModule)
local ButtonsModule = require(Arena.ButtonsModule)
local TimerModule = require(Arena.TimerModule)

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

        local removingConnection: RBXScriptConnection
        local animationConnection = DataStoreModule.DeathAnimationUpdated.Event:Connect(function(p: Player, value: string)
            if player == p then
                print("Death animation set for", player, "to", value)
                player:SetAttribute("death", value)
            end
        end)

        removingConnection = Players.PlayerRemoving:Connect(function(playerRemoved: Player)
            if playerRemoved == player then
                removingConnection:Disconnect()
                animationConnection:Disconnect()
            end
        end)
    end)

    Players.PlayerRemoving:Connect(function(player)
        loadedPlayers[player] = nil
    end)

    task.spawn(function()
        TimerModule.setTime(120)
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
        mainText.Text = "..."

        TimerModule.setTime(30)

        print("loaded")
        GameLoopModule.start()
    end)
end

return ArenaModule
