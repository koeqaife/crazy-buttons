--!strict
--!optimize 2

-- Description:
-- A game like "Rock, Paper, Scissors"
-- Two players are chosen to play
-- Attack beats Trust, Defend beats Attack, Trust beats Defend
-- The loser is eliminated

local Arena = game:GetService("ServerScriptService").Server.Arena
local TimerModule = require(Arena.TimerModule)
local GameState = require(Arena.GameStateModule)
local EventTypeModule = require(Arena.Events.EventType)
local TextModule = require(Arena.TextModule)
local ButtonsModule = require(Arena.ButtonsModule)

type EventType = EventTypeModule.Event

local Event = {} :: EventType

local buttons = {  -- DO NOT USE IN setButtons!!!
    { idx = 1, text = "Attack" },
    { idx = 2, text = "Defend" },
    { idx = 3, text = "Trust" }
}

local colors = {
    Color3.new(0.95, 0.21, 0.21),
    Color3.new(0, 0.35, 1),
    Color3.new(1, 0.14, 0.81)
}

local beats = {
    [1] = 3, -- Attack beats Trust
    [2] = 1, -- Defend beats Attack
    [3] = 2  -- Trust beats Defend
}

local beatsText = {
    [1] = {
        [2] = "They defended against your attack",
        [3] = "They trusted too much and got attacked"
    },
    [2] = {
        [1] = "You defended against their attack",
        [3] = "They trusted you and you tried to defend, you're eliminated"
    },
    [3] = {
        [1] = "You got attacked while trying to trust",
        [2] = "They didn't seem to trust you and tried to defend, they're eliminated"
    }
}

Event.chance = 0.05
Event.minPlayers = 2

function Event.check()
    return true
end

function Event.onEvent()
    local randomPlayers = GameState.pickPlayers(2)

    local p1 = randomPlayers[1]
    local p2 = randomPlayers[2]

    GameState.addHighlightTo({p1, p2})
    GameState.runPromisePerAlive(function(player, protect)
        if player == p1 or player == p2 then
            local otherPlayer = if player == p1 then p2 else p1

            return protect(TextModule.showTextSequence(player, {
                { text = "You and " .. otherPlayer.Name .. " have been chosen to play Attack, Defend, Trust", delay = 4 },
                { text = "Rules are simple", delay = 3 },
                { text = "Attack beats Trust, Defend beats Attack, Trust beats Defend", delay = 5 },
                { text = "The loser will be eliminated", delay = 4 },
            }))
        else
            return protect(TextModule.showTextSequence(player, {
                { text = p1.Name .. " and " .. p2.Name .. " have been chosen to play Attack, Defend, Trust", delay = 4 },
                { text = "Rules are simple", delay = 3 },
                { text = "Attack beats Trust, Defend beats Attack, Trust beats Defend", delay = 5 },
                { text = "The loser will be eliminated", delay = 4 },
            }))
        end
    end):await()

    for attempt = 1, 6 do
        GameState.removeHighlightFromAll()
        GameState.addHighlightTo({p1, p2})

        GameState.runFuncPerAlive(function(player)
            if player == p1 or player == p2 then
                ButtonsModule.setButtons(player, {})
                ButtonsModule.setButtons(player, {
                    { idx = 1, text = "Attack" },
                    { idx = 2, text = "Defend" },
                    { idx = 3, text = "Trust" }
                })
                TextModule.setText(player, "Choose your move")
            else
                TextModule.setText(player, "Waiting for " .. randomPlayers[1].Name .. " and " .. randomPlayers[2].Name .. " to choose their move...")
            end
        end)

        TimerModule.setTime(15)
        local _, chosen = ButtonsModule.initiateButtonChoice(15):catch(error):await()

        if chosen[p1] == nil and chosen[p2] == nil then
            GameState.runFuncPerAlive(function(player)
                TextModule.setText(player, "Both players did not move")
            end)
            GameState.kill(p1)
            GameState.kill(p2)
            break
        elseif chosen[p1] == nil then
            chosen[p1] = 3
        elseif chosen[p2] == nil then
            chosen[p2] = 3
        end

        GameState.removeHighlightFromAll()
        GameState.addHighlightToOne(p1, colors[chosen[p1]])
        GameState.addHighlightToOne(p2, colors[chosen[p2]])
        task.wait(2)

        if chosen[p1] == chosen[p2] then
            GameState.runPromisePerAlive(function(player, protect)
                if player == p1 or player == p2 then
                    return protect(TextModule.showTextSequence(player, {
                        { text = "You both chose " .. buttons[chosen[player]].text, delay = 4 },
                        { text = "It's a tie, choose again", delay = 4 },
                    }))
                else
                    return protect(TextModule.showTextSequence(player, {
                        { text = p1.Name .. " and " .. p2.Name .. " both chose " .. buttons[chosen[p1]].text, delay = 4 },
                        { text = "It's a tie, they will choose again", delay = 4 },
                    }))
                end
            end):await()
        else
            local winner = chosen[p1]
            local loser = chosen[p2]

            if beats[winner] == loser then
                TextModule.setText(p1, beatsText[winner][loser])
                TextModule.setText(p2, beatsText[loser][winner])
                GameState.runFuncPerAlive(function(player)
                    if player ~= p1 and player ~= p2 then
                        TextModule.setText(player, p1.Name .. " won against " .. p2.Name)
                    end
                end)
                task.wait(4)
                GameState.kill(p2)
                break
            else
                TextModule.setText(p2, beatsText[winner][loser])
                TextModule.setText(p1, beatsText[loser][winner])
                GameState.runFuncPerAlive(function(player)
                    if player ~= p1 and player ~= p2 then
                        TextModule.setText(player, p2.Name .. " won against " .. p1.Name .. "!")
                    end
                end)
                task.wait(4)
                GameState.kill(p2)
                break
            end
        end
    end

    return
end

return Event