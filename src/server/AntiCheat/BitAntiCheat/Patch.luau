-- Madonox
-- 2025

--[=[
	@class PatchFunction
	A function that can be patched.  The final patch executed generates the return value.
]=]
local PatchFunction = {}
PatchFunction.__index = PatchFunction

function PatchFunction.__call(pFunc:PatchFunction, ...)
	local binds = pFunc.binds
	if #binds > 0 then
		local out
		for _, func in pFunc.binds do
			out = func(pFunc, ...)
		end
		return out
	end

	return pFunc:func()(...)
end

--[=[
	@within PatchFunction
	Allows you to add a patch.
	@param patch (PatchFunction, ...any) -> any -- The function to add.
	@return PatchFunction -- Returns the same patch function (enables += functionality)

	```lua
	local myPatch = PatchFunction.newFunction(function(message)
		print(`Hello, {message}`)
	end)

	myPatch += function(patch, message)
		print(`Got argument {message}, forwarding to original function`)
		patch:func()(message) -- calls the original function
	end

	myPatch("world") -- outputs "Got argument world, forwarding to original function" and "Hello, world"
	```
]=]
function PatchFunction.__add(pFunc:PatchFunction, patch:(PatchFunction, ...any) -> any)
	if not table.find(pFunc.binds, patch) then
		table.insert(pFunc.binds, patch)
	end
	return pFunc -- += stores, so we return self
end

--[=[
	@within PatchFunction
	Allows you to remove a patch.
	@param patch (PatchFunction, ...any) -> any -- The function to remove.
	@return PatchFunction -- Returns the same patch function (enables -= functionality)

	```lua
	local myPatch = PatchFunction.newFunction(function(message)
		print(`Hello, {message}`)
	end)
	local function otherFunction(patch, message)
		print(`Got argument {message}, forwarding to original function`)
		patch:func()(message) -- calls the original function
	end

	myPatch += otherFunction

	myPatch("world") -- outputs "Got argument world, forwarding to original function" and "Hello, world"

	myPatch -= otherFunction

	myPatch("world") -- outputs "Hello, world"
	```
]=]
function PatchFunction.__sub(pFunc:PatchFunction, patch:(PatchFunction, ...any) -> any)
	local ref = table.find(pFunc.binds, patch)
	if ref then
		table.remove(pFunc.binds, ref)
	end
	return pFunc -- += stores, so we return self
end

--[=[
	@within PatchFunction
	Returns the embedded function.
]=]
function PatchFunction:func()
	return self._func
end

export type PatchFunction = typeof(setmetatable({}, PatchFunction))

local Patch = {}

--[=[
	@within PatchFunction
	Returns a new patchable function.
	@param func (...any) -> any -- The function to wrap.
]=]
function Patch.newFunction(func:(...any) -> any)
	local patchFunction = setmetatable({_func = func, binds = {}}, PatchFunction)
	return patchFunction
end

--[=[
	@within PatchFunction
	Makes all functions in a table into patch functions
	@param funcTable {[any]: (...any) -> any} -- The table containing functions to patch.
]=]
function Patch.newTable(funcTable:{[any]: (...any) -> any})
	for k, func in funcTable do
		if typeof(func) == "function" then
			funcTable[k] = Patch.newFunction(func)
		end
	end
end

return Patch