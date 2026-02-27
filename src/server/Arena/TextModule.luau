--!strict
--!optimize 2
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Promise = require(ReplicatedStorage.Shared.Promise)
local TextModule = {}

local UpdateTextEvent = Instance.new("RemoteEvent", ReplicatedStorage)
UpdateTextEvent.Name = "UpdateTextEvent"

type FaceString = "normal"
    | "shy" | "scared" | "dead" | "no_mouth"
    | "laughing" | "angry" | "unamused"
    | "nerd" | "happy" | "looking" | "alien"

    | "att_def_tru_icon" | "click_button_icon" | "color_event_icon"
    | "combo_event_icon" | "even_odd_event_icon"

type FaceObject = { text: string, face: FaceString? }
type Face = FaceString | FaceObject

local function fire(player: Player, type: "set" | "append", text: string, face: Face?)
     UpdateTextEvent:FireClient(player, type, text, face)
end

function TextModule.showTextSequence(player: Player, sequence: {{text: string, delay: number?, face: Face?}})
    return Promise.new(function(resolve, reject, onCancel)
        local cancelled = false

        onCancel(function()
            print("Player", player.Name, "sequence was cancelled")
            cancelled = true
        end)

        for _, step in ipairs(sequence) do
            if cancelled then
                return
            end

            TextModule.setText(player, step.text, step.face)
            if step.delay then
                Promise.delay(step.delay):await()
            end
        end
        resolve()
    end)
end

function TextModule.setText(player: Player, text: string, face: Face?)
    fire(player, "set", text, face)
end

function TextModule.appendText(player: Player, text: string, face: Face?)
    fire(player, "append", text, face)
end

return TextModule