--!strict
--!optimize 2
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
    for _, child in (ReplicatedStorage.Effects.WhiteAura :: Folder):GetChildren() do
        table.insert(emitters, child :: ParticleEmitter)
    end

    local childrenPerPart: {[BasePart]: {ParticleEmitter}} = {}

    defaultDeath(
        player, reverse, localPlayerIsDead, reason,
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
            task.delay(0.85, function()
                for _, emitter in childrenPerPart[part] do
                    emitter:Destroy()
                end
            end)
        end,
        endHook
    )
end