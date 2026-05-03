--!strict
--!optimize 2

local Module = {}

local MessagingService = game:GetService("MessagingService")
local DataStoreService = game:GetService("DataStoreService")
local HttpService = game:GetService("HttpService")

local StatsStore = DataStoreService:GetDataStore("GlobalArenaStats")
local TODAY_KEY = os.date("!%Y-%m-%d")
local universeId = game.GameId

local lastPlaying = -1
local lastVisits = -1

Module.updateEvent = Instance.new("BindableEvent")

export type Stats = {
    roundsToday: number,
    lastWinner: string,
    onlineNow: number,
    visits: number,
    loaded: boolean
}

-- Local cache to keep track of numbers without hitting DataStore every second
local globalStats: Stats = {
    roundsToday = 0,
    lastWinner = "None",
    onlineNow = 0,
    visits = 0,
    loaded = false
}

Module.stats = globalStats

local function getExperienceData()
    local url = "https://games.roproxy.com/v1/games?universeIds=" .. universeId
    local success, response = pcall(function()
        return HttpService:GetAsync(url)
    end)
    if success then
        local data = HttpService:JSONDecode(response)
        if data and data.data and data.data[1] then
            return data
        end
    else
        warn("Failed to fetch player count: " .. tostring(response))
    end
    return nil
end

local function getGlobalPlayerCount()
    local data = getExperienceData()
    if data == nil then
        return lastPlaying, lastVisits
    end

    local playing = data.data[1].playing
    local visits = data.data[1].visits
    lastPlaying = playing
    lastVisits = visits
    return playing, visits
end

function Module.onRoundEnd(winnerName: string)
    pcall(function()
        StatsStore:IncrementAsync(TODAY_KEY .. "_Rounds", 1)
        StatsStore:SetAsync(TODAY_KEY .. "_lastWinner", winnerName)
    end)

    local data = {
        winner = winnerName,
        msgType = "RoundUpdate"
    }
    MessagingService:PublishAsync("ArenaLiveFeed", data)
end

function Module.startTask()
    MessagingService:SubscribeAsync("ArenaLiveFeed", function(message)
        local data = message.Data
        if data.msgType == "RoundUpdate" then
            globalStats.lastWinner = data.winner
            globalStats.roundsToday += 1
            Module.updateEvent:Fire(globalStats)
        end
    end)

    task.spawn(function()
        local success, count = pcall(function()
            return StatsStore:GetAsync(TODAY_KEY .. "_Rounds")
        end)
        if success and count then
            globalStats.roundsToday = count
        end

        local success2, name = pcall(function()
            return StatsStore:GetAsync(TODAY_KEY .. "_lastWinner")
        end)
        if success2 and name then
            globalStats.lastWinner = name
        end
    end)

    task.spawn(function()
        while true do
            local playing, visits = getGlobalPlayerCount()
            globalStats.onlineNow = playing or 0
            globalStats.visits = visits or 0
            globalStats.loaded = true

            Module.updateEvent:Fire(globalStats)
            task.wait(10)
        end
    end)
end

return Module