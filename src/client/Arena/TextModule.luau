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

local currentGeneration = 0
local generationIsRunning = false

local function setText(
    current: string,
    new: string,
    speed: number,
    generation: number
): ()
    local result = ""
    local maxLength = math.max(#current, #new)

    generationIsRunning = true
    for i = 1, maxLength do
        if generation ~= currentGeneration then
            mainText.Text = new
            return
        end

        local char = new:sub(i, i)

        if i <= #new then
            result ..= char
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
    generationIsRunning = false
end

function TextModule.connect(): ()
    game:GetService("ContentProvider")
        :PreloadAsync({mainText})

    UpdateTextEvent.OnClientEvent:Connect(
        function(action: "set" | "append", text: string)
            currentGeneration += 1
            local myGeneration = currentGeneration

            if generationIsRunning then
                task.wait(0.25)
            end

            if action == "set" then
                setText("", text, 0.03, myGeneration)
            elseif action == "append" then
                setText(
                    mainText.Text,
                    mainText.Text .. text,
                    0.03,
                    myGeneration
                )
            end
        end
    )
end

return TextModule