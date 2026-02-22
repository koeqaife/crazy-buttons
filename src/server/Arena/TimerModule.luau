--!strict
--!optimize 2

local TimerModule = {}

local screen: Part = workspace:WaitForChild("TerminalScreen")

local timerLabel = screen
    :WaitForChild("SurfaceGui")
    :WaitForChild("timer") :: TextLabel

local clickSound = screen:WaitForChild("Click") :: Sound

local sound = true
local startTime = os.clock()
local duration = 30

function TimerModule.setTime(seconds: number, invisible: boolean?)
    timerLabel.Visible = seconds ~= -1 and not invisible
    if seconds == -1 then
        sound = false
        return
    end

    startTime = os.clock()
    duration = seconds

    local elapsed = os.clock() - startTime
    local remaining = math.max(0, duration - elapsed)
    timerLabel.Text =  math.ceil(remaining) .. "s"
    clickSound:Play()
    sound = true
end

function TimerModule.start()
    task.spawn(function()
        while task.wait(0.5) do
            local elapsed = os.clock() - startTime
            local remaining = math.ceil(math.max(0, duration - elapsed))

            if remaining <= 0 then
                timerLabel.Visible = false
                sound = false
                continue
            end

            local text = remaining .. "s"
            if timerLabel.Text ~= text then
                timerLabel.Text = text
                if sound then
                    clickSound:Play()
                end
            end
        end
    end)
end

return TimerModule