--!strict
--!optimize 2
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ARENA_PLACE_ID = 137127365503309

local names
if game.PlaceId == ARENA_PLACE_ID then
    names = {
        "AddCash",
        "ProcessPurchase_Client",
        "BanPlayer",
        "KickPlayer",
        "SetAdminLevel",
        "ServerCommand",
        "UnlockAllItems",
        "DisableAntiCheat",
        "SetSecureMode",
        "ForceRevivePlayer_Admin",
        "ForceKillPlayer_Admin",
        "AdminMenu",
        "StartRound",
        "GivePlayerEffect"
    }
else
    names = {
        "AddCash",
        "ProcessPurchase_Client",
        "BanPlayer",
        "KickPlayer",
        "SetAdminLevel",
        "ServerCommand",
        "UnlockAllItems",
        "DisableAntiCheat",
        "SetSecureMode",
        "AdminMenu",
        "GivePlayerEffect"
    }
end

for i, name in ipairs(names) do
    local Event = Instance.new("RemoteEvent", ReplicatedStorage)
    Event.Name = name
    Event.OnServerEvent:Connect(function(player)
        local banConfig = {
            UserIds = {player.UserId}, 
            Duration = -1,
            DisplayReason = "Exploiting/Cheating is not allowed.",
            PrivateReason = "Caught by HoneyPot: " .. name,

            ExcludeAltAccounts = false,

            ApplyToUniverse = true
        }

        local success, err = pcall(function()
            game:GetService("Players"):BanAsync(banConfig)
        end)

        if not success then
            warn("Couldn't ban player", err)
        end
    end)
end
