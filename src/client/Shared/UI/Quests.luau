--!strict
--!optimize 2
local LeftButtons = {}

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local localPlayer = Players.LocalPlayer

local Spring = require(ReplicatedStorage.Shared.spr)
local State = require(localPlayer.PlayerScripts.Client.Shared.UI.State)

local window = localPlayer:WaitForChild("PlayerGui"):WaitForChild("ScreenGui"):WaitForChild("QuestsFrame") :: Frame
local hideButton = window:WaitForChild("Hide") :: TextButton
local container = window:WaitForChild("Container") :: Frame
local template = container:WaitForChild("Template") :: Frame
local SyncQuestsEvent = ReplicatedStorage:WaitForChild("SyncQuestsEvent") :: RemoteEvent

local QUESTS_COUNT = 3
template.Visible = false

type Quest = {
    description: string,
    action: string,
    amount: number,
    reward: number
}

export type QuestWidget = {
    widget_id: string,
    quest_id: string?,
    quest: Quest?,
    frame: Frame & {
        NameLabel: TextLabel,
        Reward: Frame & {
            ImageLabel: ImageLabel,
            Result: TextLabel,
            Cookies: TextLabel
        }
    }
} & State.Widget

export type QuestsWindowWidget = {
    isShown: boolean,
    frame: Frame & {
        Hide: TextButton & {
            ImageLabel: ImageLabel
        },
        Container: Frame & {
            Header: Frame & {
                ResetsLabel: TextLabel
            }
        }
    }
} & State.Widget

local function updatePosition(id: string, widget: QuestsWindowWidget)
    -- Updates both frame anchor point and button icon rotation
    if widget.isShown then
        Spring.target(widget.frame, 1.4, 6, { AnchorPoint = Vector2.new(1, 0.5) })
        Spring.target(widget.frame.Hide.ImageLabel, 0.6, 2, { Rotation = 0 })
    else
        Spring.target(widget.frame, 0.6, 3, { AnchorPoint = Vector2.new(0.0853, 0.5) })
        Spring.target(widget.frame.Hide.ImageLabel, 0.6, 2, { Rotation = -180 })
    end
end

local function updateQuest(id: string, widget: QuestWidget)
    if not widget.quest or not widget.quest_id then
        return
    end

    widget.frame.NameLabel.Text = widget.quest.description
    widget.frame.Reward.Cookies.Text = tostring(widget.quest.reward)

    local num = State.quests[widget.quest_id]
    if num == -1 then
        widget.frame.Reward.Result.Text = "Completed"
    else
        widget.frame.Reward.Result.Text = tostring(num or 0) .. " / " .. tostring(widget.quest.amount)
    end
end

local function getTimeUntilNextDay()
    local now = os.time()
    local nextMidnight = (math.floor(now / 86400) + 1) * 86400
    local diff = nextMidnight - now
    if diff < 0 then
        diff = 0
    end
    return diff
end

local function formatTime(seconds: number)
    local hours = math.floor(seconds / 3600)
    local minutes = math.floor((seconds % 3600) / 60)
    local secs = seconds % 60
    return string.format("%02d:%02d:%02d", hours, minutes, secs)
end

function LeftButtons.initialize()
    local widget: QuestsWindowWidget = {
        frame = window :: any,
        isShown = false,
        customHandler = updatePosition
    }

    hideButton.Activated:Connect(function(inputObject, clickCount)
        widget.isShown = not widget.isShown
        State.invalidate("quests_frame")
    end)

    State.addWidget("quests_frame", widget)

    task.spawn(function()
        while true do
            if not widget.isShown then
                task.wait(2)
                continue
            end
            local secondsLeft = getTimeUntilNextDay()
            widget.frame.Container.Header.ResetsLabel.Text = formatTime(secondsLeft)
            task.wait(1)
        end
    end)

    local widgets: {QuestWidget} = {}
    for i = 1, QUESTS_COUNT, 1 do
        local frame = template:Clone()
        frame.Name = "quest_" .. i
        frame.Visible = true
        frame.Parent = container
        frame.LayoutOrder = i

        local questWidget: QuestWidget = {
            customHandler = updateQuest,
            widget_id = "quest_" .. i,
            frame = frame :: any
        }

        table.insert(widgets, questWidget)
        State.addWidget(questWidget.widget_id, questWidget)
    end

    SyncQuestsEvent.OnClientEvent:Connect(function(quests: {[string]: Quest}, order: {string})
        for i, questId in ipairs(order) do
            local questWidget = widgets[i]
            questWidget.quest_id = questId
            questWidget.quest = quests[questId]
            State.invalidate(questWidget.widget_id)
        end
    end)

    State.QuestsUpdated.Event:Connect(function()
        -- I will update all cause I'm too lazy...
        for i = 1, QUESTS_COUNT, 1 do
            State.invalidate("quest_" .. i)
        end
    end)
end

return LeftButtons