--- The Ultimate Monopoly game board.
---@class Board
---@field game Game
---@field spaces table
local Board = {}
Board.__index = Board

Space = require("Space")
Prototypes = require("BoardPrototype")

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

    --- Links together an entire track using prototype data.
    ---@param track table
    local function linkPrototypeTrack(track)
        for i, space in pairs(track) do
            local next_space = track[(i % #track) + 1]
            linkConsecutiveSpaces(space.name, next_space.name, space.action, next_space.action)
        end
    end

    linkPrototypeTrack(Prototypes.middle)
    linkPrototypeTrack(Prototypes.outer)
    linkPrototypeTrack(Prototypes.inner)

    return self
end

Board.new()
