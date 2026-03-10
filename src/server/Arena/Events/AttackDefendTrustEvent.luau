--!strict
--!optimize 2

local Arena = game:GetService("ServerScriptService").Server.Arena
local TimerModule = require(Arena.TimerModule)
local GameState = require(Arena.GameStateModule)
local EventTypeModule = require(Arena.Events.EventType)
local TextModule = require(Arena.TextModule)
local ButtonsModule = require(Arena.ButtonsModule)

type EventType = EventTypeModule.Event

local Event = {} :: EventType
Event.category = "social"
Event.name = "att_def_trust"

local buttons = {
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

Event.chance = 0.075
Event.minPlayers = 2

function Event.check()
    return true
end

function Event.onEvent()
    local randomPlayers = GameState.pickPlayers(2)

    local p1 = randomPlayers[1]
    local p2 = randomPlayers[2]

    GameState.runFuncPerDead(function(player)
        TextModule.setText(player, p1.DisplayName .. " and " .. p2.DisplayName .. " are playing Attack, Defend, Trust", "att_def_tru_icon")
    end)

    GameState.addHighlightTo({p1, p2})
    GameState.runPromisePerAlive(function(player, protect)
        if player == p1 or player == p2 then
            local otherPlayer = if player == p1 then p2 else p1

            return protect(TextModule.showTextSequence(player, {
                { text = "You and " .. otherPlayer.DisplayName .. " have been chosen to play Attack, Defend, Trust", delay = 5, face = "att_def_tru_icon" },
                { text = "Rules are simple", delay = 4, face = "happy" },
                { text = "Attack beats Trust, Defend beats Attack, Trust beats Defend", delay = 7, face = "nerd" },
                { text = "The loser will be eliminated", delay = 5, face = "dead" },
            }))
        else
            return protect(TextModule.showTextSequence(player, {
                { text = p1.DisplayName .. " and " .. p2.DisplayName .. " have been chosen to play Attack, Defend, Trust", delay = 5, face = "att_def_tru_icon" },
                { text = "Rules are simple", delay = 4, face = "happy" },
                { text = "Attack beats Trust, Defend beats Attack, Trust beats Defend", delay = 7, face = "nerd" },
                { text = "The loser will be eliminated", delay = 5, face = "dead" },
            }))
        end
    end):await()

    for attempt = 1, 6 do
        GameState.removeHighlightFromAll()
        GameState.addHighlightTo({p1, p2})

        GameState.runFuncPerAll(function(player)
            if player == p1 or player == p2 then
                ButtonsModule.setButtons(player, {})
                ButtonsModule.setButtons(player, {
                    { idx = 1, text = "Attack" },
                    { idx = 2, text = "Defend" },
                    { idx = 3, text = "Trust" }
                })
                TextModule.setText(player, "Choose your move", "normal")
            else
                TextModule.setText(player, "Waiting for " .. randomPlayers[1].DisplayName .. " and " .. randomPlayers[2].DisplayName .. " to choose their move...", "normal")
            end
        end)

        TimerModule.setTime(15)
        local _, chosen = ButtonsModule.initiateButtonChoice(15, nil, nil, nil, nil, {p1, p2}):catch(error):await()
        TimerModule.setTime(-1)

        if chosen[p1] == nil and chosen[p2] == nil then
            GameState.runFuncPerAll(function(player)
                TextModule.setText(player, "Both players did not move", "dead")
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
            GameState.runPromisePerAll(function(player, protect)
                if player == p1 or player == p2 then
                    return protect(TextModule.showTextSequence(player, {
                        { text = "You both chose " .. buttons[chosen[player]].text, delay = 4, face = "laughing" },
                        { text = "It's a tie, choose again", delay = 4, face = "shy" },
                    }))
                else
                    return protect(TextModule.showTextSequence(player, {
                        { text = p1.DisplayName .. " and " .. p2.DisplayName .. " both chose " .. buttons[chosen[p1]].text, delay = 4, face = "laughing" },
                        { text = "It's a tie, they will choose again", delay = 4, face = "shy" },
                    }))
                end
            end):await()
        else
            local c1 = chosen[p1]
            local c2 = chosen[p2]

            if beats[c1] == c2 then
                TextModule.setText(p1, beatsText[c1][c2], "happy")
                TextModule.setText(p2, beatsText[c2][c1], "dead")
                GameState.runFuncPerAll(function(player)
                    if player ~= p1 and player ~= p2 then
                        TextModule.setText(player, p1.DisplayName .. " won against " .. p2.DisplayName, "happy")
                    end
                end)
                task.wait(4)
                GameState.addRewardTo(p1, 7)
                GameState.kill(p2)
                break
            else
                TextModule.setText(p2, beatsText[c2][c1], "happy")
                TextModule.setText(p1, beatsText[c1][c2], "dead")
                GameState.runFuncPerAll(function(player)
                    if player ~= p1 and player ~= p2 then
                        TextModule.setText(player, p2.DisplayName .. " won against " .. p1.DisplayName .. "!", "happy")
                    end
                end)
                task.wait(4)
                GameState.addRewardTo(p2, 7)
                GameState.kill(p1)
                break
            end
        end
    end

    return
end

return Event