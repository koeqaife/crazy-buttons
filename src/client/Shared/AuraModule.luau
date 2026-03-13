--!strict
--!optimize 2
local ContentProvider = game:GetService("ContentProvider")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local AuraModule = {}

local auras = {
    bubblesAura = {
        folder = "Bubbles",
        applyTo = "Body"
    },
    incognitoFace = {
        folder = "IncognitoFace",
        applyTo = "Head"
    },
    purpleAura = {
        folder = "PurpleAura",
        applyTo = "Body"
    },
    greenAura = {
        folder = "GreenAura",
        applyTo = "Body"
    },
    magicAura = {
        folder = "Magic",
        applyTo = "Body"
    },
}

local appliedAuras: {[Player]: {ParticleEmitter}} = {}
local enabledAuras: {[Player]: boolean} = {}

function AuraModule.loadAura(player: Player, name: string?)
    if appliedAuras[player] == nil then
        appliedAuras[player] = {}
    else
        for i, aura in appliedAuras[player] do
            aura:Destroy()
        end
        table.clear(appliedAuras[player])
    end

    local character = player.Character
    print(character)

    if character and name ~= "default" and name and auras[name] ~= nil then
        if enabledAuras[player] == nil then
            enabledAuras[player] = true
        end
        local aura = auras[name]

        local emitters: {ParticleEmitter} = {}
        local textures: {any} = {}
        for _, child in (ReplicatedStorage.Auras[aura.folder] :: Folder):GetChildren() do
            table.insert(emitters, child:Clone() :: ParticleEmitter)
            table.insert(textures, (child:: ParticleEmitter).Texture)
        end
        ContentProvider:PreloadAsync(textures)

        local applyTo = aura.applyTo
        for i, emitter in ipairs(emitters) do
            if applyTo == "Body" then
                emitter.Parent = character:WaitForChild("HumanoidRootPart")
            elseif applyTo == "Head" then
                emitter.Parent = character:WaitForChild("Head")
            end
            emitter.Enabled = enabledAuras[player]
            table.insert(appliedAuras[player], emitter)
        end
    end
end

function AuraModule.enableAura(player: Player)
    enabledAuras[player] = true
    if appliedAuras[player] ~= nil then
        for i, aura in appliedAuras[player] do
            aura.Enabled = true
        end
    end
end

function AuraModule.disableAura(player: Player)
    enabledAuras[player] = false
    if appliedAuras[player] ~= nil then
        for i, aura in appliedAuras[player] do
            aura.Enabled = false
        end
    end
end

local function connectToPlayer(player: Player)
    if player:GetAttribute("aura") ~= nil then
        AuraModule.loadAura(player, player:GetAttribute("aura") :: string)
    end
    player:GetAttributeChangedSignal("aura"):Connect(function()
        AuraModule.loadAura(player, player:GetAttribute("aura") :: string)
    end)
end

function AuraModule.connect()
    for _, player in Players:GetPlayers() do
        connectToPlayer(player)
    end

    Players.PlayerAdded:Connect(function(player)
        connectToPlayer(player)
    end)
end

return AuraModule