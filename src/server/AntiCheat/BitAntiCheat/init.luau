-- Madonox
-- 2025

--// INTERNAL IDENTITY

local BIT_INTERNAL_ID = 0

--//

--[=[
	@class BitAntiCheat
	Primary anticheat singleton class
]=]
local BitAntiCheat = {
	functions = {};
	configuration = {};
}

--[=[
	@prop functions {[string]: PatchFunction}
	@within BitAntiCheat
	A table of patchable functions.  It contains functions like onCheaterCaught and onPlayerStriked.
]=]

BitAntiCheat.__index = BitAntiCheat

local Log = require(script:WaitForChild("Log"))
local Patch = require(script:WaitForChild("Patch"))
local BitPlayer = require(script:WaitForChild("BitPlayer"))

type BitAntiCheatProperties = {
	functions: {
		onCheaterCaught: Patch.PatchFunction;
		onPlayerStriked: Patch.PatchFunction;
	};
}
export type BitAntiCheat = typeof(setmetatable({} :: BitAntiCheatProperties, BitAntiCheat))

local BitInstance; -- checks if metatable has been set or not
local BitActive = false;

--[=[
	@within BitAntiCheat
	Returns the anticheat instance
	@return BitAntiCheat

	Basic initialization script:
	```lua
	local BitAntiCheat = require(path.to.BitAntiCheat)
	BitAntiCheat:instance():safeLoad({
		initIdentity = 0;

		configuration = {
			silentLog = false;
			clientEnabled = true;
			strikesNeeded = 10; -- how many strikes a player needs before getting kicked

			disabledChecks = {};
		};
	})
	```
]=]
function BitAntiCheat:instance(): BitAntiCheat
	if BitInstance then
		return BitInstance
	end

	-- construct anticheat

	setmetatable(BitAntiCheat, BitAntiCheat)
	setmetatable(BitPlayer, self)

	local checks = {}
	for _, module in script:WaitForChild("Checks"):GetChildren() do
		local req = require(module)
		checks[module.Name] = req

		if req.init then
			req:init()
		end
		Patch.newTable(req)
	end
	table.freeze(checks)
	self.checks = checks

	self.functions.onCheaterCaught = Patch.newFunction(function(player:Player, reason:string)
		player:Kick("Unstable connection.  Please get a better connection before rejoining.") -- TODO: use config kick reason
	end)

	local logFormat = "[BitAntiCheat]: %s"
	local log = Log.new(function(message:string, ...)
		return string.format(logFormat, string.format(message, ...))
	end)
	self.logger = log

	self.functions.onPlayerStriked = Patch.newFunction(function(player:Player, reason:string, weight:number)
		log:print("Player %s striked for %s with weighting %i", player.Name, reason, weight)
	end)

	BitInstance = BitAntiCheat
	table.freeze(BitAntiCheat)

	-- anti-tamper
	local originalScriptParent = script.Parent

	local function pcallParent(object, newParent)
		object.Parent = newParent
	end

	script.AncestryChanged:Connect(function()
		if script.Parent ~= originalScriptParent then
			local success, _ = pcall(pcallParent, script, originalScriptParent)
			log:warn("A component of BitAntiCheat is being tampered with by a server script!  This could be a serious vulnerability!  Component: %s;  Restore success: %*", script:GetFullName(), success)
		end
	end)
	for _, inst in script:GetDescendants() do
		local originalInstParent = inst.Parent
		inst.AncestryChanged:Connect(function()
			if inst.Parent ~= originalInstParent then
				local success, _ = pcall(pcallParent, script, originalScriptParent)
				log:warn("A component of BitAntiCheat is being tampered with by a server script!  This could be a serious vulnerability!  Component: %s;  Restore success: %*", inst:GetFullName(), success)
			end
		end)
	end

	return BitInstance -- keeps type checking from complaining
end

--[=[
	@within BitAntiCheat
	Used to initialize a safe load
	@param token The current loader token and configuration table
]=]
function BitAntiCheat:safeLoad(token)
	if BitActive then
		self.logger:warn("Cannot start BitAntiCheat!  An instance is already running!")
		return
	end

	self:instance() -- safety call
	if token and token.initIdentity == BIT_INTERNAL_ID then -- checks to make sure the loader is up-to-date
		local configuration = token.configuration
		local selfConfiguration = self.configuration -- since the anticheat root is frozen we manually copy values
		for k, v in configuration do
			selfConfiguration[k] = v
		end

		if configuration.silentLog then -- disables all logging
			local function nullFunction()

			end
			self.logger.print += nullFunction
			self.logger.warn += nullFunction
			self.logger.error += nullFunction
		end

		if configuration.disabledChecks then
			for _, check in configuration.disabledChecks do
				self.checks[check].disabled = true
			end
		end

		BitPlayer:init()
		return
	end

	self.logger:error("Invalid BitAntiCheat loader.  Please install a new one.  BitAntiCheat is NOT running.")
end

--[=[
	@within BitAntiCheat
	Method to directly fetch a BitPlayer from a regular Player instance.
	@param player Player -- The target player
	@return BitPlayer
]=]
function BitAntiCheat:player(player:Player)
	self:instance() -- safety call
	if BitActive then
		return (BitPlayer :: {[any]: any}).players[player] -- quick typecast to fix issues
	end

	self.logger:error("Cannot fetch BitPlayer for player %s.  BitAntiCheat is not running!", player.Name)
	return nil
end

return BitAntiCheat