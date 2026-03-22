--!strict
--!optimize 2
local ServerScriptService = game:GetService("ServerScriptService")
local PlayersModule = require(ServerScriptService.Server.Arena.PlayersModule)
local random = math.random

local Effect = {
    id = "accident_kill",
    name = "Accident Die",
    description = "Any button can kill you with chance 4%",
    priority = 5,
    universal = true,
    onButtonClick = function(player: Player, idx: number)
        if random(1, 100) <= 4 then
            PlayersModule.kill(player)
        end
    end,
}

return Effect :: any