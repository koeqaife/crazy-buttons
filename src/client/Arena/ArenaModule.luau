--!strict
--!optimize 2

local ArenaModule = {}
local Players = game:GetService("Players")
local Arena = Players.LocalPlayer.PlayerScripts.Client.Arena
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SoundService = game:GetService("SoundService")
local StarterPlayer = game:GetService("StarterPlayer")

local player = Players.LocalPlayer
local PlayerLoaded = ReplicatedStorage:WaitForChild("PlayerLoaded")

local ViewportGui = player:WaitForChild("PlayerGui"):WaitForChild("ViewportGui") :: ScreenGui
local ViewportFrame = ViewportGui:WaitForChild("ViewportFrame") :: ViewportFrame

local SyncVolumes = ReplicatedStorage:WaitForChild("SyncVolumesEvent") :: RemoteEvent

local AuraModule = require(StarterPlayer.StarterPlayerScripts.Client.Shared.AuraModule)
local CustomPromptModule = require(Players.LocalPlayer.PlayerScripts.Client.Shared.CustomPromptModule)
local MusicModule = require(Players.LocalPlayer.PlayerScripts.Client.Shared.MusicModule)
local ButtonsModule = require(Arena.ButtonsModule)
local TextModule = require(Arena.TextModule)
local GameStateModule = require(Arena.GameStateModule)
local KillToolModule = require(Arena.KillToolModule)
local AmbienceModule = require(Arena.AmbienceModule)
local UIModule = require(Arena.UIModule)

function ArenaModule.init()
    TextModule.connect()
    ButtonsModule.connect()
    GameStateModule.connect()
    KillToolModule.connect()
    AmbienceModule.init()
    CustomPromptModule.onLoad()
    MusicModule.init()
    UIModule.connect()
    AuraModule.connect()

    ViewportFrame.CurrentCamera = workspace.CurrentCamera

    game:GetService("ContentProvider"):PreloadAsync({player.Character})

    GameStateModule.setEffects()
    PlayerLoaded:FireServer()

    SyncVolumes.OnClientEvent:Connect(function(volume: { music: number, ambient: number })
        MusicModule.setMultiplier(volume.music)

        local AmbientGroup = SoundService:WaitForChild("Ambient") :: SoundGroup
        local AmbientOtherGroup = SoundService:WaitForChild("AmbientOther") :: SoundGroup

        AmbientGroup.Volume = volume.ambient
        AmbientOtherGroup.Volume = volume.ambient
    end)
end

return ArenaModule
