--- A space on the Ultimate Monopoly board.
---@class Space
---@field name string
---@field action function
---@field prev Space
---@field next Space
---@field outer Space
---@field inner Space
local Space = {}
Space.__index = Space

--- Create a new Space.
---@param name string
---@param action function
function Space.new(name, action)
    local self = setmetatable({}, Space)
    self.name = name
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