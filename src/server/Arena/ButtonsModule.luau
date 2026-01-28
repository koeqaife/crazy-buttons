--!strict
--!optimize 2

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Arena = game:GetService("ServerScriptService").Server.Arena

local SideEffectType = require(Arena.SideEffectType)
local IndicesModule = require(ReplicatedStorage.Shared.IndicesType)
local Promise = require(ReplicatedStorage.Shared.Promise)
type Indices = IndicesModule.Indices

local ButtonClickedEvent = Instance.new("RemoteEvent", ReplicatedStorage)
ButtonClickedEvent.Name = "ButtonClickedEvent"

local UpdateButtonsEvent = Instance.new("RemoteEvent", ReplicatedStorage)
UpdateButtonsEvent.Name = "UpdateButtonsEvent"

local ButtonsModule = {}

local function waitForButton(player: Player, timeout: number, filter: ((number) -> boolean)?)
    local conn
    return Promise.race({
        Promise.new(function(resolve, _, onCancel)
            conn = ButtonClickedEvent.OnServerEvent:Connect(function(playerWhoClicked, idx: number)
                if playerWhoClicked == player and (not filter or filter(idx)) then
                    resolve(idx :: number?)
                    conn:Disconnect()
                end
            end)

            onCancel(function()
                conn:Disconnect()
            end)
        end),
        Promise.new(function(resolve)
            task.wait(timeout)
            resolve(nil)
        end)
    })
end

function ButtonsModule.waitForClick(player: Player, timeout: number)
    return waitForButton(player, timeout)
end

function ButtonsModule.waitForIdxClick(player: Player, timeout: number, idx: number)
    return waitForButton(player, timeout, function(clickedIdx)
        return clickedIdx == idx
    end):andThen(function(result)
        return result ~= nil
    end)
end

local function shuffleTable(tbl)
	for i = #tbl, 2, -1 do
		local j = math.random(i)
		tbl[i], tbl[j] = tbl[j], tbl[i]
	end
	return tbl
end

function ButtonsModule.setButtons(
    player: Player,
    buttons: Indices,
    sideEffect: SideEffectType.SideEffect?,
    shuffle: boolean?
)
    if sideEffect then
        buttons = sideEffect.buttonsEffect(sideEffect)
    end

    if shuffle == nil or shuffle then
        local regularButtons = {}
        local greenButtonData = nil

        for _, buttonData in ipairs(buttons) do
            if buttonData.idx == 5 then
                greenButtonData = buttonData
            else
                table.insert(regularButtons, buttonData)
            end
        end

        shuffleTable(regularButtons)

        if greenButtonData then
            table.insert(regularButtons, greenButtonData)
        end

        buttons = regularButtons
    end

    UpdateButtonsEvent:FireClient(player, "set", buttons)
end

function ButtonsModule.updateButtons(
    player: Player,
    buttons: Indices,
    sideEffect: SideEffectType.SideEffect?
)
    if sideEffect then
        buttons = sideEffect.buttonsEffect(sideEffect)
    end
    UpdateButtonsEvent:FireClient(player, "update", buttons)
end

function ButtonsModule.init()
    -- Prevent events from queueing
    ButtonClickedEvent.OnServerEvent:Connect(function() end)
end

return ButtonsModule