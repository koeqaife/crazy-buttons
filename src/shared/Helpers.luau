local HelpersModule = {}

function HelpersModule.shuffleTable(tbl, seed: number?)
	local rng = Random.new(seed)
	for i = #tbl, 2, -1 do
		local j = rng:NextInteger(1, i)
		tbl[i], tbl[j] = tbl[j], tbl[i]
	end
	return tbl
end

return HelpersModule