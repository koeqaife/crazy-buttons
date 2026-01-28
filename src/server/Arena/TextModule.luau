--!strict
--!optimize 2
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Promise = require(ReplicatedStorage.Shared.Promise)
local TextModule = {}

local UpdateTextEvent = Instance.new("RemoteEvent", ReplicatedStorage)
UpdateTextEvent.Name = "UpdateTextEvent"

local textPerPlayer: {[Player]: string} = {}

local function fire(player: Player)
    UpdateTextEvent:FireClient(player, textPerPlayer[player])
end

function TextModule.showTextSequence(player: Player, sequence: {{text: string, delay: number?}})
    return Promise.new(function(resolve)
        for _, step in ipairs(sequence) do
            TextModule.setText(player, step.text)
            if step.delay then
                task.wait(step.delay)
            end
        end
        resolve()
    end)
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