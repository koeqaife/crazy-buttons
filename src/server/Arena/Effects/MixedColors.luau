--!strict
--!optimize 2
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Helpers = require(ReplicatedStorage.Shared.Helpers)
local IndicesType = require(ReplicatedStorage.Shared.IndicesType)

local permutationCache: {{number}} = table.create(6)
local valuesBuffer: {number} = table.create(6)

local function buildPermutation(n: number): {number}
	local perm = table.create(n)
	for i = 1, n do
		perm[i] = i
	end

	Helpers.shuffleTable(perm)

	return perm
end

local Effect = {
    id = "mixed_colors",
    name = "Mixed Colors",
    description = "Button colors will mix every time now",
    universal = true,
    priority = 10,
    beforeRound = function()
        for n = 1, 6 do
            permutationCache[n] = buildPermutation(n)
        end
    end,
    buttonsEffect = function(buttons: IndicesType.Indices)
        local n = #buttons
        if n > 6 then
            return buttons
        end

        local perm = permutationCache[n]

        for i = 1, n do
            valuesBuffer[i] = buttons[i].showAs or buttons[i].idx
        end

        for i = 1, n do
            buttons[i].showAs = valuesBuffer[perm[i]]
        end

        return buttons
    end,
}

return Effect :: any