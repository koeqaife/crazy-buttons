--!strict
--!optimize 2
local ServerScriptService = game:GetService("ServerScriptService")

-- Lazy require
return {
    english = function() return require(ServerScriptService.Server.Arena.Replicas.Default.English) end
}