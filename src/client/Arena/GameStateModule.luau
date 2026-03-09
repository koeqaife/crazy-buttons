local Lighting = game:GetService("Lighting")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TextChatService = game:GetService("TextChatService")
local KillToolModule = require(script.Parent.KillToolModule)
local Spring = require(ReplicatedStorage.Shared.spr)
local SyncDeadEvent: RemoteEvent = ReplicatedStorage:WaitForChild("SyncDeadEvent")

local GameState = {}

local localPlayerIsDead = false
local localPlayer = Players.LocalPlayer

GameState.localPlayerIsDead = localPlayerIsDead

local showDieEffect = require(localPlayer.PlayerScripts.Client.Shared.DieEffectModule)

local Blur: BlurEffect = Lighting:WaitForChild("Blur")
local ColorCorrection: ColorCorrectionEffect = Lighting:WaitForChild("ColorCorrection")
local Atmosphere: Atmosphere = Lighting:WaitForChild("Atmosphere")

Blur.Enabled = true
Blur.Size = 16
ColorCorrection.Enabled = true
ColorCorrection.Contrast = 0.3
ColorCorrection.Saturation = -1
Atmosphere.Density = 0.85

local blurSize = {
    forDead = 4,
    forAlive = 0
}
local colorCorrectionSettings = {
    forDead = {
        Contrast = 0.2,
        Saturation = 0.5,
        TintColor = Color3.fromRGB(140, 211, 255)
    },
    forAlive = {
        Contrast = 0.1,
        Saturation = 0.5,
        TintColor = Color3.new(1, 1, 1)
    }
}
local atmosphereDensity = {
    forAlive = 0.38,
    forDead = 0.60,
}


local function onSyncEvent(
    died: boolean,
    player: Player,
    dead: {Player},
    alive: {Player},
    reason: string?  -- nil | "byKillTool"
)
    local ktIgnore = KillToolModule.ignorePlayers
    for i = #ktIgnore, 1, -1 do
        table.remove(ktIgnore, i)
    end
    for _, p in ipairs(dead) do
        table.insert(ktIgnore, p)
    end

    if not player then
        return
    end
    local itsMe = player == localPlayer
    if itsMe then
        localPlayerIsDead = died
    end

    if itsMe then
        GameState.setEffects()
        for _, deadPlayer in dead do
            if deadPlayer == player then
                continue
            end

            local thisCharacter = deadPlayer.Character
            if not thisCharacter then
                continue
            end

            for _, obj in ipairs(thisCharacter:GetDescendants()) do
                if obj:IsA("BasePart") and obj.Name ~= "HumanoidRootPart" then
                    if died then
                        Spring.target(obj, 0.8, 0.25, { Transparency = 0.65 })
                    else
                        Spring.target(obj, 0.8, 0.25, { Transparency = 1 })
                    end
                end
            end
        end
    end

    -- reverse death effect when the player is resurrected (died == false)
    showDieEffect(player, not died, localPlayerIsDead, reason)
    if died then
        TextChatService.TextChannels.RBXGeneral:DisplaySystemMessage(
            "<font color=\"#eb4034\"><b>" .. player.DisplayName .. " has been eliminated.</b></font>"
        )
    end

    return
end

function GameState.localIsDead()
    return localPlayerIsDead
end

function GameState.connect()
    SyncDeadEvent.OnClientEvent:Connect(onSyncEvent)
end

function GameState.setEffects()
    local size = blurSize.forAlive
    local color = colorCorrectionSettings.forAlive
    local density = atmosphereDensity.forAlive
    if localPlayerIsDead then
        size = blurSize.forDead
        color = colorCorrectionSettings.forDead
        density = atmosphereDensity.forDead
    end
    Spring.target(Blur, 0.8, 0.25, { Size = size })
    Spring.target(ColorCorrection, 0.8, 0.25, color)
    Spring.target(Atmosphere, 0.8, 0.25, { Density = density })
end

return GameState