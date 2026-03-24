--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local Helpers = require(ReplicatedStorage.Shared.Helpers)
local IndicesModule = require(ReplicatedStorage.Shared.IndicesType)
local SideEffects = game:GetService("ServerScriptService").Server.Arena.Effects
local Format = require(ServerScriptService.Server.Arena.Replicas.Format)

type Indices = IndicesModule.Indices

export type SideEffect = {
    id: string,
    name: string,
    description: string,
    universal: boolean,
    priority: number,
    rewardsMultiplier: number?,
    timeBonus: ((original: number) -> number)?,
    textTransform: ((text: string) -> string)?,
    buttonsEffect: ((indices: Indices) -> Indices)?,
    faceEffect: ((original: Format.Face?) -> Format.Face?)?,
    onButtonClick: ((player: Player, idx: number) -> boolean?)?,
    beforeRound: (() -> ())?,
    afterRound: (() -> ())?,
    startHook: (() -> ())?,
    endHook: (() -> ())?,
}

type EffectsMap = { [string]: SideEffect }

local SideEffectsModule = {}

local allEffects: {SideEffect} = {
    require(SideEffects.Special),
    require(SideEffects.Alien),
    require(SideEffects.RandomButtons),
    require(SideEffects.RandomLives),
    require(SideEffects.AccidentKill),
    require(SideEffects.MixedColors),
    require(SideEffects.NoChat),
}
local effectsById: EffectsMap = {}
local activatedSet: { [string]: boolean } = {}
local supportedSet: { [string]: boolean } = {}
local activeEffects: {SideEffect} = {}

for _, effect in ipairs(allEffects) do
    effectsById[effect.id] = effect
end

local function updateActiveEffects()
    local result = {}

    for id, effect in pairs(effectsById) do
        if not activatedSet[id] then
            continue
        end

        if effect.universal or supportedSet[id] then
            table.insert(result, effect)
        end
    end

    table.sort(result, function(a, b)
        return a.priority < b.priority
    end)

    activeEffects = result
end

function SideEffectsModule.activateSideEffect(id: string)
    if effectsById[id] == nil then
        return warn("Effect with id '" .. id .. "' wasn't found")
    end
    print("Activated effect:", id)
    activatedSet[id] = true
    local startHook = effectsById[id].startHook
    if startHook ~= nil then
        startHook()
    end
    updateActiveEffects()
end

function SideEffectsModule.activateManySideEffects(ids: {string})
    for _, id in ipairs(ids) do
        activatedSet[id] = true
        local startHook = effectsById[id].startHook
        if startHook ~= nil then
            startHook()
        end
    end

    updateActiveEffects()
end

function SideEffectsModule.getRandom(amount: number): {SideEffect}
    local copy = table.clone(allEffects)
    Helpers.shuffleTable(copy)

    local effects: {SideEffect} = {}
    local cursor = 0

    for i = 1, 99, 1 do
        cursor += 1
        local effect = copy[cursor]
        if not effect then
            break
        end
        if not activatedSet[effect.id] then
            table.insert(effects, effect)
        end
        if #effects == amount then
            break
        end
    end

    return effects
end

function SideEffectsModule.setSupportedEffects(effects: {string})
    supportedSet = {}

    for _, id in ipairs(effects) do
        supportedSet[id] = true
    end
    updateActiveEffects()
end

function SideEffectsModule.applyTimeBonus(original: number): number
    local value = original

    for _, effect in ipairs(activeEffects) do
        if effect.timeBonus then
            value = effect.timeBonus(value)
        end
    end

    return value
end

function SideEffectsModule.applyTextTransform(text: string): string
    local result = text

    for _, effect in ipairs(activeEffects) do
        if effect.textTransform then
            result = effect.textTransform(result)
        end
    end

    return result
end

function SideEffectsModule.applyButtonsEffect(indices: Indices): Indices
    local result = indices

    for _, effect in ipairs(activeEffects) do
        if effect.buttonsEffect then
            result = effect.buttonsEffect(result)
        end
    end

    return result
end

function SideEffectsModule.applyFaceEffect(face: Format.Face?): Format.Face?
    local result = face

    for _, effect in ipairs(activeEffects) do
        if effect.faceEffect then
            result = effect.faceEffect(result :: Format.Face?)
        end
    end

    return result :: Format.Face?
end

function SideEffectsModule.applyRewardsMultiplier(original: number): number
    local result = original

    for _, effect in ipairs(activeEffects) do
        if effect.rewardsMultiplier then
            result *= effect.rewardsMultiplier
        end
    end

    return result
end

function SideEffectsModule.onButtonClick(player: Player, idx: number)
    for _, effect in ipairs(activeEffects) do
        if effect.onButtonClick then
            local interrupt = effect.onButtonClick(player, idx)
            if interrupt == true then
                break
            end
        end
    end
end

function SideEffectsModule.onBeforeRound()
    for _, effect in ipairs(activeEffects) do
        if effect.beforeRound then
            print("Running beforeRound for", effect.id)
            effect.beforeRound()
        end
    end
end

function SideEffectsModule.onAfterRound()
    for _, effect in ipairs(activeEffects) do
        if effect.afterRound then
            print("Running afterRound for", effect.id)
            effect.afterRound()
        end
    end
end

return SideEffectsModule