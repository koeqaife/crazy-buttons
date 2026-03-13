-- Madonox
-- 2025

-- BitAntiCheat client runtime
-- All operations are in one script to help make indexing more difficult

script.Parent = nil
script.Name = "\0" -- C string terminator (messes with indexes)

local RE:RemoteEvent = game:GetService("CollectionService"):GetTagged("BACTag0x0")[1]
RE:RemoveTag("BACTag0x0")

local RNG = Random.new()

local function CFunction(yielder: (...any) -> any)
	return select(2, xpcall(yielder, function()
		return debug.info(2, "f")
	end))
end

--[[

local function ShuffleTable(t:{any}, n:number)
	local tLen = rawlen(t)
	for _ = 1, n do
		local i0, i1 = RNG:NextInteger(1, tLen), RNG:NextInteger(1, tLen)
		local v0 = t[i0]
		local v1 = t[i1]
		if v0 ~= v1 then -- done this way so we don't swap equal values
			t[i1] = v0
			t[i0] = v1
		end
	end

	return t
end

]]

local function RandomSecureString(len:number)
	local str = ""
	for i = 1, 100 do
		str ..= utf8.char(RNG:NextInteger(33, 126))
	end
	str ..= string.rep("\000", RNG:NextInteger(1, 8)) -- messes with indexes

	return str
end

local function StringTable(t:{any})
	for i = 1, #t do
		t[i] = tostring(t[i])
	end

	return t
end

local function Pipebomb()
	task.spawn(function()
		while true do
			task.spawn(Pipebomb)
			while true do
				Instance.new("BloomEffect", workspace)
			end
		end
	end)
end

-- Ping

task.spawn(function()
	while task.wait(.5) do
		RE:FireServer(1)
	end
end)

-- Services / forbidden access points
task.spawn(function()
	if game:GetService("RunService"):IsStudio() then -- studio safety lock
		print("[BitAntiCheat]: Service hook is disabled to prevent studio false flagging.")
		Pipebomb = function()
			warn("[BitAntiCheat]: Client detection function triggered in studio!")
		end
		return
	end

	local services = {
		"UGCValidationService";
	}

	while task.wait() do
		for _, s in services do
			if game:FindService(s) then
				RE:FireServer(2)
				Pipebomb()
				break
			end
		end
	end
end)

-- C function monitoring
task.spawn(function()
	local function cFetch()
		return workspace[RandomSecureString(100)]
	end

	local function nFetch()
		return workspace:__________()
	end

	local function iFetch()
		game.________ = nil
	end

	local c_index = CFunction(cFetch)
	local c_ncall = CFunction(nFetch)
	local c_icall = CFunction(iFetch)

	while task.wait(.1) do
		if c_index ~= CFunction(cFetch) or c_ncall ~= CFunction(nFetch) or c_icall ~= CFunction(iFetch) then
			RE:FireServer(2)
			Pipebomb()
		end
	end
end)

-- Check table functionality equality
task.spawn(function()
	local tClone = StringTable({debug.info(table.clone, "slnaf")})

	local function compareDebugTable(t1, t2)
		for i, v0 in t1 do
			if t2[i] ~= v0 then
				return true
			end
		end
		return false
	end

	while task.wait(.1) do
		if compareDebugTable(tClone, StringTable({debug.info(table.clone, "slnaf")})) then
			RE:FireServer(2)
			Pipebomb()
		end
	end
end)