--!strict
--!optimize 2

local BadgeService = game:GetService("BadgeService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local DataStoreModule = require(ServerScriptService.Server.Shared.DataStoreModule)
local Promise = require(ReplicatedStorage.Shared.Promise)
local GameState = {}

local logAction = require(ServerScriptService.Server.Shared.QuestsModule).logAction
local RewardChanged: BindableEvent = Instance.new("BindableEvent")

local rewards: {[Player]: number} = {}
local rewardMultipliers: {[Player]: number} = {}

GameState.RewardChanged = RewardChanged
GameState.rewardMultipliers = rewardMultipliers

local function getFriendsInServer(player: Player): number
    local count = 0

    for _, other: Player in Players:GetPlayers() do
        if other ~= player and player:IsFriendsWithAsync(other.UserId) then
            count += 1
        end
    end

    return count
end

local function getCashMultiplier(friends: number): number
    if friends <= 0 then
        return 1
    elseif friends == 1 then
        return 1.15
    elseif friends == 2 then
        return 1.3
    else
        return 1.5
    end
end

function GameState.setupMultipliersAndFriendQuest()
    for i, player in Players:GetPlayers() do
        local friends = getFriendsInServer(player)
        rewardMultipliers[player] = getCashMultiplier(friends)
        if friends > 0 then
            logAction(player, "play_with_friends")
        end
        if friends >= 2 then
            logAction(player, "play_with_2_friends")
        end
    end
end

local function withJitter(baseDelay: number)
    return baseDelay + math.random() * 2.0
end

function GameState.rewardBadge(player: Player, id: number): Promise.TypedPromise<nil>
    return Promise.retryWithDelay(function()
        return Promise.promisify(function()
            if not BadgeService:UserHasBadgeAsync(player.UserId, id) then
                BadgeService:AwardBadgeAsync(player.UserId, id)
            end
        end)()
    end, 5, withJitter(15))
end

function GameState.addRewardTo(player: Player, amount: number)
    amount *= rewardMultipliers[player] or 1
    if rewards[player] == nil then
        rewards[player] = amount
    else
        rewards[player] += amount
    end
    RewardChanged:Fire(player, rewards[player])
end

function GameState.flushReward(player: Player)
    if rewards[player] == nil then
        return
    end
    local cash = rewards[player]
    rewards[player] = nil
    DataStoreModule.increaseKey(player, "cash", math.ceil(cash))
    RewardChanged:Fire(player, 0)
end

return GameState