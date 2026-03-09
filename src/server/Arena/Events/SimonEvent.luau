--!strict
--!optimize 2

-- Description:
-- Event with "Simon says"
-- It was hard to make it interesting with just buttons
-- But I think I did it! But it's pretty hard for people who play for the first time
-- Cause of how many different texts it can have
-- On tests it was hard but after some time playing it, it became easier

local Arena = game:GetService("ServerScriptService").Server.Arena
local GameState = require(Arena.GameStateModule)
local EventTypeModule = require(Arena.Events.EventType)
local TextModule = require(Arena.TextModule)
local ButtonsModule = require(Arena.ButtonsModule)

type EventType = EventTypeModule.Event
type Text = { opposite: boolean, text: string, idx: number?, custom: number? }

local Event = {} :: EventType
Event.category = "reaction"
Event.name = "simon"

local texts: {Text} = {
    -- 4
    { text = "Simon says... select ", opposite = false },
    { text = "Simon says... do not select ", opposite = true },
    { text = "Simon says, select ", opposite = false },
    { text = "Simon says, do not select ", opposite = true },

    -- 6
    { text = "Select ", opposite = true },
    { text = "Do not select ", opposite = false },

    -- 11
    { text = "Now... select ", opposite = true },
    { text = "Now... do not select ", opposite = false },
    { text = "Simply select ", opposite = true },
    { text = "My name is Simon, select ", opposite = true },
    { text = "Simon thinks you should select ", opposite = true },

    -- 17
    { text = "Simon says... select the color of the sky", opposite = false, idx = 2 },
    { text = "Simon says... select the color of a banana", opposite = false, idx = 4 },
    { text = "Simon says... select the color of a ruby", opposite = false, idx = 1 },
    { text = "Select the color of the sky", opposite = true, idx = 2 },
    { text = "Select the color of a banana", opposite = true, idx = 4 },
    { text = "Select the color of a ruby", opposite = true, idx = 1 },

    -- 22
    { text = "Do not change your selection", custom = 1, opposite = false },
    { text = "Simply not change your selection", custom = 1, opposite = false },
    { text = "Change your selection", custom = 1, opposite = true },
    { text = "Simon says... change your selection", custom = 1, opposite = false },
    { text = "Simon says... do not change your selection", custom = 1, opposite = true },
}
local COLOR_NAMES = { "Red", "Blue", "Pink", "Yellow" }

Event.chance = 0.09
Event.maxPerGame = 1
Event.minRound = 3
Event.minPlayers = 7

local MAX_DEATHS_ALLOWED = 5
local MAX_SUB_ROUNDS = 15

local ROUNDS_RANGE = {
    [1] = 1,
    [2] = 4,
    [3] = 6,
    [4] = 6,
    [5] = 11,
    [6] = 11,
    [7] = 11,
    [8] = 11,
    [9] = 11,
    [10] = 17,
    [11] = 17,
    [12] = 17,
    [13] = 22,
    [14] = 22,
    [15] = 22,
}

function Event.check()
    return true
end

function Event.onEvent()
    local deathsThisEvent = 0

    GameState.runFuncPerDead(function(player)
        TextModule.setText(player, "They're playing Simon says", "nerd")
    end)

    GameState.runPromisePerAlive(function(player, protect)
        return protect(TextModule.showTextSequence(player, {
            { text = "Alright, I'm Simon now", delay = 5, face = "shy" },
            { text = "No \"Simon says\"? Then do the opposite", delay = 5, face = "nerd" },
        }))
    end):catch(error):await()

    GameState.runFuncPerAlive(function(player)
        ButtonsModule.setButtons(player, {
            { idx = 1, text = "Red" },
            { idx = 2, text = "Blue" },
            { idx = 3, text = "Pink" },
            { idx = 4, text = "Yellow" },
        })
    end)

    local lastChosen: {[Player]: number?} = {}
    for i = 1, MAX_SUB_ROUNDS do
        if deathsThisEvent >= MAX_DEATHS_ALLOWED then
            break
        end

        local maxRange = ROUNDS_RANGE[i]
        local randomTextRaw = texts[math.random(1, maxRange)]
        local randomText: Text = {  -- Copy
            text = randomTextRaw.text,
            custom = randomTextRaw.custom,
            idx = randomTextRaw.idx,
            opposite = randomTextRaw.opposite
        }
        if randomText.custom == nil and randomText.idx == nil then
            local randomColor = math.random(1, 4)
            randomText.text = randomText.text .. COLOR_NAMES[randomColor]
            randomText.idx = randomColor
        end

        local lastChosenCopy: {[Player]: number?} = {}
        for player, idx in pairs(lastChosen) do
            lastChosenCopy[player] = idx
        end
        GameState.runFuncPerAlive(function(player)
            TextModule.setText(player, randomText.text, "normal")
        end)

        local clickedNow: {[Player]: boolean} = {}

        local _, chosen = ButtonsModule.initiateButtonChoice(
            8,
            function(playerWhoClicked)
                return not clickedNow[playerWhoClicked]
            end,
            function(playerWhoClicked)
                clickedNow[playerWhoClicked] = true
            end,
            lastChosenCopy
        ):catch(error):await()

        GameState.runNewPromisePerAlive(function(player)
            local selected = chosen[player]
            GameState.addRewardTo(player, 0.5)
            if randomText.idx then
                if (randomText.opposite and randomText.idx == selected) or
                    (not randomText.opposite and randomText.idx ~= selected)
                then
                    ButtonsModule.setButtons(player, {})
                    GameState.kill(player)
                    deathsThisEvent += 1
                end
            elseif randomText.custom == 1 then
                local lastSelected = lastChosen[player]
                local didChange = (selected ~= lastSelected)
                if (randomText.opposite and didChange) or
                    (not randomText.opposite and not didChange)
                then
                    ButtonsModule.setButtons(player, {})
                    GameState.kill(player)
                    deathsThisEvent += 1
                end
            end
        end)

        lastChosen = chosen
    end

    return
end

return Event