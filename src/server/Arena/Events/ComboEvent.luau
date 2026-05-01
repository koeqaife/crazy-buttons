--!strict
--!optimize 2

-- Description:
-- Players will have to repeat the combo shown to them
-- The combo will get longer each round
-- Players with the most mistakes will be eliminated

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local Arena = game:GetService("ServerScriptService").Server.Arena
local PlayersModule = require(ServerScriptService.Server.Arena.PlayersModule)
local RewardsModule = require(ServerScriptService.Server.Arena.RewardsModule)
local DataStoreModule = require(ServerScriptService.Server.Shared.DataStoreModule)
local IndicesType = require(ReplicatedStorage.Shared.IndicesType)
local EventTypeModule = require(Arena.Events.EventType)
local TextModule = require(Arena.TextModule)
local ButtonsModule = require(Arena.ButtonsModule)

local logAction = require(ServerScriptService.Server.Shared.QuestsModule).logAction

type EventType = EventTypeModule.Event

local BADGE_ID = 3143538501927930
local COMBO_COUNT = 5
local ROUND_COMBO_LENGTH = {
    [1] = 3,
    [2] = 4,
    [3] = 4,
    [4] = 5,
    [5] = 6
}

local Event = {} :: EventType

Event.name = "combo"
Event.category = "reaction"
Event.chance = 0.1
Event.minPlayers = 5
Event.maxPerGame = 2
Event.minRound = 2
local COLOR_NAMES = { "Red", "Blue", "Pink", "Yellow" }

function Event.check()
    return true
end

local function disableInput(player: Player)
    local indices: IndicesType.Indices = {}

    for i = 1, 4 do
        table.insert(indices, { idx = i, inputDisabled = true, onViewportFrame = true })
    end

    ButtonsModule.updateButtons(player, indices)
end

local function enableInput(player: Player)
    local indices: IndicesType.Indices = {}

    for i = 1, 4 do
        table.insert(indices, { idx = i, inputDisabled = false, onViewportFrame = false })
    end

    ButtonsModule.updateButtons(player, indices)
end
local function disableAllBtnExcept(player: Player, idx: number)
    local indices: IndicesType.Indices = {}

    for i = 1, 4 do
        table.insert(
            indices,
            {
                idx = i,
                disabled = idx ~= i,
                text = if idx ~= i then "" else COLOR_NAMES[i]
            }
        )
    end

    ButtonsModule.updateButtons(player, indices)
end

local function enableAllBtn(player: Player)
    local indices: IndicesType.Indices = {}

    for i = 1, 4 do
        table.insert(indices, { idx = i, disabled = false, text = COLOR_NAMES[i] })
    end

    ButtonsModule.updateButtons(player, indices)
end

function Event.onEvent()
    PlayersModule.runFuncPerDead(function(player)
        TextModule.setText(player, "for_dead")
    end)

    PlayersModule.runFuncPerAlive(function(player)
        ButtonsModule.setButtons(player, {
            { idx = 1, text = COLOR_NAMES[1], inputDisabled = true, onViewportFrame = true },
            { idx = 2, text = COLOR_NAMES[2], inputDisabled = true, onViewportFrame = true },
            { idx = 3, text = COLOR_NAMES[3], inputDisabled = true, onViewportFrame = true },
            { idx = 4, text = COLOR_NAMES[4], inputDisabled = true, onViewportFrame = true },
        })
    end)

    PlayersModule.runPromisePerAlive(function(player, protect)
        return protect(TextModule.showTextSequence(player, {
            { key = "repeat_after_me", delay = 6 },
            { key = "players_to_eliminate", delay = 7 },
            { key = "lets_start", delay = 3 },
        }))
    end):catch(error):await()

    local mistakes: { [Player]: number } = {}

    PlayersModule.runNewPromisePerAlive(function(player, protect, await)
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

            TextModule.setText(player, "my_turn")
            enableAllBtn(player)
            disableInput(player)
            task.wait(2)
            for i, idx in ipairs(combo) do
                disableAllBtnExcept(player, idx)
                task.wait(1)
            end

            TextModule.setText(player, "your_turn")
            enableAllBtn(player)
            task.wait(2)

            for i, idx in ipairs(combo) do
                enableInput(player)
                enableAllBtn(player)

                TextModule.setText(player, "clicks_left", {num = tostring(#combo - i + 1)})
                local clicked = await(ButtonsModule.waitForClick(player, 7.5))

                if not clicked then
                    local mistakeCount = mistakes[player] or 0
                    mistakes[player] = mistakeCount + (#combo - i)
                    break
                end

                if clicked ~= idx then
                    local mistakeCount = mistakes[player] or 0
                    mistakes[player] = mistakeCount + 1
                    logAction(player, "combo_mistake")
                else
                    -- If all 27 are without mistakes gonna be 14 (ceil of 13.5)
                    RewardsModule.addRewardTo(player, 0.5)
                end

                disableInput(player)
                disableAllBtnExcept(player, clicked or 0)
                task.wait(0.25)
            end
        end
        TextModule.setText(player, "wait")
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

    local toKill = toCount[1].player

    PlayersModule.runNewPromisePerAlive(function(player, protect, await)
        await(TextModule.showTextSequence(player, {
            { key = "mistakes_count", delay = 3, data = {num = tostring(mistakes[player] or 0)} },
            { key = "lets_see", delay = 4 }
        }))
        -- For everyone who played, even if they died
        RewardsModule.addRewardTo(player, 3)

        if player == toKill then
            TextModule.setText(player, "you_eliminated")
            PlayersModule.kill(player)
        else
            if (mistakes[player] or 0) == 0 then
                logAction(player, "perfect_combo")
                local owns = DataStoreModule.getTable(player, "owns")
                if owns ~= nil and not table.find(owns, "dangerousAura") then
                    DataStoreModule.mergeKey(player, "owns", {"dangerousAura"})
                end
                RewardsModule.rewardBadge(player, BADGE_ID):catch(warn)
            end
            TextModule.setText(player, "you_survived")
        end
        task.wait(5)
    end):catch(error):await()

    return
end

return Event