-- BitAntiCheat configuration

local CONFIGURATION = {
	silentLog = false; -- If logging should be disabled
	clientEnabled = true; -- If the client based detection should be disabled
	strikesNeeded = 10; -- how many strikes a player needs before getting kicked
	disabledChecks = {}; -- Any checks to disable
}

return CONFIGURATION