--!strict
--!optimize 2

-- Description:
-- Event where one random player is gonna be revived
-- With 1/4 chance or if deadPlayers count is less than 3, it's gonna revive random player
-- Otherwise there is gonna vote with which player people wanna revive

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
    return #GameState.deadPlayers >= 1
end

local function onEventVariant()
    -- Revive random player
    local randomPlayer = GameState.pickOnePlayer(GameState.deadPlayers)

    GameState.runNewPromisePerAll(function(player, protect, await)
        if player == randomPlayer then
            await(TextModule.showTextSequence(player, {
                { text = "Someone random will be revived now", delay = 5, face = "shy" },
                { text = "You were revived!", delay = 5, face = "happy" },
            }))
            GameState.revive(player)
        else
            await(TextModule.showTextSequence(player, {
                { text = "Someone random will be revived now", delay = 5, face = "shy" },
                { text = "Player " .. randomPlayer.Name .. " was revived", delay = 5, face = "happy" },
            }))
        end
    end):catch(error):await()
end

function Event.onEvent()
    if math.random() < 0.25 or #GameState.deadPlayers < 3 then
        return onEventVariant()
    end

    -- Pretty much the copy of VoteEvent

    local amount
    if #GameState.deadPlayers > 5 then
        amount = 4
    elseif #GameState.deadPlayers > 4 then
        amount = 3
    else
        amount = 2
    end

    local playersForVote = GameState.pickPlayers(amount, GameState.deadPlayers)
    GameState.addHighlightTo(playersForVote)

    GameState.runPromisePerAll(function(player, protect)
        if table.find(playersForVote, player) then
            return protect(TextModule.showTextSequence(player, {
                { text = "Someone will be revived now", delay = 3, face = "shy" },
                { text = "Other players will decide if that's you...", delay = 4, face = "shy" },
            }))
        elseif table.find(GameState.deadPlayers, player) then
            return protect(TextModule.showTextSequence(player, {
                { text = "Someone will be revived now", delay = 3, face = "shy" },
                { text = "But not you, sadly...", delay = 4, face = "no_mouth" },
            }))
        else
            return protect(TextModule.showTextSequence(player, {
                { text = "Someone will be revived now", delay = 3, face = "shy" },
                { text = "Choose wisely who should be revived", delay = 4, face = "nerd" },
            }))
        end
    end):await()

    TimerModule.setTime(25)

    GameState.runFuncPerAlive(function(player)
        if not table.find(playersForVote, player) then
            local buttons: IndicesType.Indices = {}
            for i, playerForVote in ipairs(playersForVote) do
                table.insert(buttons, { idx = i, text = playerForVote.Name })
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

    GameState.runFuncPerAll(function(player: Player)
        if player == mostVotedPlayer then
            TextModule.setText(player, "You were revived!", "happy")
            GameState.revive(player)
        else
            TextModule.setText(player, "Player " .. mostVotedPlayer.Name .. " was revived", "happy")
        end
    end):await()
    task.wait(5)

    return
end

return Event