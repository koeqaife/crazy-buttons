--!strict

export type Event = {
    chance: number, -- float: from 0 to 1
    name: string,
    category: string,
    minPlayers: number?,
    maxPlayers: number?,
    minRound: number?,
    maxRound: number?,
    maxPerGame: number?,
    supportedEffects: {string}?,
    check: () -> boolean,
    onEvent: () -> boolean?
}

return {}