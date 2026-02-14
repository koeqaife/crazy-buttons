local Players = game:GetService("Players")
local Scripts = Players.LocalPlayer.PlayerScripts.Client

local LOBBY_PLACE_ID = 115379867051786
local ARENA_PLACE_ID = 137127365503309

if game.PlaceId == LOBBY_PLACE_ID then
    local LobbyModule = require(Scripts.Lobby.LobbyModule)
    LobbyModule.init()
elseif game.PlaceId == ARENA_PLACE_ID then
    local ArenaModule = require(Scripts.Arena.ArenaModule)
    ArenaModule.init()
else
    print("Who am I....")
end