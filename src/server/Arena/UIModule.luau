--!strict
--!optimize 2

local UIModule = {}
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local GameStateModule = require(script.Parent.GameStateModule)
local DataStoreModule = require(ServerScriptService.Server.Shared.DataStoreModule)

local SyncEvent = Instance.new("RemoteEvent", ReplicatedStorage)
SyncEvent.Name = "SyncEvent"

function UIModule.sendMultipliers()
    for player, multiplier in GameStateModule.rewardMultipliers do
        SyncEvent:FireClient(player, "multiplier", math.round(multiplier * 10) / 10)
    end
end

function UIModule.init()
    DataStoreModule.getSignal("cash").Event:Connect(function(player: Player, newAmount: number)
        SyncEvent:FireClient(player, "cash", newAmount)
    end)

    GameStateModule.RewardChanged.Event:Connect(function(player: Player, amount: number?)
        if amount then
            SyncEvent:FireClient(player, "reward", math.round(amount * 10) / 10)
        end
    end)
end

return UIModule