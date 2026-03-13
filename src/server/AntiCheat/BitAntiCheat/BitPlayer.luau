-- Madonox
-- 2025

local Players = game:GetService("Players")
local ClientRuntime = script.Parent:WaitForChild("Client")

local function CountStrikes(dict:{[string]: number})
	local tc = 0
	for _, c in dict do
		tc += c
	end

	return tc
end

--[=[
	@class BitPlayer
	Class wrapper for players.  Handles timings, tracking, and more.
]=]
local BitPlayer = {}
BitPlayer.__index = BitPlayer

function BitPlayer:init()
	local players = {}
	self.players = players

	local function newPlayer(player:Player)
		if not players[player] then
			players[player] = self:new(player)
		end
	end

	Players.PlayerAdded:Connect(newPlayer)
	Players.PlayerRemoving:Connect(function(player:Player)
		local class = players[player]
		if class then
			class:dispose()
		end
	end)

	for _, player in Players:GetPlayers() do
		newPlayer(player)
	end

	if self.configuration.clientEnabled then
		local commsEvent = Instance.new("RemoteEvent")
		commsEvent.OnServerEvent:Connect(function(player, mode)
			local class = players[player]
			if class then
				if mode == 1 then
					class.lastPing = os.time()
				elseif mode == 2 then
					class:strike(math.huge, "Client Exploit")
				end
			end
		end)
		commsEvent:AddTag("BACTag0x0")
		local repStorage = game:GetService("ReplicatedStorage")
		commsEvent.Parent = repStorage

		-- anti-tamper

		local function pcallParent(object, newParent)
			object.Parent = newParent
		end
		commsEvent.AncestryChanged:Connect(function()
			if commsEvent.Parent ~= repStorage then
				local success, _ = pcall(pcallParent, commsEvent, repStorage)
				self.logger:warn("A component of BitAntiCheat is being tampered with by a server script!  This could be a serious vulnurability!  Component: %s;  Restore success: %*", commsEvent:GetFullName(), success)
			end
		end)
		local collectionService = game:GetService("CollectionService")
		collectionService:GetInstanceRemovedSignal("BACTag0x0"):Connect(function(item)
			if item == commsEvent then
				self.logger:warn("A component of BitAntiCheat is being tampered with by a server script!  This could be a serious vulnurability!  Component: %s;  Restoring component...", commsEvent:GetFullName())
				commsEvent:AddTag("BACTag0x0")
			end
		end)

		collectionService:GetInstanceAddedSignal("BACTag0x0"):Connect(function(item)
			if item ~= commsEvent then
				self.logger:warn("A server-script is attempting to tamper with BitAntiCheat functionality by adding non-BitAntiCheat instances to guarded tags!  This could be a serious vulnurability!  External instance: %s;  Removing intrusion...", item:GetFullName())
				item:RemoveTag("BACTag0x0")
			end
		end)

		local taggedItems = collectionService:GetTagged("BACTag0x0")
		if taggedItems[1] ~= commsEvent or rawlen(taggedItems) > 1 then
			local removedList = ""
			for _, v in taggedItems do
				if v ~= commsEvent then
					v:RemoveTag("BACTag0x0")
					removedList ..= "\n" .. v:GetFullName()
				end
			end

			self.logger:warn("Multiple instances using a reserved BitAntiCheat tag!  Removed the following instances from reserved tag:%s", removedList)
		end
	end
end

function BitPlayer:new(player:Player)
	local object = setmetatable({
		player = player;
		strikes = {};
		checkQueue = {};
		lastPing = os.time();
		memory = {};
	}, BitPlayer)

	if self.configuration.clientEnabled then
		ClientRuntime:Clone().Parent = player:WaitForChild("PlayerGui") -- safest cloning location as games almost always never destroy this
	end

	object.characterAdded = player.CharacterAdded:Connect(function(character)
		for _, check in self.checks do
			if check.characterAdded and not check.disabled then
				check:characterAdded(object, character)
			end
		end
	end)

	object.taskThread = coroutine.create(function()
		local resumptionPool = {}
		local checks = self.checks
		for id, check in checks do
			if check.checkPlayer and not check.disabled then
				resumptionPool[id] = 0
			end
		end

		-- algorithm to select the task that will run as soon as possible, wait it's delay, subtract the time from other tasks, then select again (keeps thread use down and has relatively little performance impact)
		while object.taskThread ~= nil do
			local minimumTime = 9999
			local callTask = nil

			for id, resumeTime in resumptionPool do
				if resumeTime < minimumTime then
					minimumTime = resumeTime
					callTask = id
				end
			end

			for id, _ in resumptionPool do
				if id ~= callTask then
					resumptionPool[id] -= minimumTime
				end
			end

			task.wait(minimumTime)

			resumptionPool[callTask] = checks[callTask]:checkPlayer(object)
		end

		table.clear(resumptionPool)
	end)
	coroutine.resume(object.taskThread)

	return object
end

--[=[
	@within BitPlayer
	Used to pause the checks on a player.
]=]
function BitPlayer:pauseChecks()
	local status = coroutine.status(self.taskThread)
	if status ~= "suspended" and status ~= "dead" then
		local success, _ = pcall(coroutine.yield, self.taskThread)
		if not success then
			self.logger:error("Failed to pause checks for player %s", self.player.Name)
		end
		return
	end
	self.logger:error("Failed to pause checks for player %s", self.player.Name)
end

--[=[
	@within BitPlayer
	Used to resume the checks on a player.
]=]
function BitPlayer:unpauseChecks()
	if coroutine.status(self.taskThread) == "suspended" then
		local success, _ = pcall(coroutine.resume, self.taskThread)
		if not success then
			self.logger:error("Failed to resume checks for player %s", self.player.Name)
		end
		return
	end
	self.logger:error("Failed to resume checks for player %s", self.player.Name)
end

--[=[
	@within BitPlayer
	Checks if the player is permitted to exist on this plane of existence (checks number of strikes and kicks them if they've reached the maximum).
]=]
function BitPlayer:validateExistence()
	local strikes = self.strikes
	local config = self.configuration
	if CountStrikes(strikes) >= config.strikesNeeded then
		local currentKey = nil
		local maxStrikes = 0

		for k, v in strikes do
			if v > maxStrikes then
				maxStrikes = v
				currentKey = k
			end
		end

		self.functions.onCheaterCaught(self.player, currentKey)
		return
	end

	if os.time() - self.lastPing > 5 and config.clientEnabled then -- used to check if the client might've disabled the client-sided anticheat (only processed )
		self.functions.onCheaterCaught(self.player, "No Client Ping")
	end
end

--[=[
	@within BitPlayer
	Adds x number of strikes to a player for a specific reason.

	@param count number -- The number of strikes to add
	@param reason string -- The strike reason
]=]
function BitPlayer:strike(count:number, reason:string)
	local strikes = self.strikes
	self.functions.onPlayerStriked(self.player, reason, count)

	if strikes[reason] then
		strikes[reason] += count
		self:validateExistence()
		return
	end

	strikes[reason] = count
	self:validateExistence()
end

--[=[
	@within BitPlayer
	Removes x number of strikes from a player.

	@param count number -- The number of strikes to remove
	@param reason string -- The strike id to remove from
]=]
function BitPlayer:removeStrike(count:number, reason:string)
	local strikes = self.strikes
	if strikes[reason] then
		strikes[reason] = math.min(0, strikes[reason] - count)
	end
end

function BitPlayer:dispose()
	local success, e = pcall(coroutine.close, self.taskThread)
	self.taskThread = nil -- will trigger a loop termination (prevents an infinite, undead thread)
	if not success then
		self.logger:warn("Failed to close thread for player %s.  Error: %s", self.player.Name, e)
	end
	self.characterAdded:Disconnect()
	table.clear(self.strikes)
	table.clear(self.checkQueue)
	table.clear(self.memory)
	table.clear(self)
	setmetatable(self, nil)
end

return BitPlayer