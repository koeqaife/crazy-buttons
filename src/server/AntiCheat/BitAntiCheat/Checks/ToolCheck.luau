-- Madonox
-- 2025

local ToolCheck = {}

function ToolCheck:characterAdded(bitPlayer, character:Model)
	local humanoid:Humanoid = character:FindFirstChildOfClass("Humanoid") :: Humanoid
	local normalEquips = 0
	character.ChildAdded:Connect(function(child:BackpackItem|Instance)
		if child:IsA("BackpackItem") then
			for _, otherChild in character:GetChildren() do
				if otherChild ~= child and otherChild:IsA("BackpackItem") then
					humanoid:UnequipTools()
					bitPlayer:strike(1, "Multiple Tools")
					return
				end
			end

			normalEquips += 1
			if normalEquips > 3 then -- strikes can false-positive in high ping situations / if someone mashes their keyboard
				normalEquips = 0
				bitPlayer:removeStrike(1, "Multiple Tools")
			end
		elseif child:IsA("Humanoid") then
			humanoid = child
		end
	end)
end

return ToolCheck