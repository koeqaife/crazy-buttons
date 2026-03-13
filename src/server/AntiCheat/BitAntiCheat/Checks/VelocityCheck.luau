-- Madonox
-- 2025

local VelocityCheck = {}

local XZ_Normal = Vector3.new(1, 0, 1)
local SpeedEpsilon = 1.02

local SpeedStates = {
	Enum.HumanoidStateType.Running;
	Enum.HumanoidStateType.RunningNoPhysics;
	Enum.HumanoidStateType.StrafingNoPhysics;
	Enum.HumanoidStateType.Swimming;
	Enum.HumanoidStateType.Freefall;
}

function VelocityCheck:checkPlayer(bitPlayer)
	local character = bitPlayer.player.Character
	if character and character:IsDescendantOf(workspace) and character.PrimaryPart then
		local root = character.PrimaryPart
		local humanoid:Humanoid = character:FindFirstChildOfClass("Humanoid") or character:WaitForChild("Humanoid") :: Humanoid
		if (root.AssemblyLinearVelocity * XZ_Normal).Magnitude > (humanoid.WalkSpeed + SpeedEpsilon) and table.find(SpeedStates, humanoid:GetState()) then
			bitPlayer:strike(1, "High Velocity")
			root.AssemblyLinearVelocity = Vector3.zero

			local lastPos = bitPlayer.memory.lastPosition
			if lastPos then
				root.CFrame = CFrame.new(lastPos)
			end
			return 1
		end

		bitPlayer.memory.lastPosition = root.CFrame.Position
		return 1.5 -- slightly more delay as the player passed the velocity check
	end

	bitPlayer.memory.lastPosition = nil
	return 1
end

return VelocityCheck