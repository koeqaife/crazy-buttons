--!strict
--!optimize 2
local ServerScriptService = game:GetService("ServerScriptService")

local ArenaModule = {}

function ArenaModule.init()
    local ButtonsModule = require(ServerScriptService.Server.Arena.ButtonsModule)
    local TimerModule = require(ServerScriptService.Server.Arena.TimerModule)
    ButtonsModule.init()
    TimerModule.start()
    print("Arena Module")
end

return ArenaModule
