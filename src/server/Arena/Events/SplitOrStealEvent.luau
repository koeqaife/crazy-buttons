--!strict
--!optimize 2
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

-- Description:
-- Split or Steal event where 2 random players will have to choose whether they wanna split the prize or steal it
-- If both steal, both die. If one steal the other dies. If both split, nothing happens

local Arena = game:GetService("ServerScriptService").Server.Arena
local MiscModule = require(ServerScriptService.Server.Arena.MiscModule)
local PlayersModule = require(ServerScriptService.Server.Arena.PlayersModule)
local RewardsModule = require(ServerScriptService.Server.Arena.RewardsModule)
local TimerModule = require(ServerScriptService.Server.Arena.TimerModule)
local EventTypeModule = require(Arena.Events.EventType)
local TextModule = require(Arena.TextModule)
local ButtonsModule = require(Arena.ButtonsModule)
local AmbienceModule = require(Arena.AmbienceModule)

local logAction = require(ServerScriptService.Server.Shared.QuestsModule).logAction

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

local explained = false

function Event.check()
    return true
end

function Event.onEvent()
    local randomPlayers = PlayersModule.pickPlayers(2)
    local p1 = randomPlayers[1]
    local p2 = randomPlayers[2]

    if not explained then
        explained = true
        PlayersModule.runPromisePerAll(function(player, protect, await)
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
    else
        PlayersModule.runFuncPerAll(function(player)
            if table.find(randomPlayers, player) then
                TextModule.setText(player, "intro_you_pair", { p2 = (p1 == player and p2 or p1) } )
            else
                TextModule.setText(player, "intro_others_pair", { p1 = p1, p2 = p2 } )
            end
        end)
        task.wait(7)
    end

    MiscModule.addHighlightTo(randomPlayers)

    local STEAL_BTN = 1
    local SPLIT_BTN = 5

    PlayersModule.runFuncPerAll(function(player)
        if table.find(randomPlayers, player) then
            ButtonsModule.setButtons(player, {
                { idx = SPLIT_BTN, text = "Split" },
                { idx = STEAL_BTN, text = "Steal" }
            }, false)
            TextModule.setText(player, "choose_wisely")
        else
            ButtonsModule.setButtons(player, {
                { idx = SPLIT_BTN, text = "Split", inputDisabled = true },
                { idx = STEAL_BTN, text = "Steal", inputDisabled = true }
            }, false)
            TextModule.setText(player, "waiting_for_players")
        end
    end)

    TimerModule.setTime(30)
    AmbienceModule.playEerieHorrorRising()
    local _, chosen = ButtonsModule.initiateButtonChoice(30, nil, nil, nil, nil, {p1, p2}):catch(error):await()
    AmbienceModule.stopEerieHorrorRising()
    TimerModule.setTime(-1)

    task.wait(1)
    MiscModule.removeHighlightFrom(randomPlayers)
    clickSound:Play()

    local c1 = chosen[p1]
    local c2 = chosen[p2]

    if c1 == STEAL_BTN and c2 == STEAL_BTN then
        PlayersModule.runFuncPerAll(function(player)
            TextModule.setText(player, "both_steal")
        end)

        MiscModule.addHighlightTo(randomPlayers, Color3.new(1, 0, 0), Color3.new(1, 0, 0))
        task.wait(10)

        PlayersModule.kill(p1)
        PlayersModule.kill(p2)
    elseif c1 == STEAL_BTN or c2 == STEAL_BTN then
        local stealer = c1 == STEAL_BTN and p1 or p2
        local victim = c1 == STEAL_BTN and p2 or p1

        PlayersModule.runFuncPerAll(function(player)
            TextModule.setText(player, "stealer_chosen", { stealer = stealer, victim = victim })
        end)

        MiscModule.addHighlightToOne(victim, Color3.new(0.3, 1, 0))
        MiscModule.addHighlightToOne(stealer, Color3.new(1, 0, 0), Color3.new(1, 0, 0))
        RewardsModule.addRewardTo(stealer, 10)
        logAction(stealer, "steal_survive")

        task.wait(7)

        PlayersModule.kill(victim)
    else
        MiscModule.addHighlightTo(randomPlayers, Color3.new(0.3, 1, 0))
        PlayersModule.runFuncPerAll(function(player)
            TextModule.setText(player, "both_split")
        end)

        RewardsModule.addRewardTo(p1, 5)
        RewardsModule.addRewardTo(p2, 5)
        logAction(p1, "split_survive")
        logAction(p2, "split_survive")

        task.wait(7)
    end

    return
end

return Event