--!strict
--!optimize 2

local UIModule = {}
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local GameStateModule = require(script.Parent.GameStateModule)
local DataStoreModule = require(ServerScriptService.Server.Shared.DataStoreModule)

local SyncEvent = Instance.new("RemoteEvent", ReplicatedStorage)
SyncEvent.Name = "SyncEvent"

function UIModule.sendMultipliers()
    for player, multiplier in GameStateModule.rewardMultipliers do
        SyncEvent:FireClient(player, "multiplier", math.round(multiplier * 100) / 100)
    end
end

function UIModule.init()
    DataStoreModule.getSignal("cash").Event:Connect(function(player: Player, newAmount: number)
        SyncEvent:FireClient(player, "cash", newAmount)
    end)

    DataStoreModule.getSignal("cookies").Event:Connect(function(player: Player, new: any)
        SyncEvent:FireClient(player, "cookies", new)
    end)

    DataStoreModule.getSignal("quests").Event:Connect(function(player: Player, new: any)
        SyncEvent:FireClient(player, "quests", new)
    end)

    GameStateModule.RewardChanged.Event:Connect(function(player: Player, amount: number?)
        if amount then
            SyncEvent:FireClient(player, "reward", math.round(amount * 10) / 10)
        end
    end)

    Players.PlayerAdded:Connect(function(player)
        if not DataStoreModule.dataLoaded(player) then
            return
        end
        SyncEvent:FireClient(player, "cash", DataStoreModule.getNumber(player, "cash"))
        SyncEvent:FireClient(player, "cookies", DataStoreModule.getNumber(player, "cookies"))
        SyncEvent:FireClient(player, "quests", DataStoreModule.getAny(player, "quests"))
    end)
end

return UIModule