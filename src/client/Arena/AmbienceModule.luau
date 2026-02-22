--!optimize 2
--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SoundsFolder = ReplicatedStorage:WaitForChild("Ambience") :: Folder
local SpawnSoundsParts = workspace:WaitForChild("SpawnSoundParts") :: Folder

local sounds: {Sound} = {}
local spawnLocations: {Part} = {}

local AmbienceModule = {}

local allowedTypes = {"neutral", "tense", "scary"}
local allowedModes = {"central", "around"}

local MIN_DELAY = 20
local MAX_DELAY = 90

local function getRandomDelay()
    return math.random(MIN_DELAY, MAX_DELAY)
end

local function weightedType()
    local roll = math.random()

    if roll < 0.05 then
        return "scary"
    elseif roll < 0.30 then
        return "tense"
    else
        return "neutral"
    end
end

local function getRandomSoundByType(soundType: string): Sound?
    local filtered = {}

    for _, sound in ipairs(sounds) do
        if sound:GetAttribute("Type") == soundType then
            table.insert(filtered, sound)
        end
    end

    if #filtered == 0 then
        return nil
    end

    return filtered[math.random(1, #filtered)]
end


local function playSound(template: Sound)
    local clone = template:Clone()

    local parent
    if clone:GetAttribute("Mode") == "central" then
        parent = workspace
    else
        parent = spawnLocations[math.random(1, #spawnLocations)]
    end

    clone.Parent = parent
    clone.PlayOnRemove = true
    clone:Destroy()
end

-- local function testEverySound()
--     for _, sound in ipairs(sounds) do
--         print("Testing sound: " .. sound.Name)
--         playSound(sound)
--         task.wait(sound.TimeLength + 2)
--     end
-- end

local function timer()
    while true do
        task.wait(getRandomDelay())

        if #sounds == 0 then
            continue
        end

        local soundType = weightedType()
        local sound = getRandomSoundByType(soundType)

        if sound then
            print("Playing ambience sound: " .. sound.Name .. " (Type: " .. soundType .. ")")
            playSound(sound)

            if soundType == "scary" then
                task.wait(math.random(40, 120))
            end
        end
    end
end


function AmbienceModule.init()
    for _, child in ipairs(SoundsFolder:GetChildren()) do
        if child:IsA("Sound") then
            table.insert(sounds, child)
        end
    end

    SoundsFolder.ChildAdded:Connect(function(child)
        if child:IsA("Sound") then
            table.insert(sounds, child)

            if not table.find(allowedTypes, child:GetAttribute("Type") :: string) then
                warn("Ambience sound has invalid Type attribute: " .. child.Name)
            end

            if child:GetAttribute("Mode") == nil then
                child:SetAttribute("Mode", "around")
            elseif not table.find(allowedModes, child:GetAttribute("Mode") :: string) then
                warn("Ambience sound has invalid Mode attribute: " .. child.Name)
            end
        end
    end)

    SoundsFolder.ChildRemoved:Connect(function(child)
        if child:IsA("Sound") then
            for i = #sounds, 1, -1 do
                if sounds[i] == child then
                    table.remove(sounds, i)
                    break
                end
            end
        end
    end)

    for _, child in ipairs(SpawnSoundsParts:GetChildren()) do
        if child:IsA("Part") then
            print("Found spawn sound location: " .. child.Name)
            table.insert(spawnLocations, child)
        end
    end

    SpawnSoundsParts.ChildAdded:Connect(function(child)
        print("Added spawn sound location: " .. child.Name)
        if child:IsA("Part") then
            table.insert(spawnLocations, child)
        end
    end)

    SpawnSoundsParts.ChildRemoved:Connect(function(child)
        if child:IsA("Part") then
            for i = #spawnLocations, 1, -1 do
                if spawnLocations[i] == child then
                    table.remove(spawnLocations, i)
                    break
                end
            end
        end
    end)

    task.spawn(timer)
end

return AmbienceModule