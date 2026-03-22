local Arena = game:GetService("ServerScriptService").Server.Arena
local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local TeleportService = game:GetService("TeleportService")
local Promise = require(ReplicatedStorage.Shared.Promise)
local ButtonsModule = require(script.Parent.ButtonsModule)
local LinksModule = require(script.Parent.LinksModule)
local MiscModule = require(script.Parent.MiscModule)
local PlayersModule = require(script.Parent.PlayersModule)
local RewardsModule = require(script.Parent.RewardsModule)
local SideEffects = require(script.Parent.SideEffects)
local EventType = require(ServerScriptService.Server.Arena.Events.EventType)
local DataStoreModule = require(ServerScriptService.Server.Shared.DataStoreModule)
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
local FiveButtonsEvent = require(Arena.Events.FiveButtonsEvent)

local EXPERIMENT_BADGE_ID = 4390814557028274
local LOBBY_PLACE_ID = 115379867051786

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
    ObbyEvent,
    FiveButtonsEvent
}

local eventCounts: {[Event]: number} = {}
local forcedNextEvent: { event: Event, by: Player }? = nil
local lastEventCategory: string? = nil

local eventCooldown: {[Event]: number} = {}
local EVENT_COOLDOWN = 3

local function checkEvent(event: Event)
    local players = #PlayersModule.alivePlayers
    local round = MiscModule.round
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

local function onForceReviveButton(player: Player)
    if player == nil or player.Parent == nil then
        return
    end

    if forcedNextEvent ~= nil then
        return
    end

    if not PlayersModule.forceReviveIsAllowed(player) then
        return
    end

    if DataStoreModule.getNumber(player, "pendingRevives") > 0 then
        DataStoreModule.increaseKey(player, "pendingRevives", -1)
        forcedNextEvent = { event = ReviveEvent, by = player }
    else
        MarketplaceService:PromptProductPurchase(player, 3546841437)
    end
end

local function runButtonsForDead()
    PlayersModule.runNewPromisePerDead(function(player, protect, await)
        local function clearButtons()
            ButtonsModule.setButtons(player, {})
        end

        PlayersModule.protect(player, Promise.new(function(resolve2, reject, onCancel)
            if PlayersModule.forceReviveIsAllowed(player) then
                local forceReviveText = "Force Random Revive"
                if DataStoreModule.getNumber(player, "pendingRevives") > 0 then
                    forceReviveText = "Force Random Revive (Bought)"
                end

                ButtonsModule.setButtons(player, {
                    { idx = 3, text = forceReviveText },
                    { idx = 5, text = "Return to lobby" }
                })
            else
                ButtonsModule.setButtons(player, {
                    { idx = 5, text = "Return to lobby" }
                })
            end

            task.wait(0.75)  -- Wait a bit to make sure they don't click it accidentally
            local clickPromise = ButtonsModule.waitForClick(player, -1)
            onCancel(function()
                clickPromise:cancel()
                clearButtons()
            end)

            local _, clickedIdx = clickPromise:catch(error):await()
            clearButtons()

            if clickedIdx == 5 then
                ButtonsModule.setButtons(player, {
                    { idx = 5, text = "Teleporting...", inputDisabled = true }
                })
                TeleportService:Teleport(LOBBY_PLACE_ID, player)
                resolve2()
            elseif clickedIdx == 3 then
                onForceReviveButton(player)
                resolve2()
            end
        end)):catch(warn)
    end)
end

local function runEvent(event: Event?)
    if event == nil then
        return
    end

    SideEffects.setSupportedEffects(event.supportedEffects or {})
    TextModule.setContext(event.name)
    TimerModule.setTime(-1)
    PlayersModule.cancelAll()
    task.wait()
    task.wait()
    task.wait()
    task.wait()
    MiscModule.destroyInstances()
    runButtonsForDead()
    AmbienceModule.stopAll()
    PlayersModule.runFuncPerAlive(function(player)
        ButtonsModule.setButtons(player, {})
    end)
    MiscModule.removeHighlightFromAll()

    local promise = Promise.promisify(event.onEvent)()
    local ok, result = promise:await()
    if not ok then
        promise:cancel()
        warn("Event failed: ", result)

        PlayersModule.cancelAll()
        TextModule.setContext("misc")
        PlayersModule.runFuncPerAlive(function(player)
            TextModule.setText(player, "error_occurred")
        end)

        task.wait(5)
    end
    PlayersModule.updateLists()
end

local function processReceipt(receiptInfo: {PlayerId: number, ProductId: number})
    if receiptInfo.ProductId == 3546841437 then
        local player = Players:GetPlayerByUserId(receiptInfo.PlayerId)
        if not player then
            return Enum.ProductPurchaseDecision.NotProcessedYet
        end

        if PlayersModule.forceReviveIsAllowed(player) then
            forcedNextEvent = { event = ReviveEvent, by = player }
        else
            DataStoreModule.increaseKey(player, "pendingRevives", 1)
        end
        return Enum.ProductPurchaseDecision.PurchaseGranted
    end

    return Enum.ProductPurchaseDecision.NotProcessedYet
end

local function dumpState()
    print("Round: ", MiscModule.round)
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
    print("ALIVE PLAYERS:", #PlayersModule.alivePlayers)
    for _, player in ipairs(PlayersModule.alivePlayers) do
        print("  ", player.Name)
    end

    print("DEAD PLAYERS:", #PlayersModule.deadPlayers)
    for _, player in ipairs(PlayersModule.deadPlayers) do
        print("  ", player.Name)
    end
end

function GameLoopModule.start()
    _G.dumpState = dumpState
    _G.dumpPlayers = dumpPlayers
    _G.cancelAll = PlayersModule.cancelAll
    _G.kill = PlayersModule.kill
    _G.revive = PlayersModule.revive

    for _, player in ipairs(Players:GetPlayers()) do
        -- TODO: Remove after beta/alpha test ended
        RewardsModule.rewardBadge(player, EXPERIMENT_BADGE_ID):catch(warn):await()
    end

    PlayersModule.OnPlayerLostLife.Event:Connect(function(player: Player)
        ButtonsModule.setButtons(player, {})
    end)

    PlayersModule.OnPlayerDied.Event:Connect(function(player: Player)
        task.wait()
        task.wait()
        task.wait()
        task.wait()
        runButtonsForDead()
        RewardsModule.flushReward(player)
    end)

    Players.PlayerRemoving:Connect(function(player, reason)
        RewardsModule.flushReward(player)
    end)

    MarketplaceService.ProcessReceipt = processReceipt

    task.spawn(function()
        runEvent(StartEvent)

        while #PlayersModule.alivePlayers > 0 do
            MiscModule.round += 1

            if #PlayersModule.alivePlayers <= 4 then
                LinksModule.clearLinkedPlayers()
            end

            local nextEvent: Event? = nil
            local test = {SimonEvent, FiveButtonsEvent, GodBtnEvent}
            forcedNextEvent = runEvent(test[math.random(1, 3)])
            if forcedNextEvent then
                if forcedNextEvent.event == ReviveEvent and not PlayersModule.forceReviveIsAllowed() then
                    TextModule.setContext("misc")
                    TextModule.setText(forcedNextEvent.by, "purchase_not_processed")
                    DataStoreModule.increaseKey(forcedNextEvent.by, "pendingRevives", 1)
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
                eventCooldown[nextEvent] = MiscModule.round + EVENT_COOLDOWN
                lastEventCategory = nextEvent.category

                if #PlayersModule.alivePlayers > 1 then
                    PlayersModule.runFuncPerAll(function(player)
                        TextModule.setContext("misc")
                        TextModule.setText(player, "players_left", {count = #PlayersModule.alivePlayers})
                    end)

                    task.wait(5)
                end
            else
                lastEventCategory = nil
            end
        end

        if forcedNextEvent then
            TextModule.setContext("misc")
            TextModule.setText(forcedNextEvent.by, "purchase_not_processed")
            if forcedNextEvent.event == ReviveEvent then
                DataStoreModule.increaseKey(forcedNextEvent.by, "pendingRevives", 1)
            end
        end
    end)
end

return GameLoopModule