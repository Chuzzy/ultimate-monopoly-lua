--- A debt, representing someone owing someone else money.
---@class Debt
---@field debtor Player
---@field creditor Player
---@field amount integer
local Debt = {}
Debt.__index = Debt
function Debt:__tostring()
    return (self.debtor.name or "The Bank") .. " owes " .. (self.creditor.name or "The Bank") .. " $" .. self.amount
end

--- Creates a new Debt.
---@param debtor Player
---@param creditor Player
---@param amount integer
---@return Debt
function Debt.new(debtor, creditor, amount)
    local self = setmetatable({}, Debt)
    self.debtor = debtor
    self.creditor = creditor
    if not debtor and not creditor then
        error("debtor and creditor cannot both be nil", 2)
    end
    self.amount = amount
    return self
end
