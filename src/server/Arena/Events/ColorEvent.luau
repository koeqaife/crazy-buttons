--!strict
--!optimize 2

-- Description:
-- Event where you choose color in the beginning
-- And you're gonna be asked what color you chose
-- Buttons are mixed due to default argument in ButtonsModule
-- So positions are always different

local Arena = game:GetService("ServerScriptService").Server.Arena
local GameState = require(Arena.GameStateModule)
local EventTypeModule = require(Arena.Events.EventType)
local TextModule = require(Arena.TextModule)
local ButtonsModule = require(Arena.ButtonsModule)
local TimerModule = require(Arena.TimerModule)

type EventType = EventTypeModule.Event

local Event = {} :: EventType

Event.chance = 0.1
Event.minPlayers = 2
Event.maxPerGame = 2

local chosenColors: {[Player]: number} = {}
local COLOR_NAMES = { "red", "blue", "pink", "yellow", "green" }

local counter = 0

function Event.check()
    Event.chance += 0.03
    counter -= 1
    return counter <= 0
end

function Event.onEvent()
    if next(chosenColors) then
        GameState.runFuncPerDead(function(player)
            TextModule.setText(player, "They're getting checked if they remember the color", "color_event_icon")
        end)

        GameState.runPromisePerAlive(function(player, protect)
            return protect(TextModule.showTextSequence(player, {
                { text = "Do you remember the color you chose before?", delay = 5.5, face = "color_event_icon" },
                { text = "Let's check your memory", delay = 4, face = "shy" },
            }))
        end):catch(error):await()

        TimerModule.setTime(15)
        GameState.runFuncPerAlive(function(player)
            TextModule.setText(player, "So, which one did you choose?", "nerd")
            ButtonsModule.setButtons(player, {
                { idx = 1, text = "Red" },
                { idx = 2, text = "Blue" },
                { idx = 3, text = "Pink" },
                { idx = 4, text = "Yellow" },
                { idx = 5, text = "Green" },
            })
        end)

        local _, chosen = ButtonsModule.initiateButtonChoice(15):catch(error):await()

        GameState.runNewPromisePerAlive(function(player, protect, await)
            local color = chosen[player] or 0
            if color ~= chosenColors[player] then
                TextModule.setText(player, "That was not the color you chose", "dead")
                GameState.kill(player)
                task.wait(5)
            else
                await(TextModule.showTextSequence(player, {
                    { text = "Woa, you actually remember!", delay = 4, face = "happy" },
                    { text = "Good job", delay = 2, face = "shy" },
                }))
            end
        end):catch(error):await()

        return
    end

    GameState.runFuncPerDead(function(player)
        TextModule.setText(player, "They're asked to choose a color", "color_event_icon")
    end)

    GameState.runPromisePerAlive(function(player, protect)
        return protect(TextModule.showTextSequence(player, {
            { text = "I'm about to show you some colors", delay = 4.5, face = "color_event_icon" },
            { text = "Remember which one you pick, you'll need it later", delay = 4.5, face = "normal" },
        }))
    end):catch(error):await()

    TimerModule.setTime(15)
    GameState.runFuncPerAlive(function(player)
        TextModule.setText(player, "Choose color you like the most now", "nerd")
        local buttons = {
            { idx = 1, text = "Red" },
            { idx = 2, text = "Blue" },
            { idx = 3, text = "Pink" },
            { idx = 4, text = "Yellow" },
            { idx = 5, text = "Green" },
        }
        table.remove(buttons, math.random(1, #buttons))
        table.remove(buttons, math.random(1, #buttons))

        ButtonsModule.setButtons(player, buttons)
    end)

    local _, chosen = ButtonsModule.initiateButtonChoice(15):catch(error):await()

    local toSave: {[Player]: number} = {}

    GameState.runFuncPerAlive(function(player)
        local color = chosen[player] or 0
        if color == 1 then
            TextModule.setText(player, "Red? An interesting choice", "happy")
        elseif color == 2 then
            TextModule.setText(player, "Blue, the color of the sky", "happy")
        elseif color == 3 then
            TextModule.setText(player, "Pink, sounds like a candy, yummy", "happy")
        elseif color == 4 then
            TextModule.setText(player, "Yellow!?!? Fine, that's your choice", "happy")
        elseif color == 5 then
            TextModule.setText(player, "Green, the color of nature...", "happy")
        else
            color = math.random(1, 5)
            local colorName = COLOR_NAMES[color]
            TextModule.setText(player, "Nothing? Let's go with " .. colorName .. " then", "laughing")
        end
        toSave[player] = color
    end)
    chosenColors = toSave

    -- Can show this event only after 5 rounds
    counter = 5

    task.wait(5)

    return
end

return Event