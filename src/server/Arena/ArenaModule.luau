--!strict
--!optimize 2
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local ArenaModule = {}

local loadedPlayers = {}
local PlayerLoaded = Instance.new("RemoteEvent", ReplicatedStorage)
PlayerLoaded.Name = "PlayerLoaded"

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
    require(ServerScriptService.Server.Arena.TextModule)

    local ButtonsModule = require(ServerScriptService.Server.Arena.ButtonsModule)
    local TimerModule = require(ServerScriptService.Server.Arena.TimerModule)
    ButtonsModule.init()
    TimerModule.start()

    mainText.Text = "Waiting for players..."

    PlayerLoaded.OnServerEvent:Connect(function(player)
        loadedPlayers[player] = true
    end)

    Players.PlayerRemoving:Connect(function(player)
        loadedPlayers[player] = nil
    end)

    task.spawn(function()
        TimerModule.setTime(20)
        local waited = 0

        while task.wait(1) do
            waited += 1
            if waited >= 20 then
                break
            elseif allPlayersLoaded() and #Players:GetPlayers() > 0 then
                break
            end
        end

        TimerModule.setTime(5)
        task.wait(5)

        TimerModule.setTime(30)

        print("loaded")
        -- TODO: Start game after players loaded
    end)
end

return ArenaModule
