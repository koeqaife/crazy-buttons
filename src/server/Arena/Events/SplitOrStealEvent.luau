--!strict
--!optimize 2
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

-- Description:
-- Split or Steal event where 2 random players will have to choose whether they wanna split the prize or steal it
-- If both steal, both die. If one steal the other dies. If both split, nothing happens

local Arena = game:GetService("ServerScriptService").Server.Arena
local TimerModule = require(ServerScriptService.Server.Arena.TimerModule)
local GameState = require(Arena.GameStateModule)
local EventTypeModule = require(Arena.Events.EventType)
local TextModule = require(Arena.TextModule)
local ButtonsModule = require(Arena.ButtonsModule)
local AmbienceModule = require(Arena.AmbienceModule)

type EventType = EventTypeModule.Event

local Event = {} :: EventType

local clickSound = ReplicatedStorage
    :WaitForChild("Sounds")
    :WaitForChild("LoudClickSound") :: Sound

Event.name = "split_steal"
Event.category = "social"
Event.chance = 0.08
Event.minPlayers = 2
Event.maxPerGame = 3
Event.minRound = 3

function Event.check()
    return true
end

function Event.onEvent()
    local randomPlayers = GameState.pickPlayers(2)
    local p1 = randomPlayers[1]
    local p2 = randomPlayers[2]

    GameState.runPromisePerAll(function(player, protect, await)
        if table.find(randomPlayers, player) then
            return protect(TextModule.showTextSequence(player, {
                { key = "intro_you_pair", delay = 7, data = { p2 = (p1 == player and p2 or p1) } },
                { key = "rule_both_split", delay = 5 },
                { key = "rule_one_steal", delay = 5 },
                { key = "rule_both_steal", delay = 5 },
            }))
        else
            return protect(TextModule.showTextSequence(player, {
                { key = "intro_others_pair", delay = 7, data = { p1 = p1, p2 = p2 } },
                { key = "rule_both_split", delay = 5 },
                { key = "rule_one_steal", delay = 5 },
                { key = "rule_both_steal_others", delay = 5 },
            }))
        end
    end):catch(error):await()

    GameState.addHighlightTo(randomPlayers)

    local STEAL_BTN = 1
    local SPLIT_BTN = 5

    GameState.runFuncPerAll(function(player)
        if table.find(randomPlayers, player) then
            ButtonsModule.setButtons(player, {
                { idx = SPLIT_BTN, text = "Split" },
                { idx = STEAL_BTN, text = "Steal" }
            }, nil, false)
            TextModule.setText(player, "choose_wisely")
        else
            TextModule.setText(player, "waiting_for_players")
        end
    end)

    TimerModule.setTime(30)
    AmbienceModule.playEerieHorrorRising()
    local _, chosen = ButtonsModule.initiateButtonChoice(30, nil, nil, nil, nil, {p1, p2}):catch(error):await()
    AmbienceModule.stopEerieHorrorRising()
    TimerModule.setTime(-1)

    task.wait(1)
    GameState.removeHighlightFrom(randomPlayers)
    clickSound:Play()

    local c1 = chosen[p1]
    local c2 = chosen[p2]

    if c1 == STEAL_BTN and c2 == STEAL_BTN then
        GameState.runFuncPerAll(function(player)
            TextModule.setText(player, "both_steal")
        end)

        GameState.addHighlightTo(randomPlayers, Color3.new(1, 0, 0), Color3.new(1, 0, 0))
        task.wait(10)

        GameState.kill(p1)
        GameState.kill(p2)
    elseif c1 == STEAL_BTN or c2 == STEAL_BTN then
        local stealer = c1 == STEAL_BTN and p1 or p2
        local victim = c1 == STEAL_BTN and p2 or p1

        GameState.runFuncPerAll(function(player)
            TextModule.setText(player, "stealer_chosen", { stealer = stealer, victim = victim })
        end)

        GameState.addHighlightToOne(victim, Color3.new(0.3, 1, 0))
        GameState.addHighlightToOne(stealer, Color3.new(1, 0, 0), Color3.new(1, 0, 0))
        task.wait(10)

        GameState.addRewardTo(stealer, 10)
        GameState.kill(victim)
    else
        GameState.addHighlightTo(randomPlayers, Color3.new(0.3, 1, 0))
        GameState.runFuncPerAll(function(player)
            TextModule.setText(player, "both_split")
        end)

        GameState.addRewardTo(p1, 5)
        GameState.addRewardTo(p2, 5)

        task.wait(10)
    end

    return
end

return Event