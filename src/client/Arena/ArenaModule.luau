--!strict
--!optimize 2

local ArenaModule = {}
local StarterPlayerScripts = game:GetService("StarterPlayer").StarterPlayerScripts
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local PlayerLoaded = ReplicatedStorage:WaitForChild("PlayerLoaded")

local ButtonsModule = require(StarterPlayerScripts.Client.Arena.ButtonsModule)
local TextModule = require(StarterPlayerScripts.Client.Arena.TextModule)
local PromptModule = require(StarterPlayerScripts.Client.Arena.CustomPromptModule)

function ArenaModule.init()
    TextModule.connect()
    ButtonsModule.connect()
    PromptModule.onLoad()

    game:GetService("ContentProvider"):PreloadAsync({player.Character})

    PlayerLoaded:FireServer()
end

return ArenaModule
