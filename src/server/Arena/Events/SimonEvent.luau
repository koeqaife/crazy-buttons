--!strict
--!optimize 2
local ServerScriptService = game:GetService("ServerScriptService")

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

local logAction = require(ServerScriptService.Server.Shared.QuestsModule).logAction

type EventType = EventTypeModule.Event
type Text = { opposite: boolean, text: string, idx: number?, custom: number?, tutorial: string }

local Event = {} :: EventType
Event.category = "reaction"
Event.name = "simon"

-- Tutorial appears on when you die
local texts: {Text} = {
    -- 4
    { text = "Simon says... select ", opposite = false, tutorial = "You had to select the color" },
    { text = "Simon says... do not select ", opposite = true, tutorial = "Your selection had to be opposite" },
    { text = "Simon says, select ", opposite = false, tutorial = "You had to select the color" },
    { text = "Simon says, do not select ", opposite = true, tutorial = "Your selection had to be opposite" },

    -- 6
    { text = "Select ", opposite = true, tutorial = "Your selection had to be opposite" },
    { text = "Do not select ", opposite = false, tutorial = "There was no 'Simon says' so you had to do the opposite of 'do not'" },

    -- 11
    { text = "Now... select ", opposite = true, tutorial = "There was no 'Simon says' so your selection had to be other color" },
    { text = "Now... do not select ", opposite = false, tutorial = "There was no 'Simon says' so you had to do the opposite of 'do not'" },
    { text = "Simply select ", opposite = true, tutorial = "Simply is not 'Simon says', so your selection had to be other color" },
    { text = "My name is Simon, select ", opposite = true, tutorial = "His name is Simon, but there was no 'Simon says'" },
    { text = "Simon thinks you should select ", opposite = true, tutorial = "Simon thinks but he didn't say 'Simon says'" },

    -- 17
    { text = "Simon says... select the color of the sky", opposite = false, idx = 2, tutorial = "The color of the sky is blue" },
    { text = "Simon says... select the color of a banana", opposite = false, idx = 4, tutorial = "The color of banana is yellow" },
    { text = "Simon says... select the color of a ruby", opposite = false, idx = 1, tutorial = "The color of ruby is red" },
    { text = "Select the color of the sky", opposite = true, idx = 2, tutorial = "There was no 'Simon says' so your selection had to be NOT blue" },
    { text = "Select the color of a banana", opposite = true, idx = 4, tutorial = "There was no 'Simon says' so your selection had to be NOT yellow" },
    { text = "Select the color of a ruby", opposite = true, idx = 1, tutorial = "There was no 'Simon says' so your selection had to be NOT red" },

    -- 22
    { text = "Do not change your selection", custom = 1, opposite = false, tutorial = "There was no 'Simon says' so you had to do the opposite of 'do not'" },
    { text = "Simply not change your selection", custom = 1, opposite = false, tutorial = "There was no 'Simon says' so you had to do the opposite of 'simply not'" },
    { text = "Change your selection", custom = 1, opposite = true, tutorial = "There was no 'Simon says' so you had to not click anything" },
    { text = "Simon says... change your selection", custom = 1, opposite = false, tutorial = "You had to press any button" },
    { text = "Simon says... do not change your selection", custom = 1, opposite = true, tutorial = "You had to not press any button" },
}
local COLOR_NAMES = { "Red", "Blue", "Pink", "Yellow" }

Event.chance = 0.09
Event.maxPerGame = 1
Event.minRound = 3
Event.minPlayers = 4

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
        TextModule.setText(player, "intro_dead")
    end)

    GameState.runPromisePerAlive(function(player, protect)
        return protect(TextModule.showTextSequence(player, {
            { key = "intro_alive_1", delay = 5 },
            { key = "intro_alive_2", delay = 5 },
            { key = "intro_alive_3", delay = 5 },
            { key = "intro_alive_4", delay = 5 },
        }))
    end):catch(error):await()

    GameState.runFuncPerAlive(function(player)
        logAction(player, "simon_says")
        ButtonsModule.setButtons(player, {
            { idx = 1, text = "Red" },
            { idx = 2, text = "Blue" },
            { idx = 3, text = "Pink" },
            { idx = 4, text = "Yellow" },
        })
    end)

    local lastChosen: {[Player]: number?} = {}
    local lastString = -1
    for i = 1, MAX_SUB_ROUNDS do
        if deathsThisEvent >= MAX_DEATHS_ALLOWED or (#GameState.alivePlayers <= 3 and i > 5) then
            break
        end

        local maxRange = ROUNDS_RANGE[i]
        local newStringIdx = -1
        while newStringIdx == lastString do
            newStringIdx = math.random(1, maxRange)
        end
        local randomTextRaw = texts[newStringIdx]
        local randomText: Text = {  -- Copy
            text = randomTextRaw.text,
            custom = randomTextRaw.custom,
            idx = randomTextRaw.idx,
            opposite = randomTextRaw.opposite,
            tutorial = randomTextRaw.tutorial
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

        -- use localization key with dynamic text passed in data
        GameState.runFuncPerAlive(function(player)
            TextModule.setText(player, "round_text", { text = randomText.text })
        end)

        local _, chosen = ButtonsModule.initiateButtonChoice(8, nil, nil, lastChosenCopy, true):catch(error):await()

        GameState.runNewPromisePerAlive(function(player)
            local selected = chosen[player]
            GameState.addRewardTo(player, 0.5)
            if randomText.idx then
                if (randomText.opposite and randomText.idx == selected) or
                    (not randomText.opposite and randomText.idx ~= selected)
                then
                    ButtonsModule.setButtons(player, {})
                    GameState.kill(player)
                    TextModule.setText(player, "round_text", { text = randomText.tutorial })
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