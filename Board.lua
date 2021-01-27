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

    -- Create the Space objects and use them to populate the spaces field
    -- and link the spaces between each other
    linkPrototypeTrack(Prototypes.middle)
    linkPrototypeTrack(Prototypes.outer)
    linkPrototypeTrack(Prototypes.inner)

    --- Creates an inter-track link between two spaces using prototype data.
    ---@param space_name string
    ---@param inner_name string
    local function linkIntertrackSpaces(space_name, inner_name)
        -- Make the current space point inwards to the "inner" space
        self.spaces[space_name].inner = self.spaces[inner_name]
        -- Make the "inner" space point outwards to the current space
        self.spaces[inner_name].outer = self.spaces[space_name]
    end

    --- Links together two prototype tracks to each other using an index mapping.
    ---@param outer_track table
    ---@param inner_track table
    ---@param mapping table
    local function linkBetweenPrototypeTracks(outer_track, inner_track, mapping)
        for outer_index, inner_index in pairs(mapping) do
            local outer_space = outer_track[outer_index]
            local inner_space = inner_track[inner_index]
            linkIntertrackSpaces(outer_space.name, inner_space.name)
        end
    end

    -- Link the space objects
    linkBetweenPrototypeTracks(Prototypes.outer, Prototypes.middle, Prototypes.outer_to_middle)
    linkBetweenPrototypeTracks(Prototypes.middle, Prototypes.inner, Prototypes.middle_to_inner)

    -- Fix edge cases where the corner squares on middle track have incorrect `outer` fields
    self.spaces[Names.go].outer = self.spaces[Names.stock]
    self.spaces[Names.visit].outer = self.spaces[Names.holland .. " Outer"]
    self.spaces[Names.parking].outer = self.spaces[Names.payday]
    self.spaces[Names.malloy].outer = self.spaces[Names.subway]

    -- Fix edge cases where the corner squares on inner track have incorrect `outer` fields
    self.spaces[Names.squeeze].outer = self.spaces[Names.go]
    self.spaces[Names.bonus].outer = self.spaces[Names.visit]
    self.spaces[Names.roll3].outer = self.spaces[Names.parking]
    self.spaces[Names.holland .. " Inner"].outer = self.spaces[Names.malloy]

    return self
end

B = Board.new()

while true do
    io.write("Input a space: ")
    local space = io.read()
    if not B.spaces[space] then
        print("Does not exist")
    else
        print("Behind is ", B.spaces[space].prev.name)
        print("Ahead is ", B.spaces[space].next.name)
        print("Inside is ", B.spaces[space].inner and B.spaces[space].inner.name)
        print("Outside is ", B.spaces[space].outer and B.spaces[space].outer.name)
    end
end

