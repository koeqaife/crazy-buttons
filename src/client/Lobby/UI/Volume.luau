--!strict
--!optimize 2

local Volume = {}
local Players = game:GetService("Players")
local player = Players.LocalPlayer

local MusicModule = require(player.PlayerScripts.Client.Shared.MusicModule)
local State = require(player.PlayerScripts.Client.Lobby.UI.State)
local Slider = require(player.PlayerScripts.Client.Lobby.UI.Slider)

local gui = player:WaitForChild("PlayerGui"):WaitForChild("ScreenGui")
local canvas = gui:WaitForChild("VolumeCanvas") :: CanvasGroup
local container = canvas:WaitForChild("Container") :: Frame

local header = canvas:WaitForChild("Header")
local closeButton = header:WaitForChild("CloseButton") :: TextButton

local musicVolumeSliderFrame = container:WaitForChild("MusicVolume"):WaitForChild("Slider") :: Frame
local ambientVolumeSliderFrame = container:WaitForChild("AmbientVolume"):WaitForChild("Slider") :: Frame

local musicVolumeSlider = Slider.buildOn("music_volume", musicVolumeSliderFrame, State.volume.music)
local ambientVolumeSlider = Slider.buildOn("ambient_volume", ambientVolumeSliderFrame, State.volume.ambient)

local window = State.createWindow("volume_window", canvas)
Volume.window = window

local initialized = false

local function sliderHandlers()
    local throttled = false
    local lastSent = {
        music = -1,
        ambient = -1
    }

    local function onChanged()
        if not throttled then
            throttled = true
            task.delay(3, function()
                throttled = false
                local volume = {
                    music = musicVolumeSlider.value,
                    ambient = ambientVolumeSlider.value,
                }
                if volume.music == lastSent.music and volume.ambient == lastSent.ambient then
                    return
                end
                State.SyncEvent:FireServer("set_volume", volume)
            end)
        end
    end

    musicVolumeSlider.valueChanged.Event:Connect(MusicModule.setMultiplier)

    musicVolumeSlider.inputChanged.Event:Connect(onChanged)
    ambientVolumeSlider.inputChanged.Event:Connect(onChanged)

    State.VolumeUpdated.Event:Connect(function(_, newValue: { music: number, ambient: number })
        musicVolumeSlider.setValue(newValue.music)
        ambientVolumeSlider.setValue(newValue.ambient)
        MusicModule.setMultiplier(newValue.music)
    end)
end

function Volume.initialize()
    if initialized then
        return
    end
    initialized = true

    closeButton.Activated:Connect(function(inputObject, clickCount)
        window.hide()
    end)
    sliderHandlers()
end

return Volume