--- A space on the Ultimate Monopoly board.
---@class Space
---@field name string
---@field action function
---@field prevName string
---@field nextName string
---@field outerName string
---@field innerName string
local Space = {}
Space.__index = Space

--- Create a new Space.
---@param name any
---@param prev string
---@param next string
---@param outer string
---@param inner string
---@param action function
function Space.new(name, prev, next, outer, inner, action)
    local self = setmetatable({}, Space)
    self.name = name
    self.prevName = prev
    self.nextName = next
    self.outerName = outer
    self.innerName = inner
    self.action = action
    return self
end

--- Performs the action on this space.
---@param player Player
---@param params table
function Space:act(player, params)
    self.action(self, player, params)
end
return Space