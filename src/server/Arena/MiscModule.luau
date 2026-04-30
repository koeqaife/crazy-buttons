--!strict
--!optimize 2

local Players = game:GetService("Players")
local GameState = {}

GameState.round = 0

local registeredInstances: {Instance} = {}

local function addHighlightToOne(player: Player?, color: Color3?, outlineColor: Color3?)
    if player == nil then
        return
    end
    local colorToPut = color or Color3.fromRGB(255, 140, 91)
    if player.Character and not player.Character:FindFirstChild("EventHighlight") then
        local highlight = Instance.new("Highlight")
        highlight.Name = "EventHighlight"
        highlight.Adornee = player.Character
        highlight.FillColor = colorToPut
        highlight.FillTransparency = 0.5
        highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        highlight.Parent = player.Character

        if outlineColor then
            highlight.OutlineTransparency = 0.0
            highlight.OutlineColor = outlineColor
        else
            highlight.OutlineTransparency = 1.0
        end
    end
end

local function removeHighlightFromOne(player: Player)
    if player.Character then
        local highlight = player.Character:FindFirstChild("EventHighlight")
        if highlight then
            highlight:Destroy()
        end
    end
end

GameState.addHighlightToOne = addHighlightToOne
GameState.removeHighlightFromOne = removeHighlightFromOne

function GameState.addHighlightTo(players: {Player}, color: Color3?, outlineColor: Color3?)
    for _, player in players do
        addHighlightToOne(player, color, outlineColor)
    end
end

function GameState.removeHighlightFrom(players: {Player})
    for _, player in players do
        removeHighlightFromOne(player)
    end
end

function GameState.removeHighlightFromAll()
    for _, player in Players:GetPlayers() do
        removeHighlightFromOne(player)
    end
end

function GameState.registerInstance(instance: Instance)
    table.insert(registeredInstances, instance)
end

function GameState.destroyInstances()
    for i, instance in ipairs(registeredInstances) do
        instance:Destroy()
    end
    table.clear(registeredInstances)
end

return GameState