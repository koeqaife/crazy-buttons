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
        [2] = "att_def",
        [3] = "att_trust"
    },
    [2] = {
        [1] = "def_att",
        [3] = "def_trust"
    },
    [3] = {
        [1] = "trust_att",
        [2] = "trust_def"
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
        TextModule.setText(player, "chosen_players", {p1 = p1, p2 = p2})
    end)

    GameState.addHighlightTo({p1, p2})
    GameState.runPromisePerAlive(function(player, protect)
        if player == p1 or player == p2 then
            local otherPlayer = if player == p1 then p2 else p1

            return protect(TextModule.showTextSequence(player, {
                { key = "chosen_players", delay = 5, data = {p1 = "You", p2 = otherPlayer} },
                { key = "rules_are_simple", delay = 4, face = "happy" },
                { key = "rules", delay = 7 },
                { key = "loser_eliminate", delay = 5 },
            }))
        else
            return protect(TextModule.showTextSequence(player, {
                { key = "chosen_players", delay = 5, data = {p1 = p1, p2 = p2} },
                { key = "rules_are_simple", delay = 4 },
                { key = "rules", delay = 7 },
                { key = "loser_eliminate", delay = 5 },
            }))
        end
    end):await()

    for attempt = 1, 6 do
        GameState.removeHighlightFromAll()
        GameState.addHighlightTo({p1, p2})

        GameState.runFuncPerAlive(function(player)
            local inputEnabled = player == p1 or player == p2
            ButtonsModule.setButtons(player, {})
            ButtonsModule.setButtons(player, {
                { idx = 1, text = "Attack", inputDisabled = not inputEnabled },
                { idx = 2, text = "Defend", inputDisabled = not inputEnabled },
                { idx = 3, text = "Trust", inputDisabled = not inputEnabled }
            }, nil, false)

            if player == p1 or player == p2 then
                TextModule.setText(player, "choose_your_move")
            end
        end)
        GameState.runFuncPerAll(function(player)
            if not (player == p1 or player == p2) then
                TextModule.setText(player, "waiting_for_move", {p1 = p1, p2 = p2})
            end
        end)

        TimerModule.setTime(15)
        local _, chosen = ButtonsModule.initiateButtonChoice(15, nil, nil, nil, nil, {p1, p2}):catch(error):await()
        TimerModule.setTime(-1)

        if chosen[p1] == nil and chosen[p2] == nil then
            GameState.runFuncPerAll(function(player)
                TextModule.setText(player, "both_did_not_move")
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
                        { key = "you_both_chose", delay = 4, data = {btn = buttons[chosen[player]].text} },
                        { key = "tie_choose_again", delay = 4 },
                    }))
                else
                    return protect(TextModule.showTextSequence(player, {
                        { key = "you_both_chose", delay = 4, data = {btn = buttons[chosen[player]].text} },
                        { key = "tie_they_choose_again", delay = 4 },
                    }))
                end
            end):await()
        else
            local c1 = chosen[p1]
            local c2 = chosen[p2]

            if beats[c1] == c2 then
                TextModule.setText(p1, beatsText[c1][c2])
                TextModule.setText(p2, beatsText[c2][c1])
                GameState.runFuncPerAll(function(player)
                    if player ~= p1 and player ~= p2 then
                        TextModule.setText(player, "won_against", {won = p1, lost = p2})
                    end
                end)
                task.wait(4)
                GameState.addRewardTo(p1, 7)
                GameState.kill(p2)
                break
            else
                TextModule.setText(p2, beatsText[c2][c1])
                TextModule.setText(p1, beatsText[c1][c2])
                GameState.runFuncPerAll(function(player)
                    if player ~= p1 and player ~= p2 then
                        TextModule.setText(player, "won_against", {lost = p1, won = p2})
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