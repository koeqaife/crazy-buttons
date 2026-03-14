--!strict
--!optimize 2
local Dialog = {}

local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer

local State = require(localPlayer.PlayerScripts.Client.Shared.UI.State)

local canvas = localPlayer:WaitForChild("PlayerGui"):WaitForChild("ScreenGui"):WaitForChild("DialogCanvas") :: CanvasGroup
local window = State.createWindow("dialog_window", canvas)

local container = canvas:WaitForChild("Container") :: Frame
local buttonsContainer = container:WaitForChild("Buttons") :: Frame
local textLabel = container:WaitForChild("TextLabel") :: TextLabel

local buttonTemplate = buttonsContainer:WaitForChild("Template") :: TextButton
buttonTemplate.Visible = false

local spawnedButtons: {TextButton} = {}

export type ButtonType = {
    text: string,
    func: () -> ()?,
}

function Dialog.showDialog(text: string, buttons: { ButtonType })
    for _, button in spawnedButtons do
        button:Destroy()
    end
    table.clear(spawnedButtons)

    textLabel.Text = text
    local connections: {RBXScriptConnection} = {}

    for _, button in buttons do
        local btn = buttonTemplate:Clone()
        btn.Parent = buttonsContainer
        btn.Visible = true

        local btnText = btn:WaitForChild("TextLabel") :: TextLabel
        btnText.Text = button.text

        local conn = btn.Activated:Connect(function()
            if button.func then
                task.defer(button.func)
            end
            window.hide()
            for _, conn in connections do
                conn:Disconnect()
            end
        end)
        table.insert(connections, conn)
        table.insert(spawnedButtons, btn)
    end

    window.show()
end

return Dialog