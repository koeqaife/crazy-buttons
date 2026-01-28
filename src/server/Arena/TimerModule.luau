--!strict
--!optimize 2

local TimerModule = {}

local timerLabel: TextLabel = workspace
    :WaitForChild("TerminalScreen")
    :WaitForChild("SurfaceGui")
    :WaitForChild("timer")

local startTime = os.clock()
local duration = 30

function TimerModule.setTime(seconds: number)
    startTime = os.clock()
    duration = seconds

    local elapsed = os.clock() - startTime
    local remaining = math.max(0, duration - elapsed)
    timerLabel.Text =  math.ceil(remaining) .. "s"
end

function TimerModule.start()
    task.spawn(function()
        while task.wait(0.5) do
            local elapsed = os.clock() - startTime
            local remaining = math.max(0, duration - elapsed)
            if remaining > 0 then
                timerLabel.Text = math.ceil(remaining) .. "s"
            end
        end
    end)
end

return TimerModule