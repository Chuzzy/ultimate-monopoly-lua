--- A space on the Ultimate Monopoly board.
---@class Space
---@field name string
---@field action function
---@field transit_type number
---@field camera_pos table
---@field occupant_positions table
---@field direction Direction
---@field avatar_pos table
---@field building_positions table
---@field prev Space
---@field next Space
---@field outer Space
---@field inner Space
Space = {}
Space.__index = Space

--- Create a new Space.
---@param name string
---@param action function
---@param transit_type number
---@param camera_pos table
---@param occupant_positions table
---@param direction Direction
---@param avatar_pos table
---@param building_positions table
function Space.new(name, transit_type, action, camera_pos, occupant_positions, direction, avatar_pos, building_positions)
    local self = setmetatable({}, Space)
    self.name = name
    self.transit_type = transit_type
    self.action = action
    self.camera_pos = camera_pos
    self.occupant_positions = occupant_positions
    self.direction = direction
    self.avatar_pos = avatar_pos
    self.building_positions = building_positions
    return self
end

--- Performs the action on this space.
---@param player UMPlayer
---@param params table
function Space:act(player, params)
    self.action(self, player, params)
end
