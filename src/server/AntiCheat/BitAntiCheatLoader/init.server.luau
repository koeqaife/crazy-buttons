-- Madonox
-- 2025

-- BitAntiCheat Loader
-- Don't touch the code below unless you know what you're doing!!!
-- Configuration can be found in the Configuration module below this script.

-- ** FOR TESTING **
if true then
	return
end

local success, src = pcall(require, 77068927790110)
local success2, config = pcall(require, script:WaitForChild("Configuration"))

if success and success2 then
	src:init(script, {
		initIdentity = 0;
		configuration = config;
	})
	script:Destroy()
	return
end
warn("[BitAntiCheat LOADER]: Failed to load BitAntiCheat!  Check if the configuration is properly filled out, and that the experience can require models.  BitAntiCheat is NOT running!")
script:Destroy()