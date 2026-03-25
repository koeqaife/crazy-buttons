--!strict
--!optimize 2
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local Format = require(ServerScriptService.Server.Arena.Replicas.Format)
local IndicesType = require(ReplicatedStorage.Shared.IndicesType)

local function boopify(text: string): string
    local function transformWord(word: string): string
        local lower = string.lower(word)

        lower = lower:gsub("what", "vorp")
        lower = lower:gsub("oto", "ogo")
        lower = lower:gsub("pr", "b")
        lower = lower:gsub("[dwlf]", "b")
        lower = lower:gsub("[tmnxkq]", "p")

        lower = lower:gsub("что", "ворп")
        lower = lower:gsub("про", "б")
        lower = lower:gsub("[длфв]", "б")
        lower = lower:gsub("[тмнкс]", "п")

        lower = lower:gsub("^%l", string.upper)

        return lower
    end

    return text:gsub("%a+", transformWord)
end

local Effect = {
    id = "alien",
    name = "Alien Language",
    description = "I will be talking with you on alien language",
    universal = true,
    priority = 25,
    faceEffect = function(original: Format.Face?)
        local face = original
        if face == nil then
            return
        elseif type(face) == "string" then
            face = "alien"
        end
        return face
    end,
    textTransform = function(text: string)
        return boopify(text)
    end,
    buttonsEffect = function(buttons: IndicesType.Indices)
        for _, button in ipairs(buttons) do
            if button.text then
                button.text = boopify(button.text)
            end
        end
        return buttons
    end,
}

return Effect :: any