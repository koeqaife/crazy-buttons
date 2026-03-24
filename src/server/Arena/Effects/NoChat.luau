--!strict
--!optimize 2
local ServerScriptService = game:GetService("ServerScriptService")
local PlayersModule = require(ServerScriptService.Server.Arena.PlayersModule)

local Effect = {
    id = "no_chat",
    name = "No Chat",
    description = "Chat will be disabled during rounds",
    universal = true,
    priority = 25,
    beforeRound = function()
        PlayersModule.disableChat(true)
    end,
    afterRound = function()
        PlayersModule.disableChat(false)
    end,
    timeBonus = function(original: number): number
        -- Small time bonus
        return original + 1.5
    end
}

return Effect :: any