--- A space on the Ultimate Monopoly board.
---@class Space
---@field name string
---@field action function
---@field is_transit_station boolean
---@field camera_pos table
---@field occupant_positions table
---@field direction string
---@field building_pos table
---@field house_positions table
---@field prev Space
---@field next Space
---@field outer Space
---@field inner Space
local Space = {}
Space.__index = Space

--- Create a new Space.
---@param name string
---@param action function
---@param camera_pos table
---@param occupant_positions table
---@param direction string
---@param building_pos table
---@param house_positions table
function Space.new(name, action, camera_pos, occupant_positions, direction, building_pos, house_positions)
    local self = setmetatable({}, Space)
    self.name = name
    self.action = action
    self.camera_pos = camera_pos
    self.occupant_positions = occupant_positions
    self.direction = direction
    self.building_pos = building_pos
    self.house_positions = house_positions
    return self
end

--- Performs the action on this space.
---@param player Player
---@param params table
function Space:act(player, params)
    self.action(self, player, params)
end
return Space