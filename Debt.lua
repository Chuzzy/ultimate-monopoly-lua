--- A debt, representing someone owing someone else money.
---@class Debt
---@field debtor UMPlayer The person who owes money.
---@field creditor UMPlayer The person who is owed money.
---@field amount integer The amount of money owed.
---@field reason string The reason for owing money.
Debt = {}
Debt.__index = Debt
function Debt.__tostring(self)
    return (self.debtor and self.debtor:getName() or "The Bank") .. " owes " ..
               (self.creditor and self.creditor:getName() or "The Bank") .. " $" ..
               self.amount .. (self.reason and " " .. self.reason or "")
end

--- Creates a new Debt.
---@param debtor UMPlayer The person who owes money.
---@param creditor UMPlayer The person who is owed money.
---@param amount integer The amount of money owed.
---@param reason string The reason for owing money.
---@return Debt
function Debt.new(debtor, creditor, amount, reason)
    local self = setmetatable({}, Debt)
    self.debtor = debtor
    self.creditor = creditor
    if debtor == creditor then
        error("debtor and creditor cannot be the same", 2)
    end
    if amount < 1 then error("amount must be larger than 1", 2) end
    self.amount = amount
    self.reason = reason
    return self
end

---Returns whether this debt can be paid off right now.
---In the case where the debtor is nil (The Bank) this method
---always returns true.
---@return boolean is_payable
function Debt:isPayable()
    return not self.debtor or self.debtor.money >= self.amount
end

---Returns a string representation of this Debt.
---It looks like `Somebody owes Someone $21 <reason>`
---@param has_paid boolean true to use the word "paid" in place of "owes".
---@param is_pool boolean true to use "The Pool" instead of "The Bank".
---@return string
function Debt:tostring(has_paid, is_pool)
    return (self.debtor and self.debtor:getName() or
               (is_pool and "The Pool" or "The Bank")) ..
               (has_paid and " paid " or " owes ") ..
               (self.creditor and self.creditor:getName() or
                   (is_pool and "The Pool" or "The Bank")) .. " $" ..
               self.amount .. (self.reason and " " .. self.reason or "")
end
