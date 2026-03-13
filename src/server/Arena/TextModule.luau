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

local UpdateTextEvent = Instance.new("RemoteEvent", ReplicatedStorage)
UpdateTextEvent.Name = "UpdateTextEvent"

local globalType = "default"
local globalContext = "misc"
local replicasPerPlayer: {[Player]: {[string]: {[string]: Format.Template}}} = {}

local function loadReplicas(player: Player, type: string, language: string)
    if (DataStoreModule.getCash(player) or 0) < 10 then
        type = "default"
    end
    local typeFolder = Replicas[type]()
    local languageLoad = typeFolder[language] or typeFolder["english"]
    replicasPerPlayer[player] = languageLoad()
end

local function fire(player: Player, text: string, face: Format.Face?)
     UpdateTextEvent:FireClient(player, text, face)
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
    local replica = replicasPerPlayer[player][globalContext][key]
    local formatted = Format(replica, data)
    fire(player, formatted.text, formatted.face)
end

function TextModule.setContext(value: string)
    globalContext = value
end

function TextModule.init()
    UpdateTextEvent.OnServerEvent:Connect(function(player, action: string, value: string)
        if action == "set_language" then
            loadReplicas(player, globalType, value)
        end
    end)

    -- Set random type
    local keys = {}
    for k in pairs(Replicas) do
        table.insert(keys, k)
    end

    local randomKey = keys[math.random(1, #keys)]
    globalType = randomKey

    -- Load english by default
    for i, player in Players:GetPlayers() do
        if replicasPerPlayer[player] == nil then  -- I don't trust roblox
            loadReplicas(player, globalType, "english")
        end
    end

    Players.PlayerAdded:Connect(function(player)
        if replicasPerPlayer[player] == nil then
            loadReplicas(player, globalType, "english")
        end
    end)
    DataStoreModule.CashUpdated.Event:Connect(function(player: Player)
        loadReplicas(player, globalType, "english")
    end)

    Players.PlayerRemoving:Connect(function(player, reason)
        replicasPerPlayer[player] = nil
    end)
end

return TextModule