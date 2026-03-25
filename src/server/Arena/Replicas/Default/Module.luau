--!strict
--!optimize 2
local ServerScriptService = game:GetService("ServerScriptService")

-- Lazy require
return {
    english = function() return require(ServerScriptService.Server.Arena.Replicas.Default.English) end,
    ukrainian = function() return require(ServerScriptService.Server.Arena.Replicas.Default.Ukrainian) end,
    spanish = function() return require(ServerScriptService.Server.Arena.Replicas.Default.Spanish) end,
    russian = function() return require(ServerScriptService.Server.Arena.Replicas.Default.Russian) end
}