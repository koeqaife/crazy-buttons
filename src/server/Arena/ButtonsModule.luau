--!strict
--!optimize 2

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local IndicesModule = require(ReplicatedStorage.Shared.IndicesType)
local Promise = require(ReplicatedStorage.Shared.Promise)
type Indices = IndicesModule.Indices

local ButtonClickedEvent = Instance.new("RemoteEvent", ReplicatedStorage)
ButtonClickedEvent.Name = "ButtonClickedEvent"

local UpdateButtonsEvent = Instance.new("RemoteEvent", ReplicatedStorage)
UpdateButtonsEvent.Name = "UpdateButtonsEvent"

local ButtonsModule = {}

function ButtonsModule.waitForClick(player: Player, timeout: number)
    local conn
    return Promise.race({
        Promise.new(function(resolve, reject, onCancel)
            conn = ButtonClickedEvent.OnServerEvent:Connect(function(playerWhoClicked, idx: number)
                if playerWhoClicked == player then
                    resolve(idx :: number?)
                    conn:Disconnect()
                end
            end)

            onCancel(function()
                conn:Disconnect()
            end)
        end),
        Promise.new(function(resolve, reject, onCancel)
            task.wait(timeout)
            resolve(nil)
        end)
    })
end

function ButtonsModule.setButtons(player: Player, buttons: Indices)
    UpdateButtonsEvent:FireClient(player, "set", buttons)
end

function ButtonsModule.updateButtons(player: Player, buttons: Indices)
    UpdateButtonsEvent:FireClient(player, "update", buttons)
end

function ButtonsModule.init()
    -- Prevent events from queueing
    ButtonClickedEvent.OnServerEvent:Connect(function() end)
end

return ButtonsModule