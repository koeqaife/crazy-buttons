local Lighting = game:GetService("Lighting")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Helpers = require(ReplicatedStorage.Shared.Helpers)
local Spring = require(ReplicatedStorage.Shared.spr)
local SyncDeadEvent: RemoteEvent = ReplicatedStorage:WaitForChild("SyncDeadEvent")

local GameState = {}

local localPlayerIsDead = false
local localPlayer = Players.LocalPlayer

local Blur: BlurEffect = Lighting:WaitForChild("Blur")
local ColorCorrection: ColorCorrectionEffect = Lighting:WaitForChild("ColorCorrection")
local Atmosphere: Atmosphere = Lighting:WaitForChild("Atmosphere")

local dieSound: Sound = ReplicatedStorage
    :WaitForChild("Sounds")
    :WaitForChild("DieSound")

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

    local character = player.Character
    if not character then
        return
    end

    local descendants = {}
    for _, obj in ipairs(character:GetDescendants()) do
        table.insert(descendants, obj)
    end

    Helpers.shuffleTable(descendants)

    local color
    if reason == "byKillTool" then
        color = Color3.fromRGB(255, 238, 0)
    else
        color = Color3.fromRGB(56, 138, 245)
    end

    local opacity
    if died then
        for _, obj in ipairs(descendants) do
            if obj:IsA("BasePart") then
                obj.CanQuery = false
            end
        end

        opacity = {
            highlightStart = 1,
            highlightTo = 0,
            highlightEnd = 1,
            objStart = 0,
            objStartForMe = 0,
            objTo = 0.999,
            objEnd = 1,
            objEndForMe = 0.65
        }
    else
        for _, obj in ipairs(descendants) do
            if obj:IsA("BasePart") then
                obj.CanQuery = true
            end
        end

        opacity = {
            highlightStart = 1,
            highlightTo = 0,
            highlightEnd = 1,
            objStart = 1,
            objStartForMe = 0.65,
            objTo = 0,
            objEnd = 0,
            objEndForMe = 0
        }
    end

    local sound = dieSound:Clone()
    sound.Parent = workspace
    sound:Destroy()

    for _, obj in ipairs(descendants) do
        if obj:IsA("BasePart") and obj.Name ~= "HumanoidRootPart" then
            task.wait(0.05)
            obj.Transparency = opacity.objStart
            if localPlayerIsDead or itsMe then
                obj.Transparency = opacity.objStartForMe
            end

            local highlight = Instance.new("Highlight")
            highlight.Parent = obj
            highlight.OutlineTransparency = 1
            highlight.FillTransparency = opacity.highlightStart
            highlight.FillColor = color
            highlight.DepthMode = Enum.HighlightDepthMode.Occluded

            Spring.target(highlight, 1.5, 5, { FillTransparency = opacity.highlightTo })
            Spring.target(obj, 1.5, 5, { Transparency = opacity.objTo })
            Spring.completed(highlight, function()
                if itsMe or localPlayerIsDead then
                    Spring.target(obj, 1.5, 5, { Transparency = opacity.objEndForMe })
                else
                end

                Spring.target(highlight, 1.5, 5, { FillTransparency = opacity.highlightEnd })
                Spring.completed(highlight, function()

                    highlight:Destroy()
                    if not itsMe and not localPlayerIsDead then
                        obj.Transparency = opacity.objEnd
                    end
                end)
            end)
        end
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