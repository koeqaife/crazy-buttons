--!strict
--!optimize 2

local TextModule = {}
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local blipSound: Sound = ReplicatedStorage
    :WaitForChild("Sounds")
    :WaitForChild("BlipSound")

local screen: Part = workspace
    :WaitForChild("TerminalScreen")

local mainText = screen
    :WaitForChild("SurfaceGui")
    :WaitForChild("mainText") :: TextLabel

local UpdateTextEvent: RemoteEvent = ReplicatedStorage:WaitForChild("UpdateTextEvent")

local delayBonusCharacter = {
    [" "] = 0.03,
    ["."] = 0.35,
    [","] = 0.25,
    ["!"] = 0.35,
    ["?"] = 0.35,
}

local function setText(current: string, new: string, speed: number)
    local result = ""
    local maxLength = math.max(#current, #new)
    for i = 1, maxLength do
        local char = new:sub(i, i)

        if i <= #new then
            result = result .. char
        end

        mainText.Text = result

        local bonus = delayBonusCharacter[char] or 0
        if bonus == 0 or char == " " then
            local sound = blipSound:Clone()
            sound.Parent = screen
            sound:Destroy()
        end

        task.wait(speed + bonus)
    end
end

function TextModule.connect()
    game:GetService("ContentProvider"):PreloadAsync({mainText})

    UpdateTextEvent.OnClientEvent:Connect(function(action: "set" | "append", text: string)
        if action == "set" then
            setText("mainText.Text", text, 0.03)
        elseif action == "append" then
            setText(mainText.Text, mainText.Text .. text, 0.03)
        end
    end)
end

return TextModule