--!strict

local ServerScriptService = game:GetService("ServerScriptService")
local PhysicsService = game:GetService("PhysicsService")
local Players = game:GetService("Players")

local LOBBY_PLACE_ID = 115379867051786
local ARENA_PLACE_ID = 137127365503309

local function disablePlayerCollisions()
    PhysicsService:RegisterCollisionGroup("PlayersNoCollide")
    PhysicsService:CollisionGroupSetCollidable("PlayersNoCollide", "PlayersNoCollide", false)

    Players.PlayerAdded:Connect(function(player)
        player.CharacterAdded:Connect(function(character)
            for _, child in pairs(character:GetDescendants()) do
                if child:IsA("BasePart") then
                    child.CollisionGroup = "PlayersNoCollide"
                end
            end
        end)
    end)
end

if game.PlaceId == LOBBY_PLACE_ID then
    local LobbyModule = require(ServerScriptService.Server.Lobby.LobbyModule)
    LobbyModule.init()
    disablePlayerCollisions()
elseif game.PlaceId == ARENA_PLACE_ID then
    local ArenaModule = require(ServerScriptService.Server.Arena.ArenaModule)
    ArenaModule.init()
    disablePlayerCollisions()
else
    print("Who am I....")
end