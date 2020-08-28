--- The Ultimate Monopoly game board.
---@class Board
---@field game Game
---@field spaces table
local Board = {}
Board.__index = Board

Space = require("Space")
Ordered = require("Ordered")

function Board.new()
    local self = setmetatable({}, Board)
    -- Initialise the spaces. All 111 of them.
    self.spaces = {}

    --- Creates a forward link between two spaces.
    ---@param space_name string
    ---@param after_name string
    ---@param space_action function
    ---@param after_action function
    local function linkConsecutiveSpaces(space_name, after_name, space_action,
                                         after_action)
        -- Create a space if space_name doesn't exist yet
        if not self.spaces[space_name] then
            self.spaces[space_name] = Space.new(space_name, space_action)
        end
        -- Create another space if after_name doesn't exist yet
        if not self.spaces[after_name] then
            self.spaces[after_name] = Space.new(after_name, after_action)
        end
        -- Make the "after" space point backwards to the current space
        self.spaces[after_name].prev = self.spaces[space_name]
        -- Make the current space point forward to the "after" space
        self.spaces[space_name].next = self.spaces[after_name]
    end

    return self
end

Board.new()
