--!strict
--!optimize 2
local ServerScriptService = game:GetService("ServerScriptService")

local ArenaModule = {}

function ArenaModule.init()
    local ButtonsModule = require(ServerScriptService.Server.Arena.ButtonsModule)
    ButtonsModule.init()
    print("Arena Module")
end

return ArenaModule
