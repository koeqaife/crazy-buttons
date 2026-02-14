--!strict

export type Event = {
    chance: number, -- float: from 0 to 1
    minPlayers: number?,
    maxPlayers: number?,
    minRound: number?,
    maxRound: number?,
    maxPerGame: number?,
    check: () -> boolean,
    onEvent: () -> nil
}

return {}