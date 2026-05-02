local HelpersModule = {}

function HelpersModule.getServerType(): "VIPServer" | "ReservedServer" | "StandardServer"
	if game.PrivateServerId ~= "" then
		if game.PrivateServerOwnerId ~= 0 then
			return "VIPServer"
		else
			return "ReservedServer"
		end
	else
		return "StandardServer"
	end
end

function HelpersModule.shuffleTable(tbl, seed: number?)
	local rng = Random.new(seed)
	for i = #tbl, 2, -1 do
		local j = rng:NextInteger(1, i)
		tbl[i], tbl[j] = tbl[j], tbl[i]
	end
	return tbl
end

return HelpersModule