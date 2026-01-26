local TimerModule = {}

local timerLabel: TextLabel = workspace
    :WaitForChild("TerminalScreen")
    :WaitForChild("SurfaceGui")
    :WaitForChild("timer")

local currentTime = 30

function TimerModule.setTime(seconds: number)
    currentTime = seconds + 1
end

function TimerModule.start()
    task.spawn(function()
        task.wait(5)
        while task.wait(1) do
            if currentTime > 0 then
                currentTime -= 1
                timerLabel.Text = currentTime .. "s"
            end
        end
    end)

    task.spawn(function()
        task.wait(10)
        TimerModule.setTime(30)
    end)
end

return TimerModule