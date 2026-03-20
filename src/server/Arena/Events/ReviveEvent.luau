--!strict
--!optimize 2

-- Description:
-- Event where one random player is gonna be revived
-- With 1/4 chance or if deadPlayers count is less than 3, it's gonna revive random player
-- Otherwise there is gonna vote with which player people wanna revive

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local Arena = game:GetService("ServerScriptService").Server.Arena
local MiscModule = require(ServerScriptService.Server.Arena.MiscModule)
local PlayersModule = require(ServerScriptService.Server.Arena.PlayersModule)
local IndicesType = require(ReplicatedStorage.Shared.IndicesType)
local EventTypeModule = require(Arena.Events.EventType)
local TextModule = require(Arena.TextModule)
local ButtonsModule = require(Arena.ButtonsModule)
local TimerModule = require(Arena.TimerModule)

type EventType = EventTypeModule.Event

local Event = {} :: EventType

Event.name = "revive"
Event.category = "social"
Event.chance = 0.05
Event.maxPerGame = 2
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
    return #PlayersModule.deadPlayers >= 1
end

local function onEventVariant()
    -- Revive random player
    local randomPlayer = PlayersModule.pickOnePlayer(PlayersModule.deadPlayers)

    PlayersModule.runNewPromisePerAll(function(player, protect, await)
        if player == randomPlayer then
            await(TextModule.showTextSequence(player, {
                { key = "intro_random", delay = 6 },
                { key = "you_are_revived", delay = 6 },
            }))
            PlayersModule.revive(player)
        else
            await(TextModule.showTextSequence(player, {
                { key = "intro_random", delay = 6 },
                { key = "player_revived", delay = 6, data = { player = randomPlayer } },
            }))
        end
    end):catch(error):await()
end

function Event.onEvent()
    if math.random() < 0.25 or #PlayersModule.deadPlayers < 3 then
        return onEventVariant()
    end

    -- Vote variant
    local amount
    if #PlayersModule.deadPlayers > 5 then
        amount = 4
    elseif #PlayersModule.deadPlayers > 4 then
        amount = 3
    else
        amount = 2
    end

    local playersForVote = PlayersModule.pickPlayers(amount, PlayersModule.deadPlayers)
    MiscModule.addHighlightTo(playersForVote)

    PlayersModule.runPromisePerAll(function(player, protect)
        if table.find(playersForVote, player) then
            return protect(TextModule.showTextSequence(player, {
                { key = "intro_vote_common", delay = 5 },
                { key = "intro_vote_candidate", delay = 5 },
            }))
        elseif table.find(PlayersModule.deadPlayers, player) then
            return protect(TextModule.showTextSequence(player, {
                { key = "intro_vote_common", delay = 5 },
                { key = "intro_dead_not_you", delay = 5 },
            }))
        else
            return protect(TextModule.showTextSequence(player, {
                { key = "intro_vote_common", delay = 5 },
                { key = "intro_choose_wise", delay = 5 },
            }))
        end
    end):await()

    TimerModule.setTime(25)

    PlayersModule.runFuncPerAlive(function(player)
        if not table.find(playersForVote, player) then
            local buttons: IndicesType.Indices = {}
            for i, playerForVote in ipairs(playersForVote) do
                table.insert(buttons, { idx = i, text = playerForVote.DisplayName })
            end
            ButtonsModule.setButtons(player, buttons)
        end
    end)

    local _, result = ButtonsModule.initiateButtonChoice(25):catch(error):await()

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

    PlayersModule.runFuncPerAll(function(player: Player)
        if player == mostVotedPlayer then
            TextModule.setText(player, "you_are_revived")
            PlayersModule.revive(player)
        else
            TextModule.setText(player, "player_revived", { player = mostVotedPlayer })
        end
    end)
    task.wait(5)

    return
end

return Event