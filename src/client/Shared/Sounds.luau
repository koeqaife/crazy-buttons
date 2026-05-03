--!strict
--!optimize 2

local Module = {}
local ReplicatedStorage = game:GetService("ReplicatedStorage")

function Module.play(id: string)
    local sound = Instance.new("Sound")
    sound.SoundId = id
    sound.PlayOnRemove = true
    sound.Parent = workspace
    sound:Destroy()
end

function Module.init()
    local event = ReplicatedStorage:WaitForChild("SoundEvent", 10) :: RemoteEvent
    event.OnClientEvent:Connect(function(soundId: string)
        Module.play(soundId)
    end)
end

return Module