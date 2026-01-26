--!strict
--!optimize 2

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ButtonsModule = {}

type Indices = { { idx: number, text: string, disabled: boolean? } } -- I don't wanna import/export types

local UpdateButtonsEvent = Instance.new("RemoteEvent", ReplicatedStorage)
UpdateButtonsEvent.Name = "UpdateButtonsEvent"

function ButtonsModule.setButtons(player: Player, buttons: Indices)
    UpdateButtonsEvent:FireClient(player, "set", buttons)
end

function ButtonsModule.updateButtons(player: Player, buttons: Indices)
    UpdateButtonsEvent:FireClient(player, "update", buttons)
end

function ButtonsModule.init()
end

return ButtonsModule