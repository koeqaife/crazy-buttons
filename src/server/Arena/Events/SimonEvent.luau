--!strict
--!optimize 2

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Arena = game:GetService("ServerScriptService").Server.Arena
local GameState = require(Arena.GameStateModule)
local EventTypeModule = require(Arena.Events.EventType)
local TextModule = require(Arena.TextModule)
local ButtonsModule = require(Arena.ButtonsModule)
local TimerModule = require(Arena.TimerModule)
local Promise = require(ReplicatedStorage.Shared.Promise)

type EventType = EventTypeModule.Event
type Text = { opposite: boolean, text: string, idx: number?, custom: number? }

local Event = {} :: EventType

local texts: {Text} = {
    { text = "Simon says... select ", opposite = false },
    { text = "Simon says... do not select ", opposite = true },
    { text = "Simon says, select ", opposite = false },
    { text = "Simon says, do not select ", opposite = true },
    { text = "Select ", opposite = true },
    { text = "Do not select ", opposite = false },
    { text = "Now... select ", opposite = true },
    { text = "Now... do not select ", opposite = false },
    { text = "Simply select ", opposite = true },
    { text = "My name is Simon, select ", opposite = true },
    { text = "Simon thinks you should select ", opposite = true },
    { text = "Simon says... select the color of the sky", opposite = false, idx = 2 },
    { text = "Simon says... select the color of a banana", opposite = false, idx = 4 },
    { text = "Simon says... select the color of a ruby", opposite = false, idx = 1 },
    { text = "Select the color of the sky", opposite = true, idx = 2 },
    { text = "Select the color of a banana", opposite = true, idx = 4 },
    { text = "Select the color of a ruby", opposite = true, idx = 1 },

    { text = "Do not change your selection", custom = 1, opposite = false },
    { text = "Simply not change your selection", custom = 1, opposite = false },
    { text = "Change your selection", custom = 1, opposite = true },
    { text = "Simon says... change your selection", custom = 1, opposite = false },
    { text = "Simon says... do not change your selection", custom = 1, opposite = true },
}
local COLOR_NAMES = { "Red", "Blue", "Pink", "Yellow" }

Event.chance = 0.05
Event.maxPerGame = 1
Event.minRound = 3
Event.minPlayers = 7

local MAX_DEATHS_ALLOWED = 5
local MAX_SUB_ROUNDS = 15

function Event.check()
    return true
end

function Event.onEvent()
    return Promise.new(function(resolve, reject, onCancel)
        local deathsThisEvent = 0

        TimerModule.setTime(5)
        GameState.runPromisePerAlive(function(player)
            return TextModule.showTextSequence(player, {
                { text = "Now, I will be Simon", delay = 2.5 },
                { text = "If I didn't say 'Simon says' do opposite", delay = 2.5 },
            })
        end):await()

        GameState.runNewPromisePerAlive(function(player)
            ButtonsModule.setButtons(player, {
                { idx = 1, text = "Red" },
                { idx = 2, text = "Blue" },
                { idx = 3, text = "Pink" },
                { idx = 4, text = "Yellow" },
            })
        end):await()

        local lastChosen: {[Player]: number?} = {}
        for i = 1, MAX_SUB_ROUNDS do
            if deathsThisEvent >= MAX_DEATHS_ALLOWED then
                break
            end

            local randomTextRaw = texts[math.random(1, #texts)]
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
                TextModule.setText(player, randomText.text)
            end)

            local clickedNow: {[Player]: boolean} = {}

            TimerModule.setTime(5)
            local ok, chosen = ButtonsModule.initiateButtonChoice(
                5,
                function(playerWhoClicked)
                    return not clickedNow[playerWhoClicked]
                end,
                function(playerWhoClicked)
                    clickedNow[playerWhoClicked] = true
                end,
                lastChosenCopy
            ):await()
            if not ok then
                reject(chosen)
            end

            GameState.runNewPromisePerAlive(function(player)
                local selected = chosen[player]
                if randomText.idx then
                    if (randomText.opposite and randomText.idx == selected) or
                       (not randomText.opposite and randomText.idx ~= selected)
                    then
                        ButtonsModule.setButtons(player, {})
                        GameState.kill(player)
                    end
                elseif randomText.custom == 1 then
                    local lastSelected = lastChosen[player]
                    local didChange = (selected ~= lastSelected)
                    if (randomText.opposite and didChange) or
                       (not randomText.opposite and not didChange)
                    then
                        ButtonsModule.setButtons(player, {})
                        GameState.kill(player)
                    end
                end
            end)

            TimerModule.setTime(3)
            task.wait(3)
            lastChosen = chosen
        end

        resolve()
    end)
end

return Event