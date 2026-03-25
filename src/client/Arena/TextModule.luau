--!strict
--!optimize 2

local TextModule = {}
local ContentProvider = game:GetService("ContentProvider")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TextChatService = game:GetService("TextChatService")
local LocalizationService = game:GetService("LocalizationService")
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
    ["."] = 0.4,
    [","] = 0.25,
    ["!"] = 0.4,
    ["?"] = 0.4,
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
    combo_event_icon = "rbxassetid://97579105533591",
    even_odd_event_icon = "rbxassetid://103558857828491"
}

local specialFaces: {[string]: string} = {
    -- Faces
    normal = "rbxassetid://107354355339741",
    shy = "rbxassetid://111773173400091",
    scared = "rbxassetid://91677410847193",
    dead = "rbxassetid://115184962430003",
    no_mouth = "rbxassetid://73692493553538",
    laughing = "rbxassetid://103527716306567",
    angry = "rbxassetid://96689138674896",
    unamused = "rbxassetid://131207236532480",
    nerd = "rbxassetid://112962988947005",
    happy = "rbxassetid://119222263551912",
    looking = "rbxassetid://81924625663861",
    alien = "rbxassetid://72083440966852",

    -- Icons
    click_button_icon = "rbxassetid://122756434736419",
    att_def_tru_icon = "rbxassetid://130269008297548",
    color_event_icon = "rbxassetid://110888291370464",
    combo_event_icon = "rbxassetid://85805351076145",
    even_odd_event_icon = "rbxassetid://116538556063793"
}

-- I don't wanna optimize that
-- So it will load special faces even when they're not needed
-- I know that's not the best idea
for key, value in specialFaces do
    faces[key .. "_special"] = value
end

local emoticons: {[string]: string} = {
    shy = "^_^",
    shy_special = "^_^",

    scared = "D:",
    scared_special = "D:",

    dead = "x_x",
    dead_special = "x_x",

    laughing = "XD",
    laughing_special = "XD",

    angry = ">:(",
    angry_special = ">:(",

    unamused = "-_-",
    unamused_special = "-_-",

    happy = ":D",
    happy_special = ":D",
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
    generation: number,
    face: any?
): ()
    if #new == 0 then
        mainText.Text = ""
        generationIsRunning = false
        return
    end

    local baseSpeed = 0.035
    local lengthFactor = math.clamp(#new / 40, 1, 3)
    local speed = baseSpeed / lengthFactor

    local result = ""
    local maxLength = math.max(#current, #new)

    generationIsRunning = true
    for i = 1, maxLength do
        if generation ~= currentGeneration then
            mainText.Text = new
            TextChatService.TextChannels.RBXGeneral:DisplaySystemMessage(
                "<font color=\"#88f584\"><b>[TEXT] " .. new .. "</b></font>"
            )
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
    TextChatService.TextChannels.RBXGeneral:DisplaySystemMessage(
        "<font color=\"#88f584\"><b>[TEXT] " .. new .. " " .. (emoticons[face or ""] or "") .. "</b></font>"
    )
end

local function preload()
    ContentProvider:PreloadAsync({mainText})
    local images: {ImageLabel} = {}

    for _, face in pairs(faces) do
        local imageLabel = Instance.new("ImageLabel")
        imageLabel.Image = face
        table.insert(images, imageLabel)
    end

    ContentProvider:PreloadAsync(images)
end

local function sendLocaleToServer(locale)
    UpdateTextEvent:FireServer("set_language", locale)
end

function TextModule.connect(): ()
    preload()

    local success, translator = pcall(function()
        return LocalizationService:GetTranslatorForPlayerAsync(Players.LocalPlayer)
    end)

    if not success or not translator then
        warn("Failed to get translator", translator)
        return
    end

    -- initial locale
    local currentLocale = translator.LocaleId
    sendLocaleToServer(currentLocale)

    -- listen for changes
    translator:GetPropertyChangedSignal("LocaleId"):Connect(function()
        if translator.LocaleId ~= currentLocale then
            currentLocale = translator.LocaleId
            sendLocaleToServer(currentLocale)
        end
    end)

    UpdateTextEvent.OnClientEvent:Connect(
        function(text: string, face: Face?)
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

            setText("", text, myGeneration, face)
        end
    )
end

return TextModule