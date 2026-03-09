--!strict
--!optimize 2
local ContentProvider = game:GetService("ContentProvider")

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SoundService = game:GetService("SoundService")
local Promise = require(ReplicatedStorage.Shared.Promise)

local MusicModule = {}

local SoundGroup = SoundService:WaitForChild("Music") :: SoundGroup
local MusicEffectEvent: RemoteEvent = ReplicatedStorage:WaitForChild("MusicEffectEvent")
local volumeMultiplier = 1

local lastPromise: Promise.TypedPromise<nil>? = nil

local clamp = math.clamp

local function clamp01(x)
	return clamp(x, 0, 1)
end

local function fadeInGroup()
    if lastPromise ~= nil then
        lastPromise:cancel()
    end

    local promise = Promise.new(function(resolve, _, onCancel)
        local initialVolume = SoundGroup.Volume
        local targetVolume = clamp01(1 * volumeMultiplier)
        local duration = 2
        local startTime = tick()

        local conn
        conn = game:GetService("RunService").Heartbeat:Connect(function()
            local elapsed = tick() - startTime
            if elapsed >= duration then
                SoundGroup.Volume = targetVolume
                conn:Disconnect()
                resolve(nil)
            else
                SoundGroup.Volume = initialVolume + (targetVolume - initialVolume) * (elapsed / duration)
            end
        end)

        onCancel(function()
            conn:Disconnect()
            SoundGroup.Volume = targetVolume
        end)
    end)

    lastPromise = promise
    return promise
end

local function fadeOutGroup()
    if lastPromise ~= nil then
        lastPromise:cancel()
    end

    local promise = Promise.new(function(resolve, _, onCancel)
        local initialVolume = SoundGroup.Volume
        local targetVolume = 0
        local duration = 2
        local startTime = tick()

        local conn
        conn = game:GetService("RunService").Heartbeat:Connect(function()
            local elapsed = tick() - startTime
            if elapsed >= duration then
                SoundGroup.Volume = targetVolume
                conn:Disconnect()
                resolve(nil)
            else
                SoundGroup.Volume = initialVolume + (targetVolume - initialVolume) * (elapsed / duration)
            end
        end)

        onCancel(function()
            conn:Disconnect()
            SoundGroup.Volume = targetVolume
        end)
    end)

    lastPromise = promise
    return promise
end

local function fadeOutSound(sound: Sound, from: number, to: number)
    local promise = Promise.new(function(resolve, _, onCancel)
        local initialVolume = from
        local targetVolume = to
        local duration = 2
        local startTime = tick()

        local conn
        conn = game:GetService("RunService").Heartbeat:Connect(function()
            local elapsed = tick() - startTime
            if elapsed >= duration then
                sound.Volume = targetVolume
                conn:Disconnect()
                resolve(nil)
            else
                sound.Volume = initialVolume + (targetVolume - initialVolume) * (elapsed / duration)
            end
        end)

        onCancel(function()
            conn:Disconnect()
            sound.Volume = targetVolume
        end)
    end)

    return promise
end

local function fadeInSound(sound: Sound, from: number, to: number)
    ContentProvider:PreloadAsync({sound})
    sound:Play()
    local promise = Promise.new(function(resolve, _, onCancel)
        local initialVolume = from
        local targetVolume = to
        local duration = 2
        local startTime = tick()

        local conn
        conn = game:GetService("RunService").Heartbeat:Connect(function()
            local elapsed = tick() - startTime
            if elapsed >= duration then
                sound.Volume = targetVolume
                conn:Disconnect()
                resolve(nil)
            else
                sound.Volume = initialVolume + (targetVolume - initialVolume) * (elapsed / duration)
            end
        end)

        onCancel(function()
            conn:Disconnect()
            sound.Volume = targetVolume
        end)
    end)

    return promise
end

function MusicModule.setMultiplier(volume: number)
    volumeMultiplier = volume
    SoundGroup.Volume = volume
end

function MusicModule.init()
    local funcs = {
        fadeInGroup = fadeInGroup,
        fadeOutGroup = fadeOutGroup,
        fadeInSound = fadeInSound,
        fadeOutSound = fadeOutSound
    }
    MusicEffectEvent.OnClientEvent:Connect(function(name: string, ...)
        funcs[name](...)
    end)
end

return MusicModule