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

    GameState.runPromisePerAll(function(player, protect, await)
        if player == playerKills then
            return protect(TextModule.showTextSequence(player, {
                { text = "You got a button that kills", delay = 5, face = "shy" },
                { text = "Everybody who clicks it, dies", delay = 5, face = "scared" },
                { text = "Try to convince others to click it for you", delay = 6, face = "normal" },
            }))
        elseif player == p2 or player == p1 then
            return protect(TextModule.showTextSequence(player, {
                { text = "You got a button that saves", delay = 5, face = "shy" },
                { text = "Everybody who clicks it, is saved", delay = 5, face = "happy" },
                { text = "Try to convince others to click it for you", delay = 6, face = "normal" },
            }))
        else
            return protect(TextModule.showTextSequence(player, {
                { text = "You have to talk with " .. p1.DisplayName .. " and " .. p2.DisplayName, delay = 5, face = "shy" },
                { text = "One of them has a button that kills you", delay = 6, face = "normal" },
                { text = "So who do you believe?", delay = 5, face = "nerd" },
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
            return TextModule.setText(player, "Let's see who died...")
        end

        local resultText
        local kill
        if chosen[player] == nil then
            resultText = "You didn't choose a button, you died"
            kill = true
        elseif chosen[player] == kills then
            resultText = "You chose " .. p1.DisplayName .. "'s button, you died"
            kill = true
        else
            resultText = "You chose " .. p2.DisplayName .. "'s button, you are safe"
            kill = false
        end

        TextModule.setText(player, resultText)

        if kill then
            GameState.kill(player)
        end
    end):catch(error):await()
    task.wait(6)

    return
end

return Event