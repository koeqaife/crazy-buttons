-- Madonox
-- 2025

-- non-model based loader

local BitAntiCheat = require(script:WaitForChild("BitAntiCheat"))

BitAntiCheat:instance():safeLoad({
	initIdentity = 0;

	configuration = {
		silentLog = false;
		clientEnabled = true;
		strikesNeeded = 10; -- how many strikes a player needs before getting kicked

		disabledChecks = {
			
		};
	};
})

BitAntiCheat:instance().functions.onPlayerStriked += function(self, player:Player, reason:string, weight:number)
	print("Patched function executed, calling original...")
	self:func()(player, reason, weight)
end