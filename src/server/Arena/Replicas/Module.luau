--!strict
--!optimize 2
local ServerScriptService = game:GetService("ServerScriptService")

-- Lazy require
return {
    default = function() return require(ServerScriptService.Server.Arena.Replicas.Default.Module) end,
    evil = function() return require(ServerScriptService.Server.Arena.Replicas.Evil.Module) end,
    show = function() return require(ServerScriptService.Server.Arena.Replicas.Show.Module) end,
    slang = function() return require(ServerScriptService.Server.Arena.Replicas.Slang.Module) end
}