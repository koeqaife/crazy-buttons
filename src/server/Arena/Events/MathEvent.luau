--!strict
--!optimize 2

-- Description:
-- Event where one player has math quiz
-- And other people have to answer if he is smart or not
-- If player answered correctly, everyone who pressed "No" die
-- If not, he dies if >50% players clicked "No"
-- And if >50% players clicked "Yes" everyone who clicked it die
-- Pretty interesting game

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Arena = game:GetService("ServerScriptService").Server.Arena
local Helpers = require(ReplicatedStorage.Shared.Helpers)
local IndicesType = require(ReplicatedStorage.Shared.IndicesType)
local GameState = require(Arena.GameStateModule)
local EventTypeModule = require(Arena.Events.EventType)
local TextModule = require(Arena.TextModule)
local ButtonsModule = require(Arena.ButtonsModule)
local TimerModule = require(Arena.TimerModule)
local Promise = require(ReplicatedStorage.Shared.Promise)

type EventType = EventTypeModule.Event

local Event = {} :: EventType

Event.chance = 0.10
Event.minPlayers = 4
Event.maxPerGame = 5

local quizzes = {
    { exp = "1 + 1", answer = 2, incorrectAnswers = {3, 1, 4} },
    { exp = "2 + 2", answer = 4, incorrectAnswers = {5, 3, 6} },
    { exp = "3 + 1", answer = 4, incorrectAnswers = {5, 3, 6} },
    { exp = "5 - 2", answer = 3, incorrectAnswers = {4, 2, 5} },
    { exp = "6 - 3", answer = 3, incorrectAnswers = {4, 2, 5} },
    { exp = "4 + 3", answer = 7, incorrectAnswers = {8, 6, 9} },
    { exp = "7 - 4", answer = 3, incorrectAnswers = {4, 2, 5} },
    { exp = "2 * 2", answer = 4, incorrectAnswers = {5, 3, 6} },
    { exp = "3 * 2", answer = 6, incorrectAnswers = {7, 5, 8} },
    { exp = "4 * 2", answer = 8, incorrectAnswers = {9, 7, 10} },
    { exp = "8 / 2", answer = 4, incorrectAnswers = {5, 3, 6} },
    { exp = "9 / 3", answer = 3, incorrectAnswers = {4, 2, 5} },
    { exp = "10 / 2", answer = 5, incorrectAnswers = {6, 4, 7} },
    { exp = "1 + 2 + 3", answer = 6, incorrectAnswers = {7, 5, 8} },
    { exp = "2 + 3 + 4", answer = 9, incorrectAnswers = {10, 8, 11} },
    { exp = "5 + 1 + 2", answer = 8, incorrectAnswers = {9, 7, 10} },
    { exp = "10 - 3 - 2", answer = 5, incorrectAnswers = {6, 4, 7} },
    { exp = "9 - 2 - 3", answer = 4, incorrectAnswers = {5, 3, 6} },
    { exp = "6 + 2 * 2", answer = 10, incorrectAnswers = {11, 9, 12} },
    { exp = "4 + 3 * 2", answer = 10, incorrectAnswers = {11, 9, 12} },
    { exp = "5 * 2 + 3", answer = 13, incorrectAnswers = {10, 16, 18} },
    { exp = "2 * 3 + 4", answer = 10, incorrectAnswers = {11, 9, 12} },
    { exp = "12 / 3 + 2", answer = 6, incorrectAnswers = {7, 5, 8} },
    { exp = "8 / 2 + 5", answer = 9, incorrectAnswers = {10, 8, 11} },
    { exp = "3 + 3 + 3 + 3", answer = 12, incorrectAnswers = {9, 15, 17} },
    { exp = "2 * 2 * 2", answer = 8, incorrectAnswers = {9, 7, 10} },
    { exp = "4 * 3 - 2", answer = 10, incorrectAnswers = {11, 9, 12} },
    { exp = "5 * 3 - 5", answer = 10, incorrectAnswers = {11, 9, 12} },
    { exp = "20 / 5 + 1", answer = 5, incorrectAnswers = {6, 4, 7} },
    { exp = "18 / 6 + 4", answer = 7, incorrectAnswers = {8, 6, 9} },
    { exp = "7 + 7 - 7", answer = 7, incorrectAnswers = {8, 6, 9} },
    { exp = "9 + 1 - 5", answer = 5, incorrectAnswers = {6, 4, 7} },
    { exp = "6 * 1 + 4", answer = 10, incorrectAnswers = {11, 9, 12} },
    { exp = "3 * 1 + 6", answer = 9, incorrectAnswers = {10, 8, 11} },
    { exp = "2 + 2 * 3", answer = 8, incorrectAnswers = {9, 7, 10} },
    { exp = "1 + 3 * 3", answer = 10, incorrectAnswers = {11, 9, 12} },
    { exp = "16 / 4 + 4", answer = 8, incorrectAnswers = {9, 7, 10} },
    { exp = "15 / 3 + 2", answer = 7, incorrectAnswers = {8, 6, 9} },
    { exp = "2 + 2 + 2 + 2 + 2", answer = 10, incorrectAnswers = {11, 8, 12} },
    { exp = "3 * 3 + 1", answer = 10, incorrectAnswers = {11, 9, 12} },
    { exp = "2 + 3 * 4", answer = 14, incorrectAnswers = {11, 17, 19} },
    { exp = "5 * 6 - 8", answer = 22, incorrectAnswers = {19, 25, 27} },
    { exp = "12 + 4 * 3 - 6", answer = 18, incorrectAnswers = {15, 21, 23} },
    { exp = "7 * 5 + 9 / 3", answer = 38, incorrectAnswers = {35, 41, 43} },
    { exp = "18 / 3 + 4 * 5", answer = 26, incorrectAnswers = {23, 29, 31} },
    { exp = "9 + 8 * 2 + 7", answer = 32, incorrectAnswers = {29, 35, 37} },
    { exp = "15 + 3 * 6 - 4", answer = 29, incorrectAnswers = {26, 32, 34} },
    { exp = "20 - 4 * 3 + 2", answer = 10, incorrectAnswers = {11, 9, 12} },
    { exp = "6 * 6 + 12 / 4", answer = 39, incorrectAnswers = {36, 42, 44} },
    { exp = "14 + 2 * 8 - 5", answer = 25, incorrectAnswers = {22, 28, 30} },
    { exp = "3 * 3 * 4 + 5", answer = 41, incorrectAnswers = {38, 44, 46} },
    { exp = "40 / 5 + 7 * 3", answer = 29, incorrectAnswers = {26, 32, 34} },
    { exp = "11 + 9 * 5 - 10", answer = 46, incorrectAnswers = {43, 49, 51} },
    { exp = "8 * 7 + 6 * 2", answer = 68, incorrectAnswers = {58, 78, 88} },
    { exp = "30 - 6 * 4 + 9", answer = 15, incorrectAnswers = {12, 18, 20} },
    { exp = "4 * 5 * 3 + 6", answer = 66, incorrectAnswers = {56, 76, 86} },
    { exp = "100 / 4 + 8 * 3", answer = 49, incorrectAnswers = {39, 59, 69} },
    { exp = "13 + 7 * 4 + 2 * 5", answer = 51, incorrectAnswers = {41, 61, 71} },
    { exp = "9 * 9 - 8 * 3", answer = 57, incorrectAnswers = {47, 67, 77} },
    { exp = "50 / 2 + 6 * 6", answer = 61, incorrectAnswers = {51, 71, 81} },
    { exp = "16 + 4 * 4 * 2", answer = 48, incorrectAnswers = {38, 58, 68} },
    { exp = "72 / 8 + 5 * 7", answer = 44, incorrectAnswers = {34, 54, 64} },
    { exp = "5 * 5 * 5 - 20", answer = 105, incorrectAnswers = {95, 115, 125} },
    { exp = "6 * 8 + 9 * 4", answer = 84, incorrectAnswers = {74, 94, 104} },
    { exp = "45 + 3 * 7 * 2", answer = 87, incorrectAnswers = {77, 97, 107} },
    { exp = "64 / 8 + 12 * 5", answer = 68, incorrectAnswers = {58, 78, 88} },
    { exp = "21 + 6 * 6 * 2", answer = 93, incorrectAnswers = {83, 103, 113} },
    { exp = "7 * 7 * 3 + 10", answer = 157, incorrectAnswers = {147, 167, 187} },
    { exp = "81 / 9 + 4 * 9 * 2", answer = 81, incorrectAnswers = {71, 91, 101} },
    { exp = "10 * 10 + 5 * 6 * 2", answer = 160, incorrectAnswers = {150, 170, 180} },
    { exp = "96 / 6 + 8 * 8 * 2", answer = 144, incorrectAnswers = {134, 154, 164} },
    { exp = "12 * 4 * 3 + 9 * 5", answer = 189, incorrectAnswers = {179, 199, 209} },
    { exp = "144 / 12 + 7 * 7 * 3", answer = 159, incorrectAnswers = {149, 169, 179} },
    { exp = "9 * 8 * 7 + 6 * 6", answer = 540, incorrectAnswers = {490, 590, 1080} },
    { exp = "5 * 4 * 3 * 2 + 100", answer = 220, incorrectAnswers = {170, 270, 440} },
    { exp = "200 / 5 + 9 * 9 * 3", answer = 283, incorrectAnswers = {233, 333, 566} },
    { exp = "6 * 6 * 6 + 8 * 8 * 2", answer = 344, incorrectAnswers = {294, 394, 688} },
    { exp = "250 / 10 + 5 * 5 * 5 * 2", answer = 275, incorrectAnswers = {225, 325, 550} },
    { exp = "300 / 6 + 4 * 4 * 4 * 3", answer = 242, incorrectAnswers = {192, 292, 484} },
    { exp = "7 * 7 * 7 + 3 * 3 * 3 * 4", answer = 451, incorrectAnswers = {401, 501, 902} },
}

local function getQuiz(): { exp: string, answer: number, incorrectAnswers: {number} }
    local random = math.random(1, #quizzes)
    return quizzes[random]
end

function Event.check()
    return true
end

function Event.onEvent()
    return Promise.new(function(resolve, reject, onCancel)
        local randomQuiz = getQuiz()
        local randomPlayer = GameState.alivePlayers[math.random(1, #GameState.alivePlayers)]

        local answers = {randomQuiz.answer}
        for _, incorrect in ipairs(randomQuiz.incorrectAnswers) do
            table.insert(answers, incorrect)
        end
        Helpers.shuffleTable(answers)

        TimerModule.setTime(5)
        GameState.addHighlightTo({randomPlayer})
        GameState.runPromisePerAlive(function(player)
            if player == randomPlayer then
                return TextModule.showTextSequence(player, {
                    { text = "How good are you in math?", delay = 2.5 },
                    { text = "Other people lives depend on you now", delay = 2.5 },
                })
            else
                return TextModule.showTextSequence(player, {
                    { text = "Do you think " .. randomPlayer.Name .. "is good in math?", delay = 2.5 },
                    { text = "You will have to find out", delay = 2.5 },
                })
            end
        end):await()

        TimerModule.setTime(30)
        GameState.runFuncPerAlive(function(player)
            if player == randomPlayer then
                TextModule.setText(player, "Calculate this:\n" .. randomQuiz.exp)

                local buttons: IndicesType.Indices = {}
                for index, answer in answers do
                    table.insert(buttons, { idx = index, text = tostring(answer) })
                end

                ButtonsModule.setButtons(player, buttons)
            else
                TextModule.setText(
                    player,
                    "Is " .. randomPlayer.Name ..
                    " smart enough to calculate: \n" ..
                    randomQuiz.exp .. "\n?"
                )
                ButtonsModule.setButtons(player, {
                    { idx = 1, text = "No" },
                    { idx = 2, text = "Yes" },
                })
            end
        end)

        local ok, chosen = ButtonsModule.initiateButtonChoice(30):await()
        if not ok then
            reject(chosen)
        end

        local answered = answers[chosen[randomPlayer] or 0] or -1
        local isRight = answered == randomQuiz.answer
        local yesCount = 0
        local total = 0

        GameState.runFuncPerAlive(function(player)
            if player == randomPlayer then
                return
            end

            local choice = chosen[player] or math.random(1, 2)
            total += 1

            local predictedYes = choice == 2
            if predictedYes then
                yesCount += 1
            end
        end)

        local playerMustDie = not isRight and (yesCount <= total / 2)

        TimerModule.setTime(5)
        GameState.runNewPromisePerAlive(function(player)
            if player == randomPlayer then
                if isRight then
                    TextModule.setText(player, "Your answer was right")
                    task.wait(5)
                else
                    TextModule.setText(player, "Your answer was wrong")
                    if playerMustDie then
                        task.wait(2)
                        TextModule.setText(player, "But no one even believed in you...")
                        GameState.kill(player)
                        task.wait(3)
                    else
                        task.wait(5)
                    end
                end
            else
                local choice = chosen[player]
                local isYes = choice == 2
                if choice == nil then
                    TextModule.setText(player, "You had to answer...")
                    GameState.kill(player)
                elseif isYes ~= isRight then
                    if playerMustDie then
                        TextModule.setText(player, "You were wrong, but lucky this time")
                    else
                        TextModule.setText(player, "You were wrong")
                        GameState.kill(player)
                    end
                else
                    TextModule.setText(player, "You were right")
                end
                task.wait(5)
            end
        end):await()

        resolve()
    end)
end

return Event