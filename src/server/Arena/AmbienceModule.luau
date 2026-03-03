--!optimize 2
--!strict

local ServerScriptService = game:GetService("ServerScriptService")
local TweenService = game:GetService("TweenService")
local MusicModule = require(ServerScriptService.Server.Shared.MusicModule)

local WorkspaceSounds = workspace:WaitForChild("Sounds") :: Folder

local EerieHorrorRising = WorkspaceSounds:WaitForChild("EerieHorrorRising") :: Sound

local AmbienceModule = {}
local runningSounds: {Sound} = {}

local function fadeIn(sound: Sound, duration: number, target: number): Tween
    sound.Volume = 0
    sound:Play()

    local tween = TweenService:Create(
        sound,
        TweenInfo.new(duration, Enum.EasingStyle.Linear),
        { Volume = target }
    )

    tween:Play()
    local connections: {RBXScriptConnection} = {}
    connections[#connections + 1] = sound.Ended:Once(function()
        tween:Cancel()
        for _, connection in ipairs(connections) do
            connection:Disconnect()
        end
    end)

    connections[#connections + 1] = sound.Stopped:Once(function()
        tween:Cancel()
        for _, connection in ipairs(connections) do
            connection:Disconnect()
        end
    end)

    tween.Completed:Once(function()
        for _, connection in ipairs(connections) do
            connection:Disconnect()
        end
    end)

    return tween
end

function AmbienceModule.playEerieHorrorRising()
    MusicModule.fadeOutGroup()
    if not table.find(runningSounds, EerieHorrorRising) then
        fadeIn(EerieHorrorRising, 20, 1)
        table.insert(runningSounds, EerieHorrorRising)
    end
end

function AmbienceModule.stopEerieHorrorRising()
    MusicModule.fadeInGroup()
    if table.find(runningSounds, EerieHorrorRising) then
        EerieHorrorRising:Stop()
        table.remove(runningSounds, table.find(runningSounds, EerieHorrorRising))
    end
end

function AmbienceModule.stopAll()
    local snapshot = table.clone(runningSounds)
    for _, sound in ipairs(snapshot) do
        sound:Stop()
    end
    table.clear(runningSounds)
    MusicModule.fadeInGroup()
end

return AmbienceModule