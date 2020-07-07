--- An action card: Chance, Community Chest, Travel Voucher or Roll 3.
---@class ActionCard
local ActionCard = {}
ActionCard.__index = ActionCard

--- Create a new Action Card.
---@param name string
---@param game Game
---@param action function
---@return ActionCard
function ActionCard.new(name, game, action)
    local self = setmetatable({}, ActionCard)
    self.name = name
    self.game = game
    self.action = action
    self.owner = nil
    return self
end

--- Activate the action card.
function ActionCard:activate()
    self.action(self.owner, self.game)
end
