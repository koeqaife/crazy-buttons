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
    reason: string?
)
    local character = player.Character
    if not character then
        return
    end

    local root = character:WaitForChild("HumanoidRootPart") :: Part

    local attachment: Attachment = nil

    local emitters: {ParticleEmitter} = {}

    for _, child in (ReplicatedStorage.Effects.PurpleAura :: Folder):GetChildren() do
        if child:IsA("Attachment") then
            attachment = child
        elseif child:IsA("ParticleEmitter") then
            local clone = child:Clone()
            clone.Parent = root
            clone.Enabled = true
            table.insert(emitters, clone)
        end
    end

    local childrenPerPart: {[BasePart]: {Instance}} = {}

    defaultDeath(
        player, reverse, localPlayerIsDead, reason,
        Color3.fromRGB(85, 0, 255),
        function(part)
            childrenPerPart[part] = {}
            local clone = attachment:Clone()
            clone.Parent = part
            table.insert(childrenPerPart[part], clone)

            for _, emitter in clone:GetChildren() do
                if emitter:IsA("ParticleEmitter") then
                    emitter.Enabled = true
                    table.insert(childrenPerPart[part], emitter)
                end
            end
        end,
        function(part)
            print(childrenPerPart[part], emitters)
            for _, emitter in childrenPerPart[part] do
                if emitter:IsA("ParticleEmitter") then
                    print("Disabling")
                    emitter.Enabled = false
                    print(emitter.Enabled)
                end
            end
            for _, emitter in emitters do
                emitter.Enabled = false
            end
        end,
        function(part)
            task.delay(3, function()
                for _, emitter in childrenPerPart[part] do
                    emitter:Destroy()
                end
                for _, emitter in emitters do
                    emitter:Destroy()
                end
            end)
        end
    )
end