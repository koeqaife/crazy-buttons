--!strict
--!optimize 2
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TextModule = {}

local UpdateTextEvent = Instance.new("RemoteEvent", ReplicatedStorage)
UpdateTextEvent.Name = "UpdateTextEvent"

local textPerPlayer: {[Player]: string} = {}

local function fire(player: Player)
    UpdateTextEvent:FireClient(player, textPerPlayer[player])
end

function TextModule.setText(player: Player, text: string)
    textPerPlayer[player] = text
    fire(player)
end

function TextModule.appendText(player: Player, text: string)
    textPerPlayer[player] ..= text
    fire(player)
end

return TextModule