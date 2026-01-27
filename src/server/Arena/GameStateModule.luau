local GameState = {
    alivePlayers = {},
    deadPlayers = {}
}

function GameState.kill(player: Player)
    local character = player.Character
    if character then
        local humanoid = character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            humanoid.Health = 0
        end
    end

    for i, p in ipairs(GameState.alivePlayers) do
        if p == player then
            table.remove(GameState.alivePlayers, i)
            break
        end
    end
    table.insert(GameState.deadPlayers, player)
end

return GameState