local Arena = game:GetService("ServerScriptService").Server.Arena
local Players = game:GetService("Players")
local ServerScriptService = game:GetService("ServerScriptService")
local ButtonsModule = require(script.Parent.ButtonsModule)
local EventType = require(ServerScriptService.Server.Arena.Events.EventType)
local GameState = require(Arena.GameStateModule)
local GameLoopModule = {}

type Event = EventType.Event

local StartEvent = require(Arena.Events.StartEvent)
local ColorEvent = require(Arena.Events.ColorEvent)
local VoteEvent = require(Arena.Events.VoteEvent)

local events: {Event} = {
    ColorEvent,
    VoteEvent
}
local eventCounts: {[Event]: number} = {}

local function chooseRandomEvent()
    local validEvents: {Event} = {}
    local players = #GameState.alivePlayers
    local round = GameState.round

    for _, event in ipairs(events) do
        local count = eventCounts[event] or 0

        if (not event.minPlayers or players >= event.minPlayers)
            and (not event.maxPlayers or players <= event.maxPlayers)
            and (not event.minRound or round >= event.minRound)
            and (not event.maxRound or round <= event.maxRound)
            and (not event.maxPerGame or count < event.maxPerGame)
            and event.check()
        then
            table.insert(validEvents, event)
        end
    end

    if #validEvents == 0 then
        return nil
    end

    local totalChance = 0
    for _, event in ipairs(validEvents) do
        totalChance += event.chance
    end

    local threshold = math.random() * totalChance
    local cumulative = 0

    for _, event in ipairs(validEvents) do
        cumulative += event.chance
        if threshold <= cumulative then
            return event
        end
    end

    return validEvents[#validEvents]
end


function GameLoopModule.start()
    for _, player in ipairs(Players:GetPlayers()) do
        table.insert(GameState.alivePlayers, player)
    end
    task.spawn(function()
        StartEvent.onEvent():await()

        while #GameState.alivePlayers > 0 do
            GameState.round += 1
            local nextEvent = chooseRandomEvent()
            if nextEvent then
                local ok, result = nextEvent.onEvent():await()
                if not ok then
                    error(result)
                end
                eventCounts[nextEvent] = (eventCounts[nextEvent] or 0) + 1
            end

            GameState.runFuncPerAlive(function(player)
                ButtonsModule.setButtons(player, {})
            end)

            task.wait()
        end
    end)
end

return GameLoopModule