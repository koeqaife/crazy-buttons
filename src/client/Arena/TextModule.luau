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
    game:GetService("ContentProvider"):PreloadAsync({mainText})  -- Wait until text loads too
    UpdateTextEvent.OnClientEvent:Connect(
        function(text)
            mainText.Text = text
        end
    )
end

return TextModule