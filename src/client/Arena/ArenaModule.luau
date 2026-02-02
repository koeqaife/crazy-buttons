--!strict
--!optimize 2

local ArenaModule = {}
local Arena = game:GetService("StarterPlayer").StarterPlayerScripts.Client.Arena
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local PlayerLoaded = ReplicatedStorage:WaitForChild("PlayerLoaded")

local ButtonsModule = require(Arena.ButtonsModule)
local TextModule = require(Arena.TextModule)
local PromptModule = require(Arena.CustomPromptModule)
local GameStateModule = require(Arena.GameStateModule)

function ArenaModule.init()
    TextModule.connect()
    ButtonsModule.connect()
    GameStateModule.connect()
    PromptModule.onLoad()

    game:GetService("ContentProvider"):PreloadAsync({player.Character})

    GameStateModule.setEffects()
    PlayerLoaded:FireServer()
end

return ArenaModule
