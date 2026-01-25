local StarterPlayerScripts = game:GetService("StarterPlayer").StarterPlayerScripts

local LOBBY_PLACE_ID = 115379867051786
local ARENA_PLACE_ID = 137127365503309

if game.PlaceId == LOBBY_PLACE_ID then
    local LobbyModule = require(StarterPlayerScripts.Client.Lobby.LobbyModule)
    LobbyModule.init()
elseif game.PlaceId == ARENA_PLACE_ID then
    local ArenaModule = require(StarterPlayerScripts.Client.Arena.ArenaModule)
    ArenaModule.init()
else
    print("Who am I....")
end