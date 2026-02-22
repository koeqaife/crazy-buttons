local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterGui = game:GetService("StarterGui")
local Scripts = Players.LocalPlayer.PlayerScripts.Client

local LOBBY_PLACE_ID = 115379867051786
local ARENA_PLACE_ID = 137127365503309

local function spawnCoolPlatforms()
    local Platform: Model = ReplicatedStorage:WaitForChild("Platform")
    local Workspace = game:GetService("Workspace")

    local Folder = Instance.new("Folder", Workspace)
    Folder.Name = "CoolPlatforms"

    local CENTER = Vector3.new(-93.886, -1023.5, -146.603)

    local PLATFORM_SIZE = 350
    local GAP = 350

    local GRID_RADIUS = 7
    local MIN_HEIGHT = -300
    local MAX_HEIGHT = 500

    local STEP = PLATFORM_SIZE + GAP

    for x = -GRID_RADIUS, GRID_RADIUS do
        for z = -GRID_RADIUS, GRID_RADIUS do
            if not (x == 0 and z == 0) then
                local heightOffset =
                    MIN_HEIGHT
                    + (MAX_HEIGHT - MIN_HEIGHT)
                        * ((x * 92821 + z * 1237) % 1000)
                        / 1000

                local pos = CENTER
                    + Vector3.new(
                        x * STEP,
                        heightOffset,
                        z * STEP
                    )

                local newPlatform = Platform:Clone()
                newPlatform.Parent = Folder
                newPlatform:MoveTo(pos)
            end
        end
    end
end

local function disableReset()
    local ok
    repeat
        ok = pcall(function()
            StarterGui:SetCore("ResetButtonCallback", false)
        end)
        if not ok then
            task.wait(0.1)
        end
    until ok
end

if game.PlaceId == LOBBY_PLACE_ID then
    local LobbyModule = require(Scripts.Lobby.LobbyModule)
    LobbyModule.init()
elseif game.PlaceId == ARENA_PLACE_ID then
    local ArenaModule = require(Scripts.Arena.ArenaModule)
    ArenaModule.init()
else
    print("Who am I....")
end

spawnCoolPlatforms()
disableReset()
