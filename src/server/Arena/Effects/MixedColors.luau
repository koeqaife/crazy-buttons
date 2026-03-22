--!strict
--!optimize 2
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local IndicesType = require(ReplicatedStorage.Shared.IndicesType)
local random = math.random

local Effect = {
    id = "mixed_colors",
    name = "Mixed Colors",
    description = "Button colors will mix every time now",
    universal = true,
    priority = 10,
    buttonsEffect = function(buttons: IndicesType.Indices)
        for _, button in ipairs(buttons) do
            button.showAs = random(1, 5)
        end
        return buttons
    end,
}

return Effect :: any