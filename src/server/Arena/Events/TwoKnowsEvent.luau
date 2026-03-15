--!strict
--!optimize 2
local ServerScriptService = game:GetService("ServerScriptService")

-- Description:
-- Two person are chosen, one will get a button that can save themselves, the other will get a button that can kill themselves
-- They have to convince others to press their button

local Arena = game:GetService("ServerScriptService").Server.Arena
local TimerModule = require(ServerScriptService.Server.Arena.TimerModule)
local GameState = require(Arena.GameStateModule)
local EventTypeModule = require(Arena.Events.EventType)
local TextModule = require(Arena.TextModule)
local ButtonsModule = require(Arena.ButtonsModule)

local logAction = require(ServerScriptService.Server.Shared.QuestsModule).logAction

type EventType = EventTypeModule.Event

local Event = {} :: EventType

local firstIdxColor = Color3.new(0.95, 0.21, 0.21)
local secondIdxColor = Color3.new(0, 0.35, 1)

Event.name = "two_knows"
Event.category = "social"
Event.chance = 0.09
Event.minPlayers = 4
Event.maxPerGame = 2

function Event.check()
    return true
end

function Event.onEvent()
    local randomPlayers = GameState.pickPlayers(2)

    local kills = math.random(1, 2)
    local p1 = randomPlayers[1]
    local p2 = randomPlayers[2]
    local playerKills = if kills == 1 then p1 else p2
    local playerSaves = if kills == 1 then p2 else p1

    GameState.runPromisePerAll(function(player, protect, await)
        if player == playerKills then
            return protect(TextModule.showTextSequence(player, {
                { key = "intro_killer_1", delay = 5 },
                { key = "intro_killer_2", delay = 6 },
                { key = "intro_killer_3", delay = 6 },
            }))
        elseif player == p1 or player == p2 then
            return protect(TextModule.showTextSequence(player, {
                { key = "intro_saver_1", delay = 5 },
                { key = "intro_saver_2", delay = 6 },
                { key = "intro_saver_3", delay = 6 },
            }))
        else
            return protect(TextModule.showTextSequence(player, {
                { key = "intro_others_1", delay = 5, data = { p1 = p1, p2 = p2 } },
                { key = "intro_others_2", delay = 6 },
                { key = "intro_others_3", delay = 6 },
            }))
        end
    end):catch(error):await()

    GameState.addHighlightToOne(p1, firstIdxColor, firstIdxColor)
    GameState.addHighlightToOne(p2, secondIdxColor, secondIdxColor)

    GameState.runFuncPerAlive(function(player)
        local disableInput = player == p1 or player == p2 or table.find(GameState.alivePlayers, player) == nil
        ButtonsModule.setButtons(player, {
            { idx = 1, text = p1.DisplayName, inputDisabled = disableInput },
            { idx = 2, text = p2.DisplayName, inputDisabled = disableInput },
        }, nil, false)
    end)

    TimerModule.setTime(30)
    local _, chosen = ButtonsModule.initiateButtonChoice(30, function(player, idx)
        local disableInput = player == p1 or player == p2 or table.find(GameState.alivePlayers, player) == nil
        if disableInput then
            return false
        end
        return true
    end, function(player, idx)
        GameState.removeHighlightFromOne(player)
        if idx == 1 then
            GameState.addHighlightToOne(player, firstIdxColor, firstIdxColor)
        elseif idx == 2 then
            GameState.addHighlightToOne(player, secondIdxColor, secondIdxColor)
        end
    end):catch(error):await()

    GameState.runFuncPerAlive(function(player)
        ButtonsModule.setButtons(player, {})
    end)

    GameState.runNewPromisePerAlive(function(player, protect, await)
        GameState.addRewardTo(player, 5)
        if player == p1 or player == p2 then
            return TextModule.setText(player, "lets_see")
        end

        local choice = chosen[player]
        if choice == nil then
            TextModule.setText(player, "result_no_choice")
            GameState.kill(player)
        else
            local chosenPlayer = if choice == 1 then p1 else p2
            if choice == kills then
                TextModule.setText(player, "result_chose_died", { p = chosenPlayer })
                GameState.kill(player)
                logAction(playerKills, "two_knows_kills")
            else
                TextModule.setText(player, "result_chose_safe", { p = chosenPlayer })
                logAction(playerSaves, "two_knows_save")
            end
        end
    end):catch(error):await()
    task.wait(6)

    return
end

return Event