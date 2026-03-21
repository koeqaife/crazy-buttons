--!strict
--!optimize 2

-- Abstraction level for billboard icons on top of each player
-- So modules don't work with UI by themselves
local Players = game:GetService("Players")

local framesPerPlayer: {[Player]: {[string]: Frame}} = {}
local billboardPerPlayer: {[Player]: BillboardGui} = {}

local IconModule = {}

type Space = {
    addIcon: (player: Player, iconId: string, image: string) -> (),
    removeIcon: (player: Player, iconId: string) -> (),
    clearIcons: (player: Player) -> (),
    PlayerLoaded: BindableEvent,
    destroy: () -> (),
}

local reservedSpaces: {[string]: Space} = {}

local function createBillboard(player: Player): BillboardGui
    local character = player.Character
    if not character then
        error("No character found")
    end

    local gui = character:FindFirstChild("IconGui") :: BillboardGui?

    if gui == nil then
        local newGui = Instance.new("BillboardGui", character)
        newGui.Name = "IconGui"
        newGui.Adornee = character
        -- Each icon is 2x2, so I support 5x5 matrix, should be enough for everything
        newGui.Size = UDim2.new(10, 0, 10, 0)
        newGui.SizeOffset = Vector2.new(0, 0)
        newGui.ExtentsOffsetWorldSpace = Vector3.new(0, 1.5, 0)

        local listLayout = Instance.new("UIListLayout", newGui)
        listLayout.VerticalAlignment = Enum.VerticalAlignment.Center

        billboardPerPlayer[player] = newGui
        return newGui
    end

    billboardPerPlayer[player] = gui
    return gui
end

local function createSpaceFrame(player: Player, order: number, id: string)
    if framesPerPlayer[player] and framesPerPlayer[player][id] then
        return
    end
    local gui: BillboardGui? = billboardPerPlayer[player]
    local newFrame = Instance.new("Frame", gui)
    newFrame.BackgroundTransparency = 1
    newFrame.LayoutOrder = order
    newFrame.Name = id
    -- X will be 10, Y will be 2
    -- So when I use it, I should put size as RelativeYY 1,0,1,0
    newFrame.Size = UDim2.new(1, 0, 0.2, 0)

    local listLayout = Instance.new("UIListLayout", newFrame)
    listLayout.FillDirection = Enum.FillDirection.Horizontal
    listLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

    if framesPerPlayer[player] == nil then
        framesPerPlayer[player] = {}
    end
    framesPerPlayer[player][id] = newFrame

    if gui ~= nil then
        local spaceAmount = 0
        for k, v in pairs(framesPerPlayer[player]) do
            print(spaceAmount)
            spaceAmount += 1
        end

        -- 0.3 gives the best result with any amount
        -- Tested manually...
        gui.ExtentsOffsetWorldSpace = Vector3.new(0, 1.5 + (spaceAmount * 0.3 - 0.3), 0)
    end
end

function IconModule.reserveSpace(order: number, spaceId: string): Space
    if reservedSpaces[spaceId] ~= nil then
        reservedSpaces[spaceId].destroy()
    end
    local onLoaded = Instance.new("BindableEvent")
    for _, player in Players:GetPlayers() do
        createSpaceFrame(player, order, spaceId)
        onLoaded:Fire(player)
    end
    local conn = Players.PlayerAdded:Connect(function(player)
        createSpaceFrame(player, order, spaceId)
        onLoaded:Fire(player)
    end)

    local space = {
        PlayerLoaded = onLoaded
    }

    function space.addIcon(player: Player, iconId: string, image: string)
        local spaceFrame: Frame? = framesPerPlayer[player][spaceId]
        if spaceFrame == nil then
            -- In case of race condition
            return
        end

        local imageLabel = spaceFrame:FindFirstChild(iconId) :: ImageLabel?
        if imageLabel then
            imageLabel.Image = image
        else
            local newImage = Instance.new("ImageLabel", spaceFrame)
            newImage.Name = iconId
            newImage.BackgroundTransparency = 1
            newImage.Size = UDim2.new(1, 0, 1, 0)
            newImage.SizeConstraint = Enum.SizeConstraint.RelativeYY
            newImage.Image = image
        end
    end

    function space.removeIcon(player: Player, iconId: string)
        local spaceFrame: Frame? = framesPerPlayer[player][spaceId]
        if spaceFrame == nil then
            -- In case of race condition
            return
        end

        local imageLabel = spaceFrame:FindFirstChild(iconId)
        if imageLabel then
            imageLabel:Destroy()
        end
    end

    function space.clearIcons(player: Player)
        local spaceFrame: Frame? = framesPerPlayer[player][spaceId]
        if spaceFrame == nil then
            -- In case of race condition
            return
        end

        for _, child in spaceFrame:GetChildren() do
            if child:IsA("ImageLabel") then
                child:Destroy()
            end
        end
    end

    function space.destroy()
        -- Check if it's the same space
        -- In case of race conditions
        if reservedSpaces[spaceId] == space then
            reservedSpaces[spaceId] = nil
        end
        for player, space2 in pairs(framesPerPlayer) do
            for id, frame in space2 do
                if id == spaceId then
                    frame:Destroy()
                    space2[id] = nil
                    break
                end
            end
        end
        conn:Disconnect()
    end

    reservedSpaces[spaceId] = space
    return space :: Space
end

function IconModule.init()
    Players.PlayerAdded:Connect(function(player)
        player.CharacterAdded:Connect(function()
            local billboard = createBillboard(player)

            if framesPerPlayer[player] == nil then
                framesPerPlayer[player] = {}
            else
                for _, frame in pairs(framesPerPlayer[player]) do
                    frame.Parent = billboard
                end

                local spaceAmount = 0
                for k, v in pairs(framesPerPlayer[player]) do
                    print(spaceAmount)
                    spaceAmount += 1
                end
                billboard.ExtentsOffsetWorldSpace = Vector3.new(0, 1.5 + (spaceAmount * 0.3 - 0.3), 0)
            end
        end)
    end)

    Players.PlayerRemoving:Connect(function(player, reason)
        local billboard = billboardPerPlayer[player]
        if billboard then
            -- Idk why but I wanted to destroy it before deleting it...
            -- I know it gets destroyed automatically with character
            billboard:Destroy()
            billboardPerPlayer[player] = nil
        end
        framesPerPlayer[player] = nil
    end)
end

return IconModule