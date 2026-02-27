--!strict
--!optimize 2

local TextModule = {}
local ContentProvider = game:GetService("ContentProvider")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local spr = require(ReplicatedStorage.Shared.spr)

local blipSound: Sound = ReplicatedStorage
    :WaitForChild("Sounds")
    :WaitForChild("BlipSound")

local screen: Part = workspace
    :WaitForChild("TerminalScreen")

local mainText = screen
    :WaitForChild("SurfaceGui")
    :WaitForChild("mainText") :: TextLabel

local faceLabel = workspace
    :WaitForChild("TerminalFace")
    :WaitForChild("SurfaceGui")
    :WaitForChild("ImageLabel") :: ImageLabel

local faceTextLabel = workspace
    :WaitForChild("TerminalFace")
    :WaitForChild("SurfaceGui")
    :WaitForChild("TextLabel") :: TextLabel

local faceOriginalY = faceLabel.Position.Y.Offset
local faceTextOriginalY = faceTextLabel.Position.Y.Offset

local UpdateTextEvent: RemoteEvent = ReplicatedStorage:WaitForChild("UpdateTextEvent")

type Face = { text: string, face: string? } | string

local delayBonusCharacter = {
    [" "] = 0.03,
    ["."] = 0.35,
    [","] = 0.25,
    ["!"] = 0.35,
    ["?"] = 0.35,
}

local faces: {[string]: string} = {
    -- Faces
    normal = "rbxassetid://107111947104956",
    shy = "rbxassetid://125819053346135",
    scared = "rbxassetid://136539117420551",
    dead = "rbxassetid://135470867814496",
    no_mouth = "rbxassetid://98931398681309",
    laughing = "rbxassetid://97485490801508",
    angry = "rbxassetid://93647730037278",
    unamused = "rbxassetid://119426537718247",
    nerd = "rbxassetid://122185663314152",
    happy = "rbxassetid://102994110323402",
    looking = "rbxassetid://107685640555588",
    alien = "rbxassetid://137489883002094",

    -- Icons
    click_button_icon = "rbxassetid://130876390116070",
    att_def_tru_icon = "rbxassetid://105806735001450",
    color_event_icon = "rbxassetid://102053437743340",
    combo_event_icon = "rbxassetid://97579105533591"
}

local currentGeneration = 0
local generationIsRunning = false

local function faceJumpAnimation()
    local jumpHeight = 16

    spr.target(faceLabel, 0.55, 16, {
        Position = UDim2.new(
            faceLabel.Position.X.Scale,
            faceLabel.Position.X.Offset,
            faceLabel.Position.Y.Scale,
            faceOriginalY - jumpHeight
        ),
        Size = faceLabel.Size + UDim2.fromOffset(0, 4)
    })

    spr.target(faceTextLabel, 0.55, 16, {
        Position = UDim2.new(
            faceTextLabel.Position.X.Scale,
            faceTextLabel.Position.X.Offset,
            faceTextLabel.Position.Y.Scale,
            faceTextOriginalY - jumpHeight
        )
    })

    spr.completed(faceLabel, function()
        spr.target(faceLabel, 0.4, 12, {
            Position = UDim2.new(
                faceLabel.Position.X.Scale,
                faceLabel.Position.X.Offset,
                faceLabel.Position.Y.Scale,
                faceOriginalY + 4
            ),
            Size = faceLabel.Size - UDim2.fromOffset(0, 4)
        })
    end)

    spr.completed(faceTextLabel, function()
        spr.target(faceTextLabel, 0.4, 12, {
            Position = UDim2.new(
                faceTextLabel.Position.X.Scale,
                faceTextLabel.Position.X.Offset,
                faceTextLabel.Position.Y.Scale,
                faceTextOriginalY
            )
        })
    end)
end

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
    ContentProvider:PreloadAsync({mainText})

    for _, face in pairs(faces) do
        local imageLabel = Instance.new("ImageLabel")
        imageLabel.Image = face
        ContentProvider:PreloadAsync({imageLabel})
    end

    UpdateTextEvent.OnClientEvent:Connect(
        function(action: "set" | "append", text: string, face: Face?)
            currentGeneration += 1
            local myGeneration = currentGeneration

            if generationIsRunning then
                task.wait(0.25)
            end

            if face then
                if type(face) == "string" then
                    faceLabel.Image = faces[face] or ""
                    faceTextLabel.Text = ""
                elseif face.face then
                    faceLabel.Image = faces[face.face] or faces["looking"]
                    faceTextLabel.Text = face.text
                else
                    faceLabel.Image = faces["looking"]
                    faceTextLabel.Text = face.text
                end
                faceJumpAnimation()
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