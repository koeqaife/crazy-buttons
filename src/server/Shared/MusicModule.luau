--!strict
--!optimize 2

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SoundService = game:GetService("SoundService")
local Promise = require(ReplicatedStorage.Shared.Promise)

local MusicModule = {}

local SoundtracksFolder = ReplicatedStorage:WaitForChild("Soundtracks") :: Folder
local SoundGroup = SoundService:WaitForChild("Music") :: SoundGroup

local soundtracks: {Sound} = {}
local lastTrackIndex = 0
local currentTrack: Sound? = nil
local lastPromise: Promise.TypedPromise<nil>? = nil

local function getRandom()
    local index: number = nil

    while index == nil or index == lastTrackIndex do
        index = math.random(1, #soundtracks)
    end

    return index
end

function MusicModule.fadeInGroup()
    if lastPromise ~= nil then
        lastPromise:cancel()
    end

    local promise = Promise.new(function(resolve, _, onCancel)
        local initialVolume = SoundGroup.Volume
        local targetVolume = 0.5
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

function MusicModule.fadeOutGroup()
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

local function loop()
    while true do
        local index = getRandom()
        lastTrackIndex = index

        currentTrack = soundtracks[index]
        if currentTrack == nil then
            task.wait(0.1)
            continue
        end

        local initialVolume = currentTrack.Volume
        currentTrack.Volume = 0
        fadeInSound(currentTrack, 0, initialVolume):await()

        currentTrack.SoundGroup = SoundGroup
        currentTrack:Play()
        task.wait(currentTrack.TimeLength - 2)

        fadeOutSound(currentTrack, initialVolume, 0):await()
        currentTrack:Stop()

        task.wait(1)
    end
end

function MusicModule.init()
    for _, child in ipairs(SoundtracksFolder:GetChildren()) do
        if child:IsA("Sound") then
            table.insert(soundtracks, child)
        end
    end

    task.spawn(loop)
end

return MusicModule