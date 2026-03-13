-- Madonox
-- 2025

-- Compiles the MainModule from the BitAntiCheat instance

--_G.compileEnabled = true
if _G.compileEnabled then
	print(">> Compiling model...")
	script.Parent:WaitForChild("BitAntiCheat").Parent = script:WaitForChild("MainModule")
end
