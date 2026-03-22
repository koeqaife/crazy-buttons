--!strict
--!optimize 2
local ServerScriptService = game:GetService("ServerScriptService")

-- Description:
-- Event that is always first
-- Kills those who didn't click the button

local Arena = game:GetService("ServerScriptService").Server.Arena
local PlayersModule = require(ServerScriptService.Server.Arena.PlayersModule)
local SideEffects = require(ServerScriptService.Server.Arena.SideEffects)
local DataStoreModule = require(ServerScriptService.Server.Shared.DataStoreModule)
local SpecialRounds = require(ServerScriptService.Server.Shared.SpecialRounds)
local ButtonsModule = require(Arena.ButtonsModule)
local EventTypeModule = require(Arena.Events.EventType)
local TextModule = require(Arena.TextModule)

type EventType = EventTypeModule.Event

local Event = {} :: EventType

Event.chance = 1.0
Event.maxRound = 1
Event.name = "start"

function Event.check()
    return true
end

function Event.onEvent()
    local specialActive = SpecialRounds.isActive()
    if specialActive then
        SideEffects.activateSideEffect("special")
    end

    local promise = PlayersModule.runPromisePerAlive(function(player, protect, await)
        return protect(TextModule.showTextSequence(player, {
            { key = "intro_hey", data = { player = player }, delay = 4 },
            { key = "intro_button_experiment", delay = 5 },
            { key = "intro_tested", delay = 6 },
            { key = "intro_easy_hard", delay = 7 },
        }))
    end):catch(error)

    PlayersModule.runFuncPerAlive(function(player)
        ButtonsModule.setButtons(player, {
            { idx = 5, text = "Skip" }
        })
    end)

    ButtonsModule.initiateButtonChoice(25, nil, nil, nil, true, PlayersModule.alivePlayers):catch(error):await()
    PlayersModule.cancelAll()
    promise:cancel()
    task.wait()
    task.wait()
    task.wait()
    task.wait()

    PlayersModule.runFuncPerAlive(function(player)
        DataStoreModule.increaseKey(player, "timesPlayed", 1)
    end)

    if specialActive then
        local randomEffects = SideEffects.getRandom(3)
        PlayersModule.runNewPromisePerAlive(function(player, protect, await)
            await(TextModule.showTextSequence(player, {
                { key = "intro_special", delay = 5 },
                { key = "intro_special2", delay = 5 },
            }))

            for i, effect in ipairs(randomEffects) do
                await(TextModule.showTextSequence(player, {
                    { key = "special_text", delay = 5, data = {text = effect.name} },
                    { key = "special_text2", delay = 5, data = {text = effect.description} },
                }))
            end
        end):catch(error):await()

        local ids = {}
        for _, effect in randomEffects do
            table.insert(ids, effect.id)
        end

        SideEffects.activateManySideEffects(ids)
    end

    PlayersModule.runFuncPerAlive(function(player)
        TextModule.setText(player, "intro_begin")
    end)
    task.wait(3)

    return
end

return Event