--!strict
--!optimize 2

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SoundService = game:GetService("SoundService")

local MusicModule = {}

local SoundtracksFolder = ReplicatedStorage:WaitForChild("Soundtracks") :: Folder
local SoundGroup = SoundService:WaitForChild("Music") :: SoundGroup

local soundtracks: {Sound} = {}
local lastTrackIndex = 0
local currentTrack: Sound? = nil

local MusicEffectEvent = Instance.new("RemoteEvent", ReplicatedStorage)
MusicEffectEvent.Name = "MusicEffectEvent"

local function getRandom()
    local index: number = nil

    while index == nil or index == lastTrackIndex do
        index = math.random(1, #soundtracks)
    end

    return index
end

function MusicModule.fadeInGroup()
    MusicEffectEvent:FireAllClients("fadeInGroup")
end

function MusicModule.fadeOutGroup()
    MusicEffectEvent:FireAllClients("fadeOutGroup")
end

local function fadeOutSound(sound: Sound, from: number, to: number)
    MusicEffectEvent:FireAllClients("fadeOutSound", sound, from, to)
end

local function fadeInSound(sound: Sound, from: number, to: number)
    MusicEffectEvent:FireAllClients("fadeInSound", sound, from, to)
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
        currentTrack.SoundGroup = SoundGroup
        currentTrack.Volume = 0
        currentTrack:Play()

        fadeInSound(currentTrack, 0, initialVolume)

        task.wait(currentTrack.TimeLength - 2)

        fadeOutSound(currentTrack, initialVolume, 0)
        task.wait(2)
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
    SoundGroup.Volume = 0

    task.spawn(loop)
end

return MusicModule