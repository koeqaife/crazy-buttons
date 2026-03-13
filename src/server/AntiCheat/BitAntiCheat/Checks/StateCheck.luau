-- Madonox
-- 2025

local StateCheck = {}

local function MaxVectorComponent(vector:Vector3)
	return math.max(vector.X, math.max(vector.Y, vector.Z))
end

local function RemoveStun(humanoid)
	humanoid.PlatformStand = false
end

local XZVector = Vector3.new(1, 0, 1)
local Rotation180 = CFrame.Angles(0, math.rad(180), 0)

local NewStateChecks = {
	[Enum.HumanoidStateType.Climbing] = function(bitPlayer, character:Model, humanoid:Humanoid, old:Enum.HumanoidStateType, queryParams:OverlapParams)
		local cf, size = character:GetBoundingBox()
		local parts = workspace:GetPartBoundsInRadius(cf.Position, MaxVectorComponent(size * XZVector) * 1.1, queryParams)

		-- checks for ladders (trusses + user made ladders)
		for _, part in parts do
			if part:IsA("TrussPart") then
				return
			end

			for _, otherPart in parts do
				if math.abs(otherPart.Position.Y - part.Position.Y) <= 1 then
					return
				end
			end

			table.remove(parts, table.find(parts, part)) -- has been checked against all other parts, remove to improve performance of algorithm
		end

		-- no suitable ladder found, stun the player and rotate 180 to prevent climbing
		humanoid.PlatformStand = true
		character:PivotTo(cf * Rotation180) -- teleport backwards to prevent infinite cycle
		bitPlayer:strike(1, "Climbing Without Ladder")
		task.delay(1, RemoveStun, humanoid)
	end;

	[Enum.HumanoidStateType.Seated] = function(bitPlayer, character:Model, humanoid:Humanoid, old:Enum.HumanoidStateType, queryParams:OverlapParams)
		local cf, size = character:GetBoundingBox()
		local parts = workspace:GetPartBoundsInRadius(cf.Position, MaxVectorComponent(size * XZVector) * 1.1, queryParams)

		for _, part in parts do
			if part:IsA("Seat") then
				return
			end
		end

		humanoid.PlatformStand = true
		character:PivotTo(cf * Rotation180)
		bitPlayer:strike(1, "Sitting Without Seat")
	end;
}

function StateCheck:characterAdded(bitPlayer, character:Model)
	local humanoid:Humanoid = character:FindFirstChildOfClass("Humanoid") or character:WaitForChild("Humanoid") :: Humanoid
	local overlapParams = OverlapParams.new()
	overlapParams.FilterType = Enum.RaycastFilterType.Exclude
	overlapParams.MaxParts = 100
	overlapParams.FilterDescendantsInstances = {character}
	overlapParams.RespectCanCollide = true

	humanoid.StateChanged:Connect(function(old:Enum.HumanoidStateType, new:Enum.HumanoidStateType)
		if old == Enum.HumanoidStateType.Dead then
			bitPlayer:strike(1, "Dead State Change")
			humanoid:ChangeState(Enum.HumanoidStateType.Dead)
			return
		end

		local newStateCheck = NewStateChecks[new]
		if newStateCheck then
			newStateCheck(bitPlayer, character, humanoid, old, overlapParams)
		end
	end)
end

return StateCheck