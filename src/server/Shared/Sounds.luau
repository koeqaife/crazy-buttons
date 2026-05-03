--!strict
--!optimize 2

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Module = {}
Module.serverEvent = Instance.new("RemoteEvent", ReplicatedStorage)
Module.serverEvent.Name = "SoundEvent"

return Module