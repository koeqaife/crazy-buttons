--!strict
--!optimize 2
local ServerScriptService = game:GetService("ServerScriptService")

local Effect = {
    id = "random_lives",
    name = "Random Lives",
    description = "Your lives amount will be randomized",
    priority = 10,
    universal = false,
    startHook = function()
        local PlayersModule = require(ServerScriptService.Server.Arena.PlayersModule)
        PlayersModule.setLivesPerPlayer(math.random(1, 5))
    end
}

return Effect :: any