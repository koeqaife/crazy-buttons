local HelpersModule = {}

function HelpersModule.shuffleTable(tbl, seed: number?)
	if seed then
		math.randomseed(seed)
	end
	for i = #tbl, 2, -1 do
		local j = math.random(i)
		tbl[i], tbl[j] = tbl[j], tbl[i]
	end
	math.randomseed(tick())
	return tbl
end

return HelpersModule