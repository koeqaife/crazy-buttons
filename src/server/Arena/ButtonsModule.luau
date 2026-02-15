--!strict
--!optimize 2
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Arena = game:GetService("ServerScriptService").Server.Arena

local Helpers = require(ReplicatedStorage.Shared.Helpers)
local SideEffectType = require(Arena.SideEffectType)
local IndicesModule = require(ReplicatedStorage.Shared.IndicesType)
local Promise = require(ReplicatedStorage.Shared.Promise)
type Indices = IndicesModule.Indices

local ButtonClickedEvent = Instance.new("RemoteEvent", ReplicatedStorage)
ButtonClickedEvent.Name = "ButtonClickedEvent"

local UpdateButtonsEvent = Instance.new("RemoteEvent", ReplicatedStorage)
UpdateButtonsEvent.Name = "UpdateButtonsEvent"

local buttonsPerPlayer: {[Player]: Indices} = {}

local ButtonsModule = {}

local function waitForButton(player: Player, timeout: number, filter: ((Player, number) -> boolean)?)
    local conn
    return Promise.race({
        Promise.new(function(resolve, _, onCancel)
            conn = ButtonClickedEvent.OnServerEvent:Connect(function(playerWhoClicked, idx: number)
                if playerWhoClicked == player and (not filter or filter(playerWhoClicked, idx)) then
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

function ButtonsModule.waitForClick(player: Player, timeout: number, filter: ((Player, number) -> boolean)?)
    return waitForButton(player, timeout, filter)
end

function ButtonsModule.waitForIdxClick(player: Player, timeout: number, idx: number)
    return waitForButton(player, timeout, function(_, clickedIdx)
        return clickedIdx == idx
    end):andThen(function(result)
        return result ~= nil
    end)
end

function ButtonsModule.initiateButtonChoice(
    forTime: number,
    filter: ((Player, number) -> boolean)?,
    post: ((Player, number?) -> nil)?,
    currentChoices: {[Player]: number?}?,
    allowCancel: boolean?
)
    return Promise.new(function(resolve, reject, onCancel)
        local choices: {[Player]: number?} = currentChoices or {}

        local conn = ButtonClickedEvent.OnServerEvent:Connect(function(playerWhoClicked, idx: number)
            if not ButtonsModule.doesPlayerHaveButton(playerWhoClicked, idx) then
                return
            end
            if filter and not filter(playerWhoClicked, idx) then
                return
            end

            local lastChoice = choices[playerWhoClicked]

            if lastChoice then
                ButtonsModule.updateButtons(playerWhoClicked, {{ idx = lastChoice, highlighted = false }})
            end

            if idx ~= lastChoice or not allowCancel then
                choices[playerWhoClicked] = idx
                ButtonsModule.updateButtons(playerWhoClicked, {{ idx = idx, highlighted = true }})
            else
                choices[playerWhoClicked] = nil
            end

            if post then
                post(playerWhoClicked, choices[playerWhoClicked])
            end
        end)
        onCancel(function()
            conn:Disconnect()
        end)

        task.wait(forTime)

        conn:Disconnect()

		resolve(choices)
    end)
end

function ButtonsModule.setButtons(
    player: Player,
    buttons: Indices,
    sideEffect: SideEffectType.SideEffect?,
    shuffle: boolean?,
    seed: number?
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

        Helpers.shuffleTable(regularButtons, seed)

        if greenButtonData then
            table.insert(regularButtons, greenButtonData)
        end

        buttons = regularButtons
    end

    UpdateButtonsEvent:FireClient(player, "set", buttons, seed)
    buttonsPerPlayer[player] = buttons
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

    for _, obj in ipairs(buttons) do
        local button = buttonsPerPlayer[player][obj.idx]
        if button then
            button.text = obj.text or button.text
            if obj.highlighted ~= nil then
                button.highlighted = obj.highlighted
            end
            if obj.disabled ~= nil then
                button.disabled = obj.disabled
            end
        end
    end
end

function ButtonsModule.doesPlayerHaveButton(player: Player, idx: number)
    for _, button in ipairs(buttonsPerPlayer[player]) do
        if button.idx == idx and not button.disabled then
            return true
        end
    end
    return false
end

function ButtonsModule.init()
    -- Prevent events from queueing
    ButtonClickedEvent.OnServerEvent:Connect(function() end)
end

return ButtonsModule