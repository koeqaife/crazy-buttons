--!strict
--!native
--!optimize 2
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local DataStoreModule = require(script.Parent.DataStoreModule)
local Sounds = require(script.Parent.Sounds)

local SEED = 9273451237395

local QuestsModule = {}
local cachedQuests: {string}? = nil
local cachedActions: {[string]: boolean}? = nil
local cacheDay: number = 0

local SyncQuestsEvent = Instance.new("RemoteEvent", ReplicatedStorage)
SyncQuestsEvent.Name = "SyncQuestsEvent"

export type Action = "survive_streak" | "perfect_combo" | "duel_win" | "kill" | "steal_survive"
                     | "linked" | "die" | "linked_win" | "att_def_trust_win" | "press_red"
                     | "math_correct" | "play_with_2_friends" | "duel_win_streak" | "complete_obby"
                     | "two_knows_kills" | "press" | "survive" | "play_with_friends" | "press_blue"
                     | "remember_color" | "combo_mistake" | "split_survive" | "press_streak" | "play"
                     | "simon_says" | "two_knows_save" | "press_maze" | "kill_friend"

type Quest = {
    description: string,
    action: Action,
    amount: number,
    reward: number
}

local easyQuests: {[string]: Quest} = {
    survive_once = { description = "Survive once", action = "survive", amount = 1, reward = 10 },
    play_5 = { description = "Play 5 times", action = "play", amount = 5, reward = 15 },
    press_20 = { description = "Press 20 buttons", action = "press", amount = 20, reward = 10 },
    press_10 = { description = "Press 10 buttons", action = "press", amount = 10, reward = 10 },
    kill_someone = { description = "Kill a player", action = "kill", amount = 1, reward = 15 },
    press_maze_2 = { description = "Press 2 buttons in maze", action = "press_maze", amount = 2, reward = 15 },
    math_correct = { description = "Answer a math quiz correctly", action = "math_correct", amount = 1, reward = 10 },
    complete_obby_1 = { description = "Complete an obby once", action = "complete_obby", amount = 1, reward = 20 },
    combo_mistakes_25 = { description = "Make 25 mistakes in combo mini-game", action = "combo_mistake", amount = 25, reward = 10 },
    two_knows_save = { description = "Make everyone click your button when it saves", action = "two_knows_save", amount = 1, reward = 20 },
    two_knows_kills = { description = "Make everyone click your button when it kills", action = "two_knows_kills", amount = 1, reward = 20 },
    simon_says_once = { description = "Play Simon Says once", action = "simon_says", amount = 1, reward = 10 },
    linked_5 = { description = "Get linked 5 times", action = "linked", amount = 5, reward = 15 },

    press_red_5 = { description = "Press red buttons 5 times", action = "press_red", amount = 5, reward = 10 },
    press_blue_5 = { description = "Press blue buttons 5 times", action = "press_blue", amount = 5, reward = 10 },
    die_once = { description = "Die once", action = "die", amount = 1, reward = 10 },
    join_party = { description = "Play with at least 2 friends 2 times", action = "play_with_2_friends", amount = 2, reward = 20 },
}

local mediumQuests: {[string]: Quest} = {
    att_def_trust_win_1 = { description = "Win Attack, Defend, Trust once", action = "att_def_trust_win", amount = 1, reward = 25 },
    duel_win_2 = { description = "Win 2 duels", action = "duel_win", amount = 2, reward = 25 },
    duel_win_3 = { description = "Win 3 duels", action = "duel_win", amount = 3, reward = 30 },
    remember_color_1 = { description = "Remember your color and don't die", action = "remember_color", amount = 1, reward = 25 },
    combo_no_mistakes = { description = "Make no mistakes in combo mini-game", action = "perfect_combo", amount = 1, reward = 25 },
    split_survive = { description = "Survive while splitting in Split or Steal", action = "split_survive", amount = 1, reward = 25 },
    steal_survive = { description = "Survive while stealing in Split or Steal", action = "steal_survive", amount = 1, reward = 25 },
    linked_win = { description = "Win after being linked", action = "linked_win", amount = 1, reward = 30 },
    kill_friend = { description = "Kill your friend", action = "kill_friend", amount = 1, reward = 35 },

    survive_3 = { description = "Survive 3 times", action = "survive", amount = 3, reward = 30 },
    play_20 = { description = "Play 20 times", action = "play", amount = 20, reward = 35 },
    press_100 = { description = "Press 100 buttons", action = "press", amount = 100, reward = 35 },
    complete_obby_3 = { description = "Complete obby 3 times", action = "complete_obby", amount = 3, reward = 35 },
    math_correct_3 = { description = "Answer 3 math quizzes correctly", action = "math_correct", amount = 3, reward = 25 },

    survive_streak_2 = { description = "Survive 2 games in a row", action = "survive_streak", amount = 2, reward = 35 },
    duel_win_streak_2 = { description = "Win 2 duels in a row", action = "duel_win_streak", amount = 2, reward = 35 },
    press_streak_20 = { description = "Press 20 buttons without dying", action = "press_streak", amount = 20, reward = 35 },
}

local hardQuests: {[string]: Quest} = {
    survive_10 = { description = "Survive 10 rounds", action = "survive", amount = 10, reward = 40 },
    press_500 = { description = "Press 500 buttons", action = "press", amount = 500, reward = 65 },
    win_10_duels = { description = "Win 10 duels", action = "duel_win", amount = 10, reward = 45 },
    complete_obby_10 = { description = "Complete obby 25 times", action = "complete_obby", amount = 25, reward = 50 },
    remember_color_1 = { description = "Remember your color and don't die 25 times", action = "remember_color", amount = 25, reward = 75 },
    linked_win_5 = { description = "Win after being linked 5 times", action = "linked_win", amount = 5, reward = 50 },

    perfect_combo_3 = { description = "Perfect combo 10 times (no mistakes)", action = "perfect_combo", amount = 10, reward = 65 },
    win_att_def_trust_5 = { description = "Win Attack, Defend, Trust 12 times", action = "att_def_trust_win", amount = 12, reward = 50 },

    survive_streak_5 = { description = "Survive 5 times in a row", action = "survive_streak", amount = 5, reward = 80 },

    social_club = { description = "Play with friends 20 times", action = "play_with_friends", amount = 20, reward = 65 },

    press_master_1000 = { description = "Press 1000 buttons", action = "press", amount = 1000, reward = 75 },
}

local allQuests: {[string]: Quest}  = {}
local indexes: {[Action]: {string}} = {}

for key, value in pairs(easyQuests) do allQuests[key] = value end
for key, value in pairs(mediumQuests) do allQuests[key] = value end
for key, value in pairs(hardQuests) do allQuests[key] = value end
for key, value in pairs(allQuests) do
    local action = value.action :: any
    if indexes[action] == nil then
        indexes[action] = {key}
    else
        table.insert(indexes[action], key)
    end
end

local questsPerPlayer: {[Player]: {[string]: number}} = {}
QuestsModule.allQuests = allQuests

local function pickQuest(list: {[string]: Quest}, rng: Random, used: {[string]: boolean}): string
    local keys = {}

    for key, quest in pairs(list) do
        if not used[quest.action] then
            table.insert(keys, key)
        end
    end

    if #keys == 0 then
        error("No quests available without repeating actions")
    end

    local chosen = keys[rng:NextInteger(1, #keys)]
    used[list[chosen].action] = true

    return chosen
end

local function getSeed(day: number): number
    return bit32.bxor(day, SEED)
end

local function getQuests()
    local day = math.floor(os.time() / 86400)
    if day == cacheDay and cachedQuests ~= nil and cachedActions ~= nil then
        return cachedQuests, cachedActions
    else
        table.clear(questsPerPlayer)
    end
    local rng = Random.new(getSeed(day))

    local usedActions: {[string]: boolean} = {}

    local easy = pickQuest(easyQuests, rng, usedActions)
    local medium = pickQuest(mediumQuests, rng, usedActions)
    local hard = pickQuest(hardQuests, rng, usedActions)
    local quests = {easy, medium, hard}
    cacheDay = day
    cachedQuests = quests
    cachedActions = usedActions

    return quests, usedActions
end

function QuestsModule.logAction(player: Player, action: Action)
    local quests, actions = getQuests()
    if actions[action] ~= true then
        return
    end

    local playerQuests = questsPerPlayer[player]
    if playerQuests == nil then
        playerQuests = {}
        questsPerPlayer[player] = playerQuests
    end

    for _, quest in ipairs(quests) do
        local questDescription = allQuests[quest]
        if questDescription.action == action then
            local progress = playerQuests[quest]
            if progress == -1 then
                -- Ignore
                continue
            elseif progress == nil then
                playerQuests[quest] = 1
            else
                playerQuests[quest] += 1
            end

            if playerQuests[quest] >= questDescription.amount then
                playerQuests[quest] = -1
                DataStoreModule.increaseKey(player, "cookies", questDescription.reward)
                Sounds.serverEvent:FireClient(player, "rbxassetid://1388573684")
            else
                Sounds.serverEvent:FireClient(player, "rbxassetid://76930511030201")
            end
        end
    end

    DataStoreModule.rewriteKey(player, "quests", playerQuests)
    DataStoreModule.rewriteKey(player, "questsDay", cacheDay)
end

function QuestsModule.resetAction(player: Player, action: Action)
    local quests, actions = getQuests()
    if actions[action] ~= true then
        return
    end

    local playerQuests = questsPerPlayer[player]
    if playerQuests == nil then
        -- Quests didn't load yet
        return
    end

    for _, quest in ipairs(quests) do
        local questDescription = allQuests[quest]
        if questDescription.action == action then
            local progress = playerQuests[quest]
            if progress == -1 then
                -- Ignore
            else
                playerQuests[quest] = 0
            end
        end
    end

    DataStoreModule.rewriteKey(player, "quests", playerQuests)
    DataStoreModule.rewriteKey(player, "questsDay", cacheDay)
end

local function broadcastQuestsToAll()
    cachedQuests = nil
    cachedActions = nil
    cacheDay = 0
    local quests, _ = getQuests()
    local questsDescriptions: {[string]: Quest} = {}
    for _, q in ipairs(quests) do
        questsDescriptions[q] = allQuests[q]
    end

    SyncQuestsEvent:FireAllClients(questsDescriptions, quests)
end

local function startDailySyncTask()
    task.spawn(function()
        while true do
            local now = os.time()
            local nextMidnight = (math.floor(now / 86400) + 1) * 86400
            local waitSeconds = nextMidnight - now + 2

            if waitSeconds <= 0 then
                waitSeconds = 1
            end

            task.wait(waitSeconds)

            local ok, err = pcall(function()
                broadcastQuestsToAll()
            end)
            if not ok then
                warn("Daily quest broadcast failed:", err)
            end
        end
    end)
end

function QuestsModule.init()
    Players.PlayerAdded:Connect(function(player)
        local quests, _ = getQuests()
        local questsDescriptions: {[string]: Quest} = {}
        for _, quest in ipairs(quests) do
            questsDescriptions[quest] = allQuests[quest]
        end
        SyncQuestsEvent:FireClient(player, questsDescriptions, quests)
    end)

    DataStoreModule.getSignal("quests").Event:Connect(function(player, value)
        local day = math.floor(os.time() / 86400)

        if DataStoreModule.getNumber(player, "questsDay") ~= day then
            questsPerPlayer[player] = {}
            DataStoreModule.rewriteKey(player, "quests", {})
            DataStoreModule.rewriteKey(player, "questsDay", day)
        else
            questsPerPlayer[player] = value
        end
    end)

    broadcastQuestsToAll()
    startDailySyncTask()
end

return QuestsModule