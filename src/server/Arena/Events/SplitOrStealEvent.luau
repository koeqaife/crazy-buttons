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

Event.chance = 0.08
Event.minPlayers = 2
Event.maxPerGame = 3
Event.minRound = 3

function Event.check()
    return true
end

function Event.onEvent()
    local randomPlayers = GameState.pickPlayers(2)

    GameState.runPromisePerAll(function(player, protect, await)
        if table.find(randomPlayers, player) then
            return protect(TextModule.showTextSequence(player, {
                { text = "You have been chosen for the Split or Steal", delay = 3, face = "shy" },
                { text = "You will be paired with " .. (if randomPlayers[1] == player then randomPlayers[2] else randomPlayers[1]).Name, delay = 4, face = "scared" },
                { text = "You both will choose whether to split or steal", delay = 4, face = "unamused" },
                { text = "If both split, nothing happens", delay = 4, face = "happy" },
                { text = "If one steals, the other dies", delay = 4, face = "scared" },
                { text = "If both steal, you both die", delay = 4, face = "laughing" },
            }))
        else
            return protect(TextModule.showTextSequence(player, {
                { text = "Two players have been chosen for the Split or Steal", delay = 3, face = "shy" },
                { text = "They are " .. randomPlayers[1].Name .. " and " .. randomPlayers[2].Name, delay = 4, face = "happy" },
                { text = "They both will choose whether to split or steal", delay = 4, face = "unamused" },
                { text = "If both split, nothing happens", delay = 4, face = "happy" },
                { text = "If one steals, the other dies", delay = 4, face = "scared" },
                { text = "If both steal, they both die", delay = 4, face = "laughing" },
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
            })
            TextModule.setText(player, "Choose wisely", "nerd")
        else
            TextModule.setText(player, "Waiting for the players to choose", "normal")
        end
    end)

    TimerModule.setTime(59)
    AmbienceModule.playEerieHorrorRising()
    local _, chosen = ButtonsModule.initiateButtonChoice(59):catch(error):await()

    task.wait(1)
    GameState.removeHighlightFrom(randomPlayers)
    clickSound:Play()
    AmbienceModule.stopEerieHorrorRising()

    local p1 = randomPlayers[1]
    local p2 = randomPlayers[2]

    local c1 = chosen[p1]
    local c2 = chosen[p2]

    if c1 == STEAL_BTN and c2 == STEAL_BTN then
        GameState.runFuncPerAll(function(player)
            TextModule.setText(
                player,
                "Both players chose to steal, they both die",
                "laughing"
            )
        end)

        GameState.addHighlightTo(randomPlayers, Color3.new(1, 0, 0), Color3.new(1, 0, 0))
        task.wait(10)

        GameState.kill(p1)
        GameState.kill(p2)
    elseif c1 == STEAL_BTN or c2 == STEAL_BTN then
        local stealer = c1 == STEAL_BTN and p1 or p2
        local victim = c1 == STEAL_BTN and p2 or p1

        GameState.runFuncPerAll(function(player)
            TextModule.setText(
                player,
                stealer.Name
                    .. " chose to steal, "
                    .. victim.Name
                    .. " is eliminated",
                "unamused"
            )
        end)

        GameState.addHighlightToOne(victim, Color3.new(0.3, 1, 0))
        GameState.addHighlightToOne(stealer, Color3.new(1, 0, 0), Color3.new(1, 0, 0))
        task.wait(10)

        GameState.kill(victim)
    else
        GameState.addHighlightTo(randomPlayers, Color3.new(0.3, 1, 0))
        GameState.runFuncPerAll(function(player)
            TextModule.setText(
                player,
                "Both players chose to split, they both survive",
                "happy"
            )
        end)
        task.wait(10)
    end

    return
end

return Event