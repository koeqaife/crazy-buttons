--!strict
--!optimize 2
local ContentProvider = game:GetService("ContentProvider")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Spring = require(ReplicatedStorage.Shared.spr)
local Helpers = require(ReplicatedStorage.Shared.Helpers)
local localPlayer = Players.LocalPlayer

return function(
    player: Player,
    reverse: boolean,
    localPlayerIsDead: boolean,
    reason: string?,
    endHook: () -> ()?
)
    if reverse then
        local defaultDeath = require(localPlayer.PlayerScripts.Client.Shared.Deaths.DefaultDeath)
        return defaultDeath(player, reverse, localPlayerIsDead, reason, endHook)
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

    local opacity
    if not reverse then
        for _, obj in ipairs(descendants) do
            if obj:IsA("BasePart") then
                obj.CanQuery = false
            end
        end

        opacity = {
            objStart = 0,
            objStartForMe = 0,
            objTo = 1,
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
            objStart = 1,
            objStartForMe = 0.65,
            objTo = 0,
            objEnd = 0,
            objEndForMe = 0
        }
    end

    local humanoid = character:WaitForChild("Humanoid") :: Humanoid
    local root = character:WaitForChild("HumanoidRootPart") :: Part

    local part = Instance.new("Part")
    part.Size = Vector3.new(4, 1, 4)
    part.Anchored = true
    part.CanCollide = false
    part.Parent = workspace
    part.Transparency = 1

    local bottomY = root.Position.Y - humanoid.HipHeight - (humanoid.RigType == Enum.HumanoidRigType.R6 and 0 or 0.5)

    part.Position = Vector3.new(root.Position.X, bottomY + part.Size.Y/2, root.Position.Z)

    local explosionChildren: {ParticleEmitter} = {}
    local explosionTextures: {any} = {}
    for _, child in (ReplicatedStorage.Effects.Explosion :: Folder):GetChildren() do
        local clone = child:Clone() :: ParticleEmitter
        table.insert(explosionChildren, clone)
        table.insert(explosionTextures, clone.Texture)
        clone.Parent = part
        clone.Enabled = false
    end

    ContentProvider:PreloadAsync(explosionTextures)

    local dieSound: Sound = ReplicatedStorage
        :WaitForChild("Sounds")
        :WaitForChild("ExplosionSound")
    ContentProvider:PreloadAsync({dieSound})

    local sound = dieSound:Clone()
    sound.Parent = workspace
    sound:Destroy()

    for _, child in explosionChildren do
        child.Enabled = true
    end

    task.delay(0.6, function()
        for _, emitter in explosionChildren do
            emitter.Enabled = false
        end
        task.delay(5, function()
            for _, emitter in explosionChildren do
                emitter:Destroy()
            end
            part:Destroy()
            if endHook then
                endHook()
            end
        end)
    end)

    for _, obj in ipairs(descendants) do
        if obj:IsA("BasePart") and obj.Name ~= "HumanoidRootPart" then
            obj.Transparency = opacity.objStart
            if localPlayerIsDead then
                obj.Transparency = opacity.objStartForMe
            end

            Spring.target(obj, 1.5, 5, { Transparency = opacity.objTo })
            Spring.completed(obj, function()
                if localPlayerIsDead then
                    Spring.target(obj, 1.5, 5, { Transparency = opacity.objEndForMe })
                end
            end)
        end
    end
end