-- Madonox
-- 2025

local RotationCheck = {}

function RotationCheck:checkPlayer(bitPlayer)
	local char = bitPlayer.player.Character
	if char and char:IsDescendantOf(workspace) and char.PrimaryPart then
		local root:BasePart = char.PrimaryPart

		if root and root.AssemblyAngularVelocity.Magnitude > 72 then
			bitPlayer:strike(1, "High Angular Velocity")
			root.AssemblyAngularVelocity = Vector3.zero
			return 1
		end
	end

	bitPlayer:removeStrike(1, "High Angular Velocity")
	return 3
end

return RotationCheck