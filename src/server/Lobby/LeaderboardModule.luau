--!strict
--!optimize 2
local ServerScriptService = game:GetService("ServerScriptService")
local DataStoreModule = require(ServerScriptService.Server.Shared.DataStoreModule)

local Leaderboard = {}
local boards: { [string]: {Frame} } = {}

local functions = {
    survives = DataStoreModule.getTopSurvives,
    streak = DataStoreModule.getTopStreak
}

local function putFrame(key: string, at: ScrollingFrame, template: Frame, rank: number, name: string, value: string)
    local clone = template:Clone()
    clone.Name = "Row"
    clone.Parent = at
    clone.Visible = true

    local playerName = clone:WaitForChild("PlayerName") :: TextLabel
    local playerCounter = clone:WaitForChild("PlayerCounter") :: TextLabel

    playerName.Text = rank .. ". " .. name
    playerCounter.Text = value

    table.insert(boards[key], clone)
end

local function clearFrames(key: string)
    for _, frame in ipairs(boards[key]) do
        frame.Parent = nil
        frame:Destroy()
    end
    table.clear(boards[key])
end

function Leaderboard.initFor(key: string, forPart: Part)
    local frame = forPart:WaitForChild("SurfaceGui"):WaitForChild("ScrollingFrame") :: ScrollingFrame

    local template = frame:WaitForChild("RowTemplate") :: Frame
    template.Visible = false

    boards[key] = {}

    task.spawn(function()
        clearFrames(key)
        while true do
            functions[key]():andThen(function(top: {{ name: string, value: number }}?)
                if top == nil then
                    return
                end

                clearFrames(key)

                for rank, obj in ipairs(top) do
                    putFrame(key, frame, template, rank, obj.name, tostring(obj.value))
                end
            end):catch(function(err)
                warn("Failed to update leaderboard for " .. key .. ": " .. tostring(err))
            end)
            task.wait(30)
        end
    end)
end

return Leaderboard