-- Madonox
-- 2025

local CollectionService = game:GetService("CollectionService")
local InstanceLoaded = false

local function DetectActiveInstance()
	return #CollectionService:GetTagged("BitAntiCheatRuntime" .. tostring(game.PlaceId)) > 0
end

local BitAntiCheatLoader = {}

local function TriggerBAC(module, ...)
	require(module):instance():safeLoad(...)
end

function BitAntiCheatLoader:init(src, ...)
	script:AddTag("BitAntiCheatRuntime" .. tostring(game.PlaceId)) -- labels this module as an active instance
	if not DetectActiveInstance() and not InstanceLoaded then
		InstanceLoaded = true
		local bitAntiCheat = script:WaitForChild("BitAntiCheat")
		bitAntiCheat.Parent = game:GetService("ServerScriptService")
		task.spawn(TriggerBAC, bitAntiCheat, ...)
		script.Parent = nil -- Persist the script so it's tag remains as a label
		return
	end
	warn("[BitAntiCheat EMBEDDED]: Attempted to load BitAntiCheat more than once!  Aborting additional load attempt.  BitAntiCheat should still be running.  Additional script source: " .. src:GetFullName())
end

setmetatable(BitAntiCheatLoader, {
	__call = function(_, ...)
		BitAntiCheatLoader:init(...)
	end
})

return BitAntiCheatLoader