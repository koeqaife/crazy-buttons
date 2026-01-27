--!strict
--!optimize 2

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local IndicesModule = require(ReplicatedStorage.Shared.IndicesType)
type Indices = IndicesModule.Indices

local ButtonClickedEvent = Instance.new("RemoteEvent", ReplicatedStorage)
ButtonClickedEvent.Name = "ButtonClickedEvent"

local UpdateButtonsEvent = Instance.new("RemoteEvent", ReplicatedStorage)
UpdateButtonsEvent.Name = "UpdateButtonsEvent"

local ButtonsModule = {
    buttonClickedEvent = ButtonClickedEvent
}

function ButtonsModule.setButtons(player: Player, buttons: Indices)
    UpdateButtonsEvent:FireClient(player, "set", buttons)
end

function ButtonsModule.updateButtons(player: Player, buttons: Indices)
    UpdateButtonsEvent:FireClient(player, "update", buttons)
end

function ButtonsModule.init()
end

return ButtonsModule