local Arena = game:GetService("ServerScriptService").Server.Arena
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local Promise = require(ReplicatedStorage.Shared.Promise)
local ButtonsModule = require(script.Parent.ButtonsModule)
local EventType = require(ServerScriptService.Server.Arena.Events.EventType)
local GameState = require(Arena.GameStateModule)
local TimerModule = require(Arena.TimerModule)
local AmbienceModule = require(Arena.AmbienceModule)
local TextModule = require(Arena.TextModule)
local GameLoopModule = {}

type Event = EventType.Event

local StartEvent = require(Arena.Events.StartEvent)
local ColorEvent = require(Arena.Events.ColorEvent)
local VoteEvent = require(Arena.Events.VoteEvent)
local SimonEvent = require(Arena.Events.SimonEvent)
local MathEvent = require(Arena.Events.MathEvent)
local ClickEvent = require(Arena.Events.ClickEvent)
local ReviveEvent = require(Arena.Events.ReviveEvent)
local ClickFirstEvent = require(Arena.Events.ClickFirstEvent)
local ComboEvent = require(Arena.Events.ComboEvent)
local AlienEvent = require(Arena.Events.AlienEvent)
local SacrificeEvent = require(Arena.Events.SacrificeEvent)
local GodBtnEvent = require(Arena.Events.GodBtnEvent)
local HandoutEvent = require(Arena.Events.HandoutEvent)
local EvenOddEvent = require(Arena.Events.EvenOddEvent)
local SplitOrStealEvent = require(Arena.Events.SplitOrStealEvent)
local AttackDefendTrustEvent = require(Arena.Events.AttackDefendTrustEvent)
local YouSurvivedEvent = require(Arena.Events.YouSurvivedEvent)
local DuelEvent = require(Arena.Events.DuelEvent)
local LinkedEvent = require(Arena.Events.LinkedEvent)

local events: {Event} = {
    ColorEvent,
    VoteEvent,
    SimonEvent,
    MathEvent,
    ClickEvent,
    ReviveEvent,
    ClickFirstEvent,
    ComboEvent,
    AlienEvent,
    SacrificeEvent,
    GodBtnEvent,
    HandoutEvent,
    EvenOddEvent,
    SplitOrStealEvent,
    AttackDefendTrustEvent,
    YouSurvivedEvent,
    DuelEvent,
    LinkedEvent
}
local eventCounts: {[Event]: number} = {}

local function chooseRandomEvent(): Event?
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

local function runEvent(event: Event?)
    if event == nil then
        return
    end

    TimerModule.setTime(-1)
    AmbienceModule.stopAll()
    GameState.runFuncPerAlive(function(player)
        ButtonsModule.setButtons(player, {})
    end)
    GameState.removeHighlightFromAll()

    local promise = Promise.promisify(event.onEvent)()
    local ok, result = promise:await()
    if not ok then
        promise:cancel()
        warn("Event failed: ", result)

        GameState.cancelAll()
        GameState.runFuncPerAlive(function(player)
            TextModule.setText(player, "An error occurred...", "dead")
        end)
        task.wait(5)
    end
end

function GameLoopModule.start()
    for _, player in ipairs(Players:GetPlayers()) do
        table.insert(GameState.alivePlayers, player)
    end
    task.spawn(function()
        runEvent(StartEvent)

        while #GameState.alivePlayers > 0 do
            GameState.round += 1

            local nextEvent = chooseRandomEvent()
            if nextEvent ~= nil then
                runEvent(nextEvent)
                eventCounts[nextEvent] = (eventCounts[nextEvent] or 0) + 1
            end

            GameState.runFuncPerAlive(function(player)
                TextModule.setText(player, "", "normal")
            end)

            task.wait(3)
        end
    end)
end

return GameLoopModule