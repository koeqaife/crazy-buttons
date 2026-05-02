--!strict
--!optimize 2

-- Description:
-- from 2 to 4 players are gonna be voted
-- The one with highest amount of votes dies

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local Arena = game:GetService("ServerScriptService").Server.Arena
local IconModule = require(ServerScriptService.Server.Arena.IconModule)
local MiscModule = require(ServerScriptService.Server.Arena.MiscModule)
local PlayersModule = require(ServerScriptService.Server.Arena.PlayersModule)
local RewardsModule = require(ServerScriptService.Server.Arena.RewardsModule)
local IndicesType = require(ReplicatedStorage.Shared.IndicesType)
local EventTypeModule = require(Arena.Events.EventType)
local TextModule = require(Arena.TextModule)
local ButtonsModule = require(Arena.ButtonsModule)
local TimerModule = require(Arena.TimerModule)

type EventType = EventTypeModule.Event

local Event = {} :: EventType

Event.name = "vote"
Event.category = "social"
Event.chance = 0.1
Event.minRound = 2
Event.maxPerGame = 7
Event.minPlayers = 3

local iconsArrow = {
    "rbxassetid://73836240759936",  -- red
    "rbxassetid://94482221000405",  -- blue
    "rbxassetid://87641409463283",  -- pink
    "rbxassetid://72327863886531",  -- yellow
}

local iconsKill = {
    "rbxassetid://116467828523943", -- red
    "rbxassetid://132494941969982", -- blue
    "rbxassetid://81605219273054",  -- pink
    "rbxassetid://114734242707416", -- yellow
}

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
    local amount
    if #PlayersModule.alivePlayers > 10 then
        amount = 3
    else
        amount = 2
    end

    local playersForVote = PlayersModule.pickPlayers(amount)
    local guiSpace = IconModule.reserveSpace(1, "event")

    PlayersModule.runFuncPerDead(function(player)
        TextModule.setText(player, "dead_intro")
    end)

    PlayersModule.runPromisePerAlive(function(player, protect)
        if table.find(playersForVote, player) then
            return protect(TextModule.showTextSequence(player, {
                { key = "intro_common_1", delay = 5 },
                { key = "intro_candidate_fate", delay = 3 },
            }))
        else
            return protect(TextModule.showTextSequence(player, {
                { key = "intro_common_1", delay = 5 },
                { key = "intro_choose_wise", delay = 3 },
            }))
        end
    end):catch(error):await()

    TimerModule.setTime(30)

    local votingPromise = ButtonsModule.initiateButtonChoice(
        30,
        function(player, idx)
            return table.find(PlayersModule.alivePlayers, player) ~= nil and table.find(playersForVote, player) == nil
        end,
        function(player, idx)
            MiscModule.removeHighlightFromOne(player)
            if idx ~= nil then
                guiSpace.addIcon(player, "kill", iconsKill[idx])
                MiscModule.addHighlightToOne(player, highlightColors[idx])
            else
                guiSpace.removeIcon(player, "kill")
            end
        end, nil, true
    )

    PlayersModule.runNewPromisePerAlive(function(player, protect, await)
        local playerOnVote = table.find(playersForVote, player) ~= nil

        local buttons: IndicesType.Indices = {}
        for i, playerForVote in ipairs(playersForVote) do
            table.insert(buttons, { idx = i, text = playerForVote.DisplayName, inputDisabled = playerOnVote })

            local color = highlightColors[i]
            guiSpace.addIcon(playerForVote, "arrow", iconsArrow[i])
            MiscModule.addHighlightToOne(playerForVote, color, color)
        end

        ButtonsModule.setButtons(player, buttons, false)

        if playerOnVote then
            TextModule.setToast(player, "People vote for who to eliminate", 5)
            await(TextModule.showTextSequence(player, {
                { key = "candidate_line_1", delay = 4 },
                { key = "candidate_line_2", delay = 4 },
                { key = "candidate_line_3", delay = 5 },
                { key = "candidate_line_4", delay = 4 },
                { key = "candidate_line_5", delay = 5 },
                { key = "candidate_line_6", delay = 4 },
                { key = "candidate_line_7", delay = 4 },
            }))
        end
    end)

    local _, result = votingPromise:catch(error):await()
    guiSpace.destroy()

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

    PlayersModule.runFuncPerAlive(function(player)
        RewardsModule.addRewardTo(player, 3)
    end)

    PlayersModule.runFuncPerAll(function(player: Player)
        if player == mostVotedPlayer then
            TextModule.setText(player, "you_eliminated")
            PlayersModule.kill(player)
        else
            TextModule.setText(player, "player_eliminated", { player = mostVotedPlayer })
        end
    end)
    task.wait(8)

    return
end

return Event