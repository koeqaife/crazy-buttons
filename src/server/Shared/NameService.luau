--!strict
--!optimize 2

local Players = game:GetService("Players")

local NameService = {}

local CACHE_TTL = 60 * 60 * 24
local RATE_INTERVAL = 0.01
local MAX_RETRIES = 5

local cache: { [number]: { name: string, ts: number } } = {}
local lastRequest = 0

local function rateWait()
    local now = os.clock()
    local delta = RATE_INTERVAL - (now - lastRequest)
    if delta > 0 then
        task.wait(delta)
    end
    lastRequest = os.clock()
end

local function is429Error(err: any): boolean
    if typeof(err) == "string" then
        return string.find(err, "429") ~= nil or string.find(err:lower(), "too many requests") ~= nil
    end
    return false
end

function NameService.getName(userId: number): string?
    local entry = cache[userId]
    if entry and os.time() - entry.ts < CACHE_TTL then
        return entry.name
    end

    for attempt = 1, MAX_RETRIES do
        rateWait()

        local ok, result = pcall(function()
            return Players:GetNameFromUserIdAsync(userId)
        end)

        if ok and type(result) == "string" then
            cache[userId] = { name = result, ts = os.time() }
            return result
        end

        if not ok then
            if is429Error(result) then
                local backoff = (2 ^ (attempt - 1)) * 0.1 + math.random() * 0.1
                task.wait(backoff)
            else
                warn(("NameService: failed to get name for %d: %s"):format(userId, tostring(result)))
                return nil
            end
        end
    end

    warn(("NameService: exhausted retries for %d"):format(userId))
    return nil
end

function NameService.invalidate(userId: number)
    cache[userId] = nil
end

function NameService.clearCache()
    cache = {}
end

return NameService