--!strict
--!optimize 2

-- Description:
-- from 2 to 4 players are gonna be voted
-- The one with highest amount of votes dies

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Arena = game:GetService("ServerScriptService").Server.Arena
local IndicesType = require(ReplicatedStorage.Shared.IndicesType)
local GameState = require(Arena.GameStateModule)
local EventTypeModule = require(Arena.Events.EventType)
local TextModule = require(Arena.TextModule)
local ButtonsModule = require(Arena.ButtonsModule)
local TimerModule = require(Arena.TimerModule)
local Promise = require(ReplicatedStorage.Shared.Promise)

type EventType = EventTypeModule.Event

local Event = {} :: EventType

Event.chance = 0.1
Event.maxPerGame = 7
Event.minPlayers = 3

local function getMostVoted(result: { [Player]: number }): Player?
    local maxVotes = -math.huge
    local topPlayer: Player? = nil

    for player, votes in pairs(result) do
        if votes > maxVotes then
            maxVotes = votes
            topPlayer = player
        end
    end

    return topPlayer
end

function Event.check()
    return true
end

function Event.onEvent()
    return Promise.new(function(resolve, reject, onCancel)
        -- Honestly not the best code, but at least it works

        local amount
        if #GameState.alivePlayers > 15 then
            amount = 4
        elseif #GameState.alivePlayers > 5 then
            amount = 3
        else
            amount = 2
        end

        local playersForVote = GameState.pickPlayers(amount)
        GameState.addHighlightTo(playersForVote)

        TimerModule.setTime(5)
        GameState.runPromisePerAlive(function(player: Player)
            if table.find(playersForVote, player) then
                return TextModule.showTextSequence(player, {
                    { text = "Someone will be eliminated now", delay = 2.5 },
                    { text = "Other players will decide your fate...", delay = 2.5 },
                })
            else
                return TextModule.showTextSequence(player, {
                    { text = "Someone will be eliminated now", delay = 2.5 },
                    { text = "Choose wisely who should be eliminated", delay = 2.5 },
                })
            end
        end):await()

        TimerModule.setTime(25)

        local votingPromise = ButtonsModule.initiateButtonChoice(25)

        GameState.runNewPromisePerAlive(function(player: Player)
            if table.find(playersForVote, player) then
                task.wait(2.5)
                TextModule.showTextSequence(player, {
                    { text = "It may be a bit boring while they're voting?", delay = 2.5 },
                    { text = "Many people are crazy", delay = 2.5 },
                    { text = "They are gonna choose someone who just looks bad", delay = 2.5 },
                    { text = "Or someone who did something bad", delay = 2.5 },
                    { text = "If you know what I'm talking about", delay = 2.5 },
                    { text = "You didn't make them mad, right?", delay = 5 },
                    { text = "Let's see who was eliminated", delay = 5 },
                }):await()
            else
                local buttons: IndicesType.Indices = {}
                for i, playerForVote in ipairs(playersForVote) do
                    table.insert(buttons, { idx = i, text = playerForVote.Name })
                end
                ButtonsModule.setButtons(player, buttons)
            end
        end)

        local ok, result = votingPromise:await()
        if not ok then
            return reject(result)
        end

        local votes: { [Player]: number } = {}
        for _, idx in pairs(result) do
            if idx then
                local votedPlayer = playersForVote[idx]
                votes[votedPlayer] = (votes[votedPlayer] or 0) + 1
            end
        end

        local mostVoted = getMostVoted(votes)

        local mostVotedPlayer
        if mostVoted == nil then
            local random = math.random(1, #playersForVote)
            mostVotedPlayer = playersForVote[random]
        else
            mostVotedPlayer = mostVoted
        end

        TimerModule.setTime(5)
        GameState.runFuncPerAll(function(player: Player)
            if player == mostVotedPlayer then
                TextModule.setText(player, "You were eliminated... I'm sorry")
                GameState.kill(player)
            else
                TextModule.setText(player, "Player " .. mostVotedPlayer.Name .. " was eliminated")
            end
        end):await()
        task.wait(5)

        resolve()
    end)
end

return Event