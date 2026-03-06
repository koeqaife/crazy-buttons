--!strict
--!optimize 2
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Spring = require(ReplicatedStorage.Shared.spr)
local Helpers = require(ReplicatedStorage.Shared.Helpers)

local localPlayer = Players.LocalPlayer

return function(
    player: Player,
    reverse: boolean,
    localPlayerIsDead: boolean,
    reason: string?,
    overrideColor: Color3?,
    partStartHook: (part: BasePart) -> ()?,
    partMiddleHook: (part: BasePart) -> ()?,
    partEndHook: (part: BasePart) -> ()?,
    endHook: () -> ()?
)
    local itsMe = player == localPlayer

    local dieSound: Sound = ReplicatedStorage
        :WaitForChild("Sounds")
        :WaitForChild("DieSound")

    local character = player.Character
    if not character then
        return
    end

    local descendants = {}
    for _, obj in ipairs(character:GetDescendants()) do
        table.insert(descendants, obj)
    end

    Helpers.shuffleTable(descendants)

    local color: Color3
    if overrideColor ~= nil then
        color = overrideColor
    elseif reason == "byKillTool" then
        color = Color3.fromRGB(255, 238, 0)
    else
        color = Color3.fromRGB(56, 138, 245)
    end

    local opacity
    if not reverse then
        for _, obj in ipairs(descendants) do
            if obj:IsA("BasePart") then
                obj.CanQuery = false
            end
        end

        opacity = {
            highlightStart = 1,
            highlightTo = 0,
            highlightEnd = 1,
            objStart = 0,
            objStartForMe = 0,
            objTo = 0.999,
            objEnd = 1,
            objEndForMe = 0.65
        }
    else
        for _, obj in ipairs(descendants) do
            if obj:IsA("BasePart") then
                obj.CanQuery = true
            end
        end

        opacity = {
            highlightStart = 1,
            highlightTo = 0,
            highlightEnd = 1,
            objStart = 1,
            objStartForMe = 0.65,
            objTo = 0,
            objEnd = 0,
            objEndForMe = 0
        }
    end

    local sound = dieSound:Clone()
    sound.Parent = workspace
    sound:Destroy()

    local counter = #descendants

    for _, obj in ipairs(descendants) do
        if obj:IsA("BasePart") and obj.Name ~= "HumanoidRootPart" then
            task.wait(0.05)
            obj.Transparency = opacity.objStart
            if localPlayerIsDead or itsMe then
                obj.Transparency = opacity.objStartForMe
            end

            local highlight = Instance.new("Highlight")
            highlight.Parent = obj
            highlight.OutlineTransparency = 1
            highlight.FillTransparency = opacity.highlightStart
            highlight.FillColor = color
            highlight.DepthMode = Enum.HighlightDepthMode.Occluded

            if partStartHook then
                partStartHook(obj)
            end

            Spring.target(highlight, 1.5, 5, { FillTransparency = opacity.highlightTo })
            Spring.target(obj, 1.5, 5, { Transparency = opacity.objTo })
            Spring.completed(highlight, function()
                if itsMe or localPlayerIsDead then
                    Spring.target(obj, 1.5, 5, { Transparency = opacity.objEndForMe })
                end
                if partMiddleHook then
                    partMiddleHook(obj)
                end

                Spring.target(highlight, 1.5, 5, { FillTransparency = opacity.highlightEnd })
                Spring.completed(highlight, function()
                    if partEndHook then
                        partEndHook(obj)
                    end

                    counter -= 1
                    if counter <= 0 and endHook then
                        endHook()
                    end

                    highlight:Destroy()
                    if not itsMe and not localPlayerIsDead then
                        obj.Transparency = opacity.objEnd
                    end
                end)
            end)
        end
    end
end