--!strict
--!optimize 2

-- Description:
-- Players will have to repeat the combo shown to them
-- The combo will get longer each round
-- Players with the most mistakes will be eliminated

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Arena = game:GetService("ServerScriptService").Server.Arena
local IndicesType = require(ReplicatedStorage.Shared.IndicesType)
local GameState = require(Arena.GameStateModule)
local EventTypeModule = require(Arena.Events.EventType)
local TextModule = require(Arena.TextModule)
local ButtonsModule = require(Arena.ButtonsModule)

type EventType = EventTypeModule.Event

local COMBO_COUNT = 5
local ROUND_COMBO_LENGTH = {
    [1] = 3,
    [2] = 4,
    [3] = 4,
    [4] = 5,
    [5] = 6
}

local Event = {} :: EventType

Event.chance = 0.05
Event.minPlayers = 5
Event.maxPerGame = 2
Event.minRound = 2

function Event.check()
    return true
end

local function disableInput(player: Player)
    local indices: IndicesType.Indices = {}

    for i = 1, 4 do
        table.insert(indices, { idx = i, inputDisabled = true })
    end

    ButtonsModule.updateButtons(player, indices)
end

local function enableInput(player: Player)
    local indices: IndicesType.Indices = {}

    for i = 1, 4 do
        table.insert(indices, { idx = i, inputDisabled = false })
    end

    ButtonsModule.updateButtons(player, indices)
end

local function disableAllBtnExcept(player: Player, idx: number)
    local indices: IndicesType.Indices = {}

    for i = 1, 4 do
        table.insert(indices, { idx = i, disabled = idx ~= i })
    end

    ButtonsModule.updateButtons(player, indices)
end

local function enableAllBtn(player: Player)
    local indices: IndicesType.Indices = {}

    for i = 1, 4 do
        table.insert(indices, { idx = i, disabled = false })
    end

    ButtonsModule.updateButtons(player, indices)
end

function Event.onEvent()
    GameState.runFuncPerDead(function(player)
        TextModule.setText(player, "They're doing combos now, three players will be eliminated")
    end)

    GameState.runPromisePerAlive(function(player, protect)
        return protect(TextModule.showTextSequence(player, {
            { text = "Now you will have to repeat after me", delay = 4 },
            { text = "Players with the highest amount of mistakes will be eliminated", delay = 5 },
            { text = "And now we start", delay = 3 },
        }))
    end):catch(error):await()

    GameState.runFuncPerAlive(function(player)
        ButtonsModule.setButtons(player, {
            { idx = 1 },
            { idx = 2 },
            { idx = 3 },
            { idx = 4 },
        })
    end)

    local mistakes: { [Player]: number } = {}

    GameState.runNewPromisePerAlive(function(player, protect, await)
        for round = 1, COMBO_COUNT do
            local combo: {number} = {}
            for i = 1, ROUND_COMBO_LENGTH[round] do
                local lastIdx = combo[i - 1]
                local nextIdx = nil

                while nextIdx == nil or nextIdx == lastIdx do
                    nextIdx = math.random(1, 4)
                end

                table.insert(combo, nextIdx)
            end

            TextModule.setText(player, "My turn")
            enableAllBtn(player)
            disableInput(player)
            task.wait(2)
            for i, idx in ipairs(combo) do
                TextModule.setText(player, tostring(i))
                disableAllBtnExcept(player, idx)
                task.wait(1)
            end

            TextModule.setText(player, "Your turn")
            enableAllBtn(player)
            task.wait(2)

            for i, idx in ipairs(combo) do
                enableInput(player)
                enableAllBtn(player)

                TextModule.setText(player, tostring(i))
                local clicked = await(ButtonsModule.waitForClick(player, 10))

                if not clicked then
                    TextModule.setText(player, "You didn't click anything")
                    GameState.kill(player)
                    return
                end

                if clicked ~= idx then
                    local mistakeCount = mistakes[player] or 0
                    mistakes[player] = mistakeCount + 1
                end

                disableInput(player)
                disableAllBtnExcept(player, clicked or 0)
                task.wait(1)
            end
        end
        TextModule.setText(player, "Let's wait for others to finish")
        task.wait(2)
    end):catch(error):await()

    local toCount = {}
    for player, mistakeCount in pairs(mistakes) do
        if mistakeCount > 0 then
            table.insert(toCount, { player = player, mistakes = mistakeCount })
        end
    end

    table.sort(toCount, function(a, b)
        return a.mistakes > b.mistakes
    end)

    local toKill = {}
    local toKillCount: number

    if #GameState.alivePlayers >= 15 then
        toKillCount = 3
    elseif #GameState.alivePlayers >= 5 then
        toKillCount = 2
    else
        toKillCount = 1
    end

    for i, info in ipairs(toCount) do
        if i > toKillCount then
            break
        end
        table.insert(toKill, info.player)
    end

    GameState.runNewPromisePerAlive(function(player, protect, await)
        await(TextModule.showTextSequence(player, {
            { text = "You have " .. mistakes[player] .. " mistakes...", delay = 2 },
            { text = "Let's see what we got here", delay = 3 }
        }))

        if table.find(toKill, player) then
            TextModule.setText(player, "You are the one of people who are eliminated")
            GameState.kill(player)
        else
            TextModule.setText(player, "You survived")
        end
        task.wait(5)
    end):catch(error):await()

    return
end

return Event