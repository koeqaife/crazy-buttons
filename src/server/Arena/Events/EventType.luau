--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Promise = require(ReplicatedStorage.Shared.Promise)

export type Event = {
    chance: number, -- float: from 0 to 1
    minPlayers: number?,
    maxPlayers: number?,
    minRound: number?,
    maxRound: number?,
    maxPerGame: number?,
    customGreen: boolean,
    check: () -> boolean,
    onEvent: () -> Promise.TypedPromise<Event?>
}

return {}