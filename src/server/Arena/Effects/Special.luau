--!strict
--!optimize 2
local ServerScriptService = game:GetService("ServerScriptService")
local Format = require(ServerScriptService.Server.Arena.Replicas.Format)

local Effect = {
    id = "special",
    name = "Special",
    description = "Always ran when special round is active",
    universal = true,
    priority = 999,
    startHook = function()
        local terminalScreen: Part = workspace:WaitForChild("TerminalScreen")
        local terminalFace: Part = workspace:WaitForChild("TerminalFace")

        local color = Color3.fromHex("#a996ec")

        local light1 = terminalScreen:WaitForChild("ScreenLight") :: SurfaceLight
        local light2 = terminalFace:WaitForChild("ScreenLight") :: SurfaceLight

        local faceGui = terminalFace:WaitForChild("SurfaceGui") :: SurfaceGui
        local screenGui = terminalScreen:WaitForChild("SurfaceGui") :: SurfaceGui

        local faceText = faceGui:WaitForChild("TextLabel") :: TextLabel

        local screenText = screenGui:WaitForChild("mainText") :: TextLabel
        local screenTimer = screenGui:WaitForChild("timer") :: TextLabel

        faceText.TextColor3 = color
        screenText.TextColor3 = color
        screenTimer.TextColor3 = color
        light1.Color = color
        light2.Color = color
    end,
    faceEffect = function(original: Format.Face?)
        local face = original
        if face == nil then
            return
        elseif type(face) == "string" then
            face = face .. "_special"
        elseif face.face and string.sub(face.face, -8) ~= "_special" then
            face.face = (face.face .. "_special") :: Format.FaceStringSpecial
        else
            face.face = "looking_special"
        end
        return face
    end
}

return Effect :: any