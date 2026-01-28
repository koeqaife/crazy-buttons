local Arena = game:GetService("ServerScriptService").Server.Arena
local Players = game:GetService("Players")
local GameState = require(Arena.GameStateModule)
local GameLoopModule = {}

local StartEvent = require(Arena.Events.StartEvent)

function GameLoopModule.start()
    for _, player in ipairs(Players:GetPlayers()) do
        table.insert(GameState.alivePlayers, player)
    end
    task.spawn(function()
        StartEvent.onEvent():await()
    end)
end

return GameLoopModule