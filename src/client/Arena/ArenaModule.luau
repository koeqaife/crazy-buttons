--!strict
--!optimize 2

local ArenaModule = {}
local Players = game:GetService("Players")
local Arena = Players.LocalPlayer.PlayerScripts.Client.Arena
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local PlayerLoaded = ReplicatedStorage:WaitForChild("PlayerLoaded")

local ButtonsModule = require(Arena.ButtonsModule)
local TextModule = require(Arena.TextModule)
local PromptModule = require(Arena.CustomPromptModule)
local GameStateModule = require(Arena.GameStateModule)
local KillToolModule = require(Arena.KillToolModule)
local AmbienceModule = require(Arena.AmbienceModule)

function ArenaModule.init()
    TextModule.connect()
    ButtonsModule.connect()
    GameStateModule.connect()
    KillToolModule.connect()
    AmbienceModule.init()
    PromptModule.onLoad()

    game:GetService("ContentProvider"):PreloadAsync({player.Character})

    GameStateModule.setEffects()
    PlayerLoaded:FireServer()
end

return ArenaModule
