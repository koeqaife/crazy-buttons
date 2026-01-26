--!strict
--!optimize 2

local TextModule = {}
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local mainText: TextLabel = workspace
    :WaitForChild("TerminalScreen")
    :WaitForChild("SurfaceGui")
    :WaitForChild("mainText")

local UpdateTextEvent: RemoteEvent = ReplicatedStorage:WaitForChild("UpdateTextEvent")

function TextModule.connect()
    UpdateTextEvent.OnClientEvent:Connect(
        function(text)
            mainText.Text = text
        end
    )
end

return TextModule