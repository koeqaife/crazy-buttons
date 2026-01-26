--!strict
--!optimize 2

local ArenaModule = {}
local StarterPlayerScripts = game:GetService("StarterPlayer").StarterPlayerScripts

local ButtonsModule = require(StarterPlayerScripts.Client.Arena.ButtonsModule)

function ArenaModule.init()
    ButtonsModule.setButtons({
        { idx = 1, text = "Click me" },
        { idx = 2, text = "DO NOT CLICK" },
        { idx = 4, text = "Ye", disabled = true },
    })
end

return ArenaModule
