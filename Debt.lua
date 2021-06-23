--- A debt, representing someone owing someone else money.
---@class Debt
---@field debtor UMPlayer
---@field creditor UMPlayer
---@field amount integer
---@field reason string
local Debt = {}
Debt.__index = Debt
function Debt:__tostring()
    return (self.debtor and self.debtor.name or "The Bank") .. " owes " .. (self.creditor and self.creditor.name or "The Bank") .. " $" .. self.amount .. " " .. (self.reason or "")
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
    if amount < 1 then
        error("amount must be larger than 1", 2)
    end
    self.amount = amount
    self.reason = reason
    return self
end
