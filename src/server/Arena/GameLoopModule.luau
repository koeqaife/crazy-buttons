local Arena = game:GetService("ServerScriptService").Server.Arena
local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local Promise = require(ReplicatedStorage.Shared.Promise)
local ButtonsModule = require(script.Parent.ButtonsModule)
local EventType = require(ServerScriptService.Server.Arena.Events.EventType)
local DataStoreModule = require(ServerScriptService.Server.Shared.DataStoreModule)
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
local TwoKnowsEvent = require(Arena.Events.TwoKnowsEvent)
local MazeEvent = require(Arena.Events.MazeEvent)
local ObbyEvent = require(Arena.Events.ObbyEvent)

local EXPERIMENT_BADGE_ID = 4390814557028274

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
    LinkedEvent,
    TwoKnowsEvent,
    MazeEvent,
    ObbyEvent
}

local eventCounts: {[Event]: number} = {}
local forcedNextEvent: { event: Event, by: Player }? = nil
local lastEventCategory: string? = nil

local eventCooldown: {[Event]: number} = {}
local EVENT_COOLDOWN = 3

local function checkEvent(event: Event)
    local players = #GameState.alivePlayers
    local round = GameState.round
    local count = eventCounts[event] or 0
    return (not event.minPlayers or players >= event.minPlayers)
            and (not event.maxPlayers or players <= event.maxPlayers)
            and (not event.minRound or round >= event.minRound)
            and (not event.maxRound or round <= event.maxRound)
            and (not event.maxPerGame or count < event.maxPerGame)
            and event.check()
            and (not lastEventCategory or event.category ~= lastEventCategory)
            and (not eventCooldown[event] or round >= eventCooldown[event])
end

local function chooseRandomEvent(): Event?
    local validEvents: {Event} = {}

    for _, event in ipairs(events) do
        if checkEvent(event) then
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

    TextModule.setContext(event.name)
    TimerModule.setTime(-1)
    GameState.cancelAll()
    task.wait()
    task.wait()
    task.wait()
    task.wait()
    GameState.destroyInstances()
    GameState.runButtonsForDead()
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
        TextModule.setContext("misc")
        GameState.runFuncPerAlive(function(player)
            TextModule.setText(player, "error_occurred")
        end)

        task.wait(5)
    end
end

local function processReceipt(receiptInfo: {PlayerId: number, ProductId: number})
    if receiptInfo.ProductId == 3546841437 then
        local player = Players:GetPlayerByUserId(receiptInfo.PlayerId)
        if not player then
            return Enum.ProductPurchaseDecision.NotProcessedYet
        end

        if GameState.forceReviveIsAllowed(player) then
            forcedNextEvent = { event = ReviveEvent, by = player }
        else
            DataStoreModule.addPendingRevives(player, 1):await()
        end
        return Enum.ProductPurchaseDecision.PurchaseGranted
    end

    return Enum.ProductPurchaseDecision.NotProcessedYet
end

local function onForceReviveButton(player: Player)
    if player == nil or player.Parent == nil then
        return
    end

    if forcedNextEvent ~= nil then
        return
    end

    if not GameState.forceReviveIsAllowed(player) then
        return
    end

    if DataStoreModule.getPendingRevives(player) > 0 then
        DataStoreModule.addPendingRevives(player, -1):await()
        forcedNextEvent = { event = ReviveEvent, by = player }
    else
        MarketplaceService:PromptProductPurchase(player, 3546841437)
    end
end

local function dumpState()
    print("Round: ", GameState.round)
    print("Last event category: ", lastEventCategory)
    for _, event in ipairs(events) do
        print(
            "EVENT: " .. event.name,
            "| Category: " .. event.category,
            "| Chance: " .. tostring(event.chance),
            "| Min/Max players: " .. tostring(event.minPlayers) .. "/" .. tostring(event.maxPlayers),
            "| Min/Max round: " .. tostring(event.minRound) .. "/" .. tostring(event.maxRound),
            "| CanRun: " .. tostring(checkEvent(event))
        )
    end
end

local function dumpPlayers()
    print("ALIVE PLAYERS:", #GameState.alivePlayers)
    for _, player in ipairs(GameState.alivePlayers) do
        print("  ", player.Name)
    end

    print("DEAD PLAYERS:", #GameState.deadPlayers)
    for _, player in ipairs(GameState.deadPlayers) do
        print("  ", player.Name)
    end
end

function GameLoopModule.start()
    _G.dumpState = dumpState
    _G.dumpPlayers = dumpPlayers
    _G.cancelAll = GameState.cancelAll
    _G.kill = GameState.kill
    _G.revive = GameState.revive

    for _, player in ipairs(Players:GetPlayers()) do
        table.insert(GameState.alivePlayers, player)

        -- TODO: Remove after beta/alpha test ended
        GameState.rewardBadge(player, EXPERIMENT_BADGE_ID):catch(warn):await()
    end

    GameState.ForceRevive.Event:Connect(onForceReviveButton)
    MarketplaceService.ProcessReceipt = processReceipt

    task.spawn(function()
        runEvent(ComboEvent)
        runEvent(StartEvent)

        while #GameState.alivePlayers > 0 do
            GameState.round += 1

            if #GameState.alivePlayers <= 4 then
                GameState.clearLinkedPlayers()
            end

            local nextEvent: Event? = nil
            if forcedNextEvent then
                if forcedNextEvent.event == ReviveEvent and not GameState.forceReviveIsAllowed() then
                    TextModule.setContext("misc")
                    TextModule.setText(forcedNextEvent.by, "purchase_not_processed")
                    DataStoreModule.addPendingRevives(forcedNextEvent.by, 1):await()
                    forcedNextEvent = nil
                    nextEvent = chooseRandomEvent()
                    task.wait(4)
                else
                    TextModule.setContext("misc")
                    TextModule.setText(forcedNextEvent.by, "purchase_processed")
                    nextEvent = forcedNextEvent.event
                    forcedNextEvent = nil
                    task.wait(4)
                end
            else
                nextEvent = chooseRandomEvent()
            end

            if nextEvent ~= nil then
                runEvent(nextEvent)
                eventCounts[nextEvent] = (eventCounts[nextEvent] or 0) + 1
                eventCooldown[nextEvent] = GameState.round + EVENT_COOLDOWN
                lastEventCategory = nextEvent.category

                if #GameState.alivePlayers > 1 then
                    GameState.runFuncPerAll(function(player)
                        TextModule.setContext("misc")
                        TextModule.setText(player, "players_left", {count = #GameState.alivePlayers})
                    end)

                    task.wait(10)
                end
            else
                lastEventCategory = nil
            end
        end

        if forcedNextEvent then
            TextModule.setContext("misc")
            TextModule.setText(forcedNextEvent.by, "purchase_not_processed")
            if forcedNextEvent.event == ReviveEvent then
                DataStoreModule.addPendingRevives(forcedNextEvent.by, 1):await()
            end
        end
    end)
end

return GameLoopModule