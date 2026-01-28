--!strict
--!optimize 2

local TimerModule = {}

local timerLabel: TextLabel = workspace
    :WaitForChild("TerminalScreen")
    :WaitForChild("SurfaceGui")
    :WaitForChild("timer")

local currentTime = 30

function TimerModule.setTime(seconds: number)
    currentTime = seconds
    timerLabel.Text = currentTime .. "s"
end

function TimerModule.start()
    task.spawn(function()
        while task.wait(1) do
            if currentTime > 0 then
                currentTime -= 1
                timerLabel.Text = currentTime .. "s"
            end
        end
    end)
end

return TimerModule