--!strict
--!optimize 2

-- All effects should not kill the person!!
-- Only change its opacity to 0 (0.65 if local player is dead or it is local player)

local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer

local DeathsFolder = localPlayer.PlayerScripts.Client.Shared.Deaths

local deaths = {
    default = require(DeathsFolder.DefaultDeath),
    explosion = require(DeathsFolder.ExplosionDeath),
    white = require(DeathsFolder.WhiteAuraDeath),
    purple = require(DeathsFolder.PurpleAuraDeath),
    green = require(DeathsFolder.GreenAuraDeath),
    incognito = require(DeathsFolder.IncognitoDeath),
    magic = require(DeathsFolder.MagicDeath),
    hearts = require(DeathsFolder.HeartsDeath),
}

return function(player: Player, reverse: boolean, localPlayerIsDead: boolean, reason: string?, force: string?, endHook: () -> ()?)
    local deathEffect = force or player:GetAttribute("death") :: string? or "default"

    (deaths[deathEffect] or deaths["default"])(player, reverse, localPlayerIsDead, reason, endHook)
end