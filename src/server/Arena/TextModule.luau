--!strict
--!optimize 2
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local Replicas = require(ServerScriptService.Server.Arena.Replicas.Module)
local Format = require(ServerScriptService.Server.Arena.Replicas.Format)
local DataStoreModule = require(ServerScriptService.Server.Shared.DataStoreModule)
local Promise = require(ReplicatedStorage.Shared.Promise)
local TextModule = {}
local applyTextTransform = require(ServerScriptService.Server.Arena.SideEffects).applyTextTransform
local applyFaceEffect = require(ServerScriptService.Server.Arena.SideEffects).applyFaceEffect

local UpdateTextEvent = Instance.new("RemoteEvent", ReplicatedStorage)
UpdateTextEvent.Name = "UpdateTextEvent"

local globalContext = "misc"
local replicasPerPlayer: {[Player]: {[string]: {[string]: Format.Template}}} = {}
local typesPerPlayer: {[Player]: string} = {}
local languagesPerPlayer: {[Player]: string} = {}

local function loadReplicas(player: Player)
    local typeFolder = Replicas[typesPerPlayer[player] or "default"]()
    local languageLoad = typeFolder[languagesPerPlayer[player] or "english"] or typeFolder["english"]
    replicasPerPlayer[player] = languageLoad()
end

local function fire(player: Player, text: string, face: Format.Face?)
     UpdateTextEvent:FireClient(player, applyTextTransform(text), applyFaceEffect(face))
end

function TextModule.translateFor(player: Player, text: string): string
    -- For in-place translations
    -- TODO: Make it work...
    return text
end

function TextModule.showTextSequence(player: Player, sequence: {{key: string, data: {[string]: any}?, delay: number?}})
    return Promise.new(function(resolve, reject, onCancel)
        local cancelled = false

        onCancel(function()
            print("Player", player.Name, "sequence was cancelled")
            cancelled = true
        end)

        for _, step in ipairs(sequence) do
            if cancelled then
                return
            end

            TextModule.setText(player, step.key, step.data)
            if step.delay then
                Promise.delay(step.delay):await()
            end
        end
        resolve()
    end)
end

function TextModule.setText(player: Player, key: string, data: {[string]: any}?)
    if replicasPerPlayer[player] == nil then
        loadReplicas(player)
    end
    local replica = replicasPerPlayer[player][globalContext][key]
    local formatted = Format(replica, data)
    fire(player, formatted.text, formatted.face)
end

function TextModule.setContext(value: string)
    globalContext = value
end

function TextModule.init()
    UpdateTextEvent.OnServerEvent:Connect(function(player: Player, action: string, value: string)
        if action == "set_language" then
            loadReplicas(player)
        end
    end)

    -- Load english by default
    for i, player in Players:GetPlayers() do
        if replicasPerPlayer[player] == nil then  -- I don't trust roblox
            loadReplicas(player)
        end
    end

    Players.PlayerAdded:Connect(function(player)
        if replicasPerPlayer[player] == nil then
            loadReplicas(player)
        end
    end)
    DataStoreModule.getSignal("timesPlayed").Event:Connect(function(player: Player, value: number)
        if typesPerPlayer[player] ~= nil then
            return
        end
        print("Loading replicas", player.Name, typesPerPlayer[player], value)
        local bag = Replicas.bag
        typesPerPlayer[player] = bag[(value % #bag) + 1]
        loadReplicas(player)
    end)

    Players.PlayerRemoving:Connect(function(player, reason)
        replicasPerPlayer[player] = nil
    end)
end

return TextModule