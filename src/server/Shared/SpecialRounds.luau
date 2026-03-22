--!strict
--!optimize 2

local SpecialRounds = {}

local INTERVAL = 12 * 60 * 60
local DURATION = 45 * 60
local GRACE = 60
local START_HOUR_UTC = 18

local function getBaseTime(): number
    local now = os.time()
    local utc = os.date("!*t", now)

    return os.time({
        year = utc.year,
        month = utc.month,
        day = utc.day,
        hour = START_HOUR_UTC,
        min = 0,
        sec = 0,
        isdst = false
    })
end

function SpecialRounds.isActive(): boolean
    local now = os.time()
    local base = getBaseTime()

    local diff = now - base
    local cyclePosition = diff % INTERVAL

    if cyclePosition < 0 then
        cyclePosition += INTERVAL
    end

    return cyclePosition < (DURATION + GRACE) or true
end

function SpecialRounds.getSecondsUntilEnd(): number
    local now = os.time()
    local base = getBaseTime()

    local diff = now - base
    local cyclePosition = diff % INTERVAL

    if cyclePosition < 0 then
        cyclePosition += INTERVAL
    end

    if cyclePosition < DURATION then
        return DURATION - cyclePosition
    end

    return 0
end

function SpecialRounds.getSecondsUntilNextRound(): number
    local now = os.time()
    local base = getBaseTime()

    local diff = now - base
    local cyclePosition = diff % INTERVAL

    if cyclePosition < 0 then
        cyclePosition += INTERVAL
    end

    if cyclePosition < DURATION then
        return 0
    end

    return INTERVAL - cyclePosition
end

return SpecialRounds