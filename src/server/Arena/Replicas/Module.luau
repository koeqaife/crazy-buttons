--!strict
--!optimize 2
local ServerScriptService = game:GetService("ServerScriptService")

-- Lazy require
return {
    default = function() return require(ServerScriptService.Server.Arena.Replicas.Default.Module) end,
    bag = { "default" }
}