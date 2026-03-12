--!strict
--!optimize 2
local ContentProvider = game:GetService("ContentProvider")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local localPlayer = Players.LocalPlayer

local defaultDeath = require(localPlayer.PlayerScripts.Client.Shared.Deaths.DefaultDeath)

return function(
    player: Player,
    reverse: boolean,
    localPlayerIsDead: boolean,
    reason: string?,
    endHook: () -> ()?
)
    local emitters: {ParticleEmitter} = {}
    local textures: {any} = {}
    for _, child in (ReplicatedStorage.Effects.Magic :: Folder):GetChildren() do
        table.insert(emitters, child :: ParticleEmitter)
        table.insert(textures, (child:: ParticleEmitter).Texture)
    end
    ContentProvider:PreloadAsync(textures)

    local childrenPerPart: {[BasePart]: {ParticleEmitter}} = {}

    defaultDeath(
        player, reverse, localPlayerIsDead, reason,
        function()
            task.delay(3, function()
                if endHook then
                    endHook()
                end
            end)
        end,
        Color3.new(1, 1, 1),
        function(part)
            childrenPerPart[part] = {}
            for _, emitter in emitters do
                local clone = emitter:Clone()
                clone.Parent = part
                clone.Enabled = true
                table.insert(childrenPerPart[part], clone)
            end
        end,
        function(part)
            for _, emitter in childrenPerPart[part] do
                emitter.Enabled = false
            end
        end,
        function(part)
            task.delay(3, function()
                for _, emitter in childrenPerPart[part] do
                    emitter:Destroy()
                end
            end)
        end
    )
end