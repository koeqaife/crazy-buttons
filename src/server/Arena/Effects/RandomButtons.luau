--!strict
--!optimize 2
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Helpers = require(ReplicatedStorage.Shared.Helpers)
local IndicesType = require(ReplicatedStorage.Shared.IndicesType)
local buttonSpawns: {string}

local Effect = {
    id = "random_buttons",
    name = "Random Buttons",
    description = "Buttons will be located on random positions on the map",
    priority = 10,
    universal = true,
    startHook = function()
        local spawns = ReplicatedStorage.GodButtons :: Folder
        buttonSpawns = {}

        for i, part in spawns:GetChildren() do
            if part:IsA("Part") then
                local clone = part:Clone()
                clone.Parent = workspace
                clone.Name = "ButtonSpawn_" .. i
                table.insert(buttonSpawns, clone.Name)
            end
        end
    end,
    beforeRound = function()
        Helpers.shuffleTable(buttonSpawns)
    end,
    buttonsEffect = function(buttons: IndicesType.Indices)
        for i, button in ipairs(buttons) do
            if not button.spawnAt then
                button.spawnAt = buttonSpawns[i]
            end
        end
        return buttons
    end,
    timeBonus = function(original: number): number
        -- So people always have time to go to the button from one place of the map to another
        return original + 10
    end
}

return Effect :: any