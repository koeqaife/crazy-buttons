--!strict
--!optimize 2

local GameState = {}

local linkedPlayers: {[Player]: Player} = {}
local links: {[string]: {Beam: Beam, Attachment1: Attachment, Attachment2: Attachment}} = {}

GameState.linkedPlayers = linkedPlayers
GameState.wasLinked = {} :: {[Player]: boolean}

local function createLink(player1: Player, player2: Player)
    if not player1.Character or not player2.Character then return end
    local hrp1 = player1.Character:FindFirstChild("HumanoidRootPart")
    local hrp2 = player2.Character:FindFirstChild("HumanoidRootPart")
    if not hrp1 or not hrp2 then return end

    local attachment1 = Instance.new("Attachment", hrp1)
    local attachment2 = Instance.new("Attachment", hrp2)

    local beam = Instance.new("Beam")
    beam.Attachment0 = attachment1
    beam.Attachment1 = attachment2
    beam.FaceCamera = true
    beam.Color = ColorSequence.new(Color3.fromRGB(56, 138, 245))
    beam.Width0 = 0.2
    beam.Width1 = 0.2
    beam.LightEmission = 1
    beam.LightInfluence = 1
    beam.Parent = hrp1

    -- Transparency: beginning transparent, middle not, end transparent
    beam.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 1),
        NumberSequenceKeypoint.new(0.249, 1),
        NumberSequenceKeypoint.new(0.25, 0),
        NumberSequenceKeypoint.new(0.75, 0),
        NumberSequenceKeypoint.new(0.751, 1),
        NumberSequenceKeypoint.new(1, 1)
    })

    local object = {Beam = beam, Attachment1 = attachment1, Attachment2 = attachment2}
    links[player1.Name .. "_" .. player2.Name] = object
    links[player2.Name .. "_" .. player1.Name] = object
end

local function removeLink(player1: Player, player2: Player)
    local data = links[player1.Name .. "_" .. player2.Name]
    if data then
        data.Beam:Destroy()
        data.Attachment1:Destroy()
        data.Attachment2:Destroy()

        links[player1.Name .. "_" .. player2.Name] = nil
        links[player2.Name .. "_" .. player1.Name] = nil
    end
end

function GameState.linkTogether(player1: Player, player2: Player)
    linkedPlayers[player1] = player2
    linkedPlayers[player2] = player1
    GameState.wasLinked[player1] = true
    GameState.wasLinked[player2] = true

    createLink(player1, player2)
end

function GameState.clearLinkedPlayers()
    for player1, player2 in pairs(linkedPlayers) do
        removeLink(player1, player2)
    end
    table.clear(linkedPlayers)
end

function GameState.clearLinks(player: Player): Player?
    local linked = linkedPlayers[player]
    if linked then
        linkedPlayers[linked] = nil
        linkedPlayers[player] = nil
        removeLink(player, linked)
    end
    return linked
end

return GameState