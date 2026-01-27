--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local IndicesModule = require(ReplicatedStorage.Shared.IndicesType)

type Indices = IndicesModule.Indices

export type SideEffect = {
    forRounds: number,
    afterRound: number,
    buttonsEffect: (indices: Indices) -> Indices
}

return {}