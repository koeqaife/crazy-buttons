--!strict
--!optimize 2
local MarketplaceService = game:GetService("MarketplaceService")

local PurchaseProcessor = {}

type ProcessReceiptCallback = ({[string]: any}) -> Enum.ProductPurchaseDecision

local processors: {[string]: { priority: number, callback: ProcessReceiptCallback }} = {}

function PurchaseProcessor.addProcessor(
    key: string,
    priority: number,
    callback: ProcessReceiptCallback
)
    print("Registered new processor", '"' .. key .. '"', "with priority", priority)
    processors[key] = {priority = priority, callback = callback}
end

function PurchaseProcessor.removeProcessor(key: string)
    processors[key] = nil
end

local function computeProcessors(receiptInfo: {[string]: any})
    local sorted = {}
    for k, v in pairs(processors) do
        table.insert(sorted, v)
    end
    table.sort(sorted, function(a, b) return a.priority > b.priority end)

    for _, processor in ipairs(sorted) do
        local result = processor.callback(receiptInfo)
        if result and result == Enum.ProductPurchaseDecision.PurchaseGranted then
            return result
        end
    end

    return Enum.ProductPurchaseDecision.NotProcessedYet
end

task.spawn(function()
    while task.wait(30) do
        -- Replacing process receipt in case something happens
        MarketplaceService.ProcessReceipt = function(receiptInfo)
            return computeProcessors(receiptInfo)
        end
    end
end)

return PurchaseProcessor