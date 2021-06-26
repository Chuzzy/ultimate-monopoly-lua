--- A debt, representing someone owing someone else money.
---@class Debt
---@field debtor UMPlayer
---@field creditor UMPlayer
---@field amount integer
---@field reason string
Debt = {}
Debt.__index = Debt
function Debt.__tostring(self)
    return (self.debtor and self.debtor:getName() or "The Bank") .. " owes " ..
               (self.creditor and self.creditor:getName() or "The Bank") .. " $" ..
               self.amount .. (self.reason and " " .. self.reason or "")
end

--- Creates a new Debt.
---@param debtor UMPlayer
---@param creditor UMPlayer
---@param amount integer
---@param reason string
---@return Debt
function Debt.new(debtor, creditor, amount, reason)
    local self = setmetatable({}, Debt)
    self.debtor = debtor
    self.creditor = creditor
    if not debtor and not creditor then
        error("debtor and creditor cannot both be nil", 2)
    end
    if amount < 1 then error("amount must be larger than 1", 2) end
    self.amount = amount
    self.reason = reason
    return self
end

---Returns a string representation of this Debt.
---@param has_paid boolean true to use the word "paid" in place of "owes".
---@return string
function Debt:tostring(has_paid)
    return (self.debtor and self.debtor:getName() or "The Bank") ..
    (has_paid and " paid " or " owes ") ..
    (self.creditor and self.creditor:getName() or "The Bank") .. " $" ..
    self.amount .. (self.reason and " " .. self.reason or "")
end
