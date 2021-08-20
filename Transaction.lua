---@class Transaction
---@field subject Property The item being improved (or degraded).
---@field count integer The number of improvements. A negative value = number of degradations.
---Represents a user buying or selling improvements, mortgaging or unmortgaging a property or a stock.
Transaction = {}
Transaction.__index = Transaction


function Transaction.new(subject, count)
    local self = setmetatable({}, Transaction)
    self.subject = subject
    self.count = count
    return self
end

---Increases the number of upgrades by 1.
function Transaction:upgrade()
    --TODO: Check for exceeding upgrade limit
    self.count = self.count + 1
end

---Decreases the number of upgrades by 1.
function Transaction:downgrade()
    --TODO: Check for exceeding downgrade limit.
    self.count = self.count - 1
end

function Transaction:tostring()
    --TODO: Implement Transaction:tostring
end
