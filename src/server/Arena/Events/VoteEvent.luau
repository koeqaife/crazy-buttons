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

type EventType = EventTypeModule.Event

local Event = {} :: EventType

Event.chance = 0.1
Event.maxPerGame = 7
Event.minPlayers = 3

local highlightColors = {
    Color3.new(0.95, 0.21, 0.21),   -- Red
    Color3.new(0, 0.35, 1),         -- Blue
    Color3.new(1, 0.14, 0.81),      -- Pink
    Color3.new(0.96, 0.8, 0.19),    -- Yellow
}

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

    GameState.runFuncPerDead(function(player)
        TextModule.setText(player, "They're voting for who to eliminate", "shy")
    end)

    GameState.runPromisePerAlive(function(player, protect)
        if table.find(playersForVote, player) then
            return protect(TextModule.showTextSequence(player, {
                { text = "Someone will be eliminated now", delay = 3, face = "normal" },
                { text = "Other players will decide your fate...", delay = 4, face = "scared" },
            }))
        else
            return protect(TextModule.showTextSequence(player, {
                { text = "Someone will be eliminated now", delay = 3, face = "normal" },
                { text = "Choose wisely who should be eliminated", delay = 4, face = "happy" },
            }))
        end
    end):catch(error):await()

    TimerModule.setTime(30)

    local votingPromise = ButtonsModule.initiateButtonChoice(30, nil, function(player, idx)
        GameState.removeHighlightFromOne(player)
        if idx ~= nil then
            GameState.addHighlightToOne(player, highlightColors[idx])
        end
    end, nil, true)

    local buttons: IndicesType.Indices = {}
    for i, playerForVote in ipairs(playersForVote) do
        table.insert(buttons, { idx = i, text = playerForVote.Name })

        local color = highlightColors[i]
        GameState.addHighlightToOne(playerForVote, color, color)
    end

    GameState.runNewPromisePerAlive(function(player, protect, await)
        if table.find(playersForVote, player) then
            await(TextModule.showTextSequence(player, {
                { text = "It may be a bit boring while they're voting?", delay = 4, face = "normal" },
                { text = "Many people are crazy", delay = 4, face = "shy" },
                { text = "They are gonna choose someone who just looks bad", delay = 5, face = "normal" },
                { text = "Or someone who did something bad", delay = 4, face = "scared" },
                { text = "If you know what I'm talking about", delay = 5, face = "normal" },
                { text = "You didn't make them mad, right?", delay = 4, face = "shy" },
                { text = "Let's see who was eliminated", delay = 4, face = "scared" },
            }))
        else
            ButtonsModule.setButtons(player, buttons)
        end
    end)

    local _, result = votingPromise:catch(error):await()

    local votes: { [Player]: number } = {}
    for _, idx in pairs(result) do
        if idx then
            local votedPlayer = playersForVote[idx]
            if votedPlayer then
                votes[votedPlayer] = (votes[votedPlayer] or 0) + 1
            end
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

    GameState.runFuncPerAll(function(player: Player)
        if player == mostVotedPlayer then
            TextModule.setText(player, "You were eliminated... I'm sorry", "dead")
            GameState.kill(player)
        else
            TextModule.setText(player, "Player " .. mostVotedPlayer.Name .. " was eliminated", "dead")
        end
    end)
    task.wait(5)

    return
end

return Event