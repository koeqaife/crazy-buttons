-- Madonox
-- 2025

-- Log class

local Patch = require(script.Parent:WaitForChild("Patch"))

--[=[
	@class Log
	Logger class.
]=]
local Log = {}
Log.__index = Log

export type Log = typeof(setmetatable({}, Log))

--[=[
	@within Log
	@param processor (...any) -> ...any -- The message processing function for logs.
	@return Log
]=]
function Log.new(processor:(...any) -> ...any): Log
	local logger = setmetatable({processor = Patch.newFunction(processor)}, Log)

	return logger
end

--[=[
	@within Log
	Prints out the processed arguments supplied to it.
]=]
function Log:print(...:any)
	print(self.processor(...))
end

--[=[
	@within Log
	Warns the processed arguments supplied to it.
]=]
function Log:warn(...:any)
	warn(self.processor(...))
end

--[=[
	@within Log
	Errors the processed arguments supplied to it.
]=]
function Log:error(...:any)
	error(self.processor(...))
end

Patch.newTable(Log)

return Log