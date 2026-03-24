--!strict
--!optimize 2

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterPlayer = game:GetService("StarterPlayer")
local localPlayer = Players.LocalPlayer

local ScreenGui = localPlayer:WaitForChild("PlayerGui"):WaitForChild("ScreenGui") :: ScreenGui
local moneyFrame = ScreenGui:WaitForChild("Money") :: Frame
local moneyLabel = moneyFrame:WaitForChild("TextLabel") :: TextLabel
local multiplierLabel = moneyFrame:WaitForChild("MultiplierLabel") :: TextLabel
local SyncDeadEvent: RemoteEvent = ReplicatedStorage:WaitForChild("SyncDeadEvent")
local LifeEvent: RemoteEvent = ReplicatedStorage:WaitForChild("LifeEvent")

local vignette = localPlayer:WaitForChild("PlayerGui"):WaitForChild("VignetteGui"):WaitForChild("Vignette") :: CanvasGroup

local State = require(localPlayer.PlayerScripts.Client.Shared.UI.State)
local Dialog = require(localPlayer.PlayerScripts.Client.Shared.UI.Dialog)
local Quests = require(localPlayer.PlayerScripts.Client.Shared.UI.Quests)

local reward = 0
local rewardCounter = 0

local vignetteLock = false

local round = math.round

local UIModule = {}

local TweenService = game:GetService("TweenService")
local Toasts = require(StarterPlayer.StarterPlayerScripts.Client.Shared.UI.Toasts)

local function showVignette()
    if vignetteLock then
        return
    end
    vignetteLock = true
    vignette.Visible = true
    vignette.GroupTransparency = 1
    local showTweenInfo = TweenInfo.new(
        0.2,
        Enum.EasingStyle.Quad,
        Enum.EasingDirection.Out
    )

    local tween = TweenService:Create(vignette, showTweenInfo, {GroupTransparency = 0})
    tween:Play()
    tween.Completed:Wait()

    local hideTweenInfo = TweenInfo.new(2)

    local hideTween = TweenService:Create(vignette, hideTweenInfo, {GroupTransparency = 1})
    hideTween:Play()
    hideTween.Completed:Wait()
    vignette.Visible = false
    vignetteLock = false
end

function UIModule.connect()
    Quests.initialize()
    SyncDeadEvent.OnClientEvent:Connect(function(died: boolean, player: Player)
        Toasts.hide("life")
        task.wait(3)
        if died and player == localPlayer then
            Dialog.showDialog("Oh looks like you died.\nYou earned " .. rewardCounter .. "$ this game.", {{ text = "OK" }})
        end
    end)
    LifeEvent.OnClientEvent:Connect(function(show: boolean, noToast: boolean?)
        if show then
            showVignette()
            if noToast ~= true then
                Toasts.show("life", "Wait for round to finish")
            end
        else
            Toasts.hide("life")
        end
    end)

    moneyLabel.Text = tostring(State.cash) .. " (+" .. tostring(reward) .. ")"

    State.CashUpdated.Event:Connect(function(_, newValue)
        moneyLabel.Text = tostring(newValue) .. " (+" .. tostring(reward) .. ")"
    end)

    State.SyncEvent.OnClientEvent:Connect(function(key: string, value: any)
        if key == "reward" then
            if value > 0 then
                rewardCounter += value - reward
            end
            reward = round(value)
            moneyLabel.Text = tostring(State.cash) .. " (+" .. tostring(value) .. ")"
        elseif key == "multiplier" then
            multiplierLabel.Text = tostring(round(value * 100 - 100)) .. "% friend multiplier"
        end
    end)
end

return UIModule