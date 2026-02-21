--!optimize 2
--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SoundsFolder = ReplicatedStorage:WaitForChild("Ambience") :: Folder

local sounds: {Sound} = {}

local AmbienceModule = {}

local allowedTypes = {"neutral", "tense", "scary"}

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
    clone.Parent = workspace
    clone.PlayOnRemove = true
    clone:Destroy()
end


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

    task.spawn(timer)
end

return AmbienceModule