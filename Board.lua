--- The Ultimate Monopoly game board.
---@class Board
---@field game Game
---@field spaces table
Board = {}
Board.__index = Board

require("Space")
require("BoardPrototype")
require("BoardPositions")

function Board.new()
    local self = setmetatable({}, Board)
    -- Initialise the spaces. All 111 of them.
    self.spaces = {}

    --- Creates a forward link between two spaces.
    ---@param space_prototype table
    ---@param after_prototype table
    local function linkConsecutiveSpaces(space_prototype, after_prototype)
        local space_name = space_prototype.name
        local space_transit = space_prototype.transit_type
        local space_action = space_prototype.action
        local space_pos = BoardPositions.main[space_name]
        local after_name = after_prototype.name
        local after_transit = after_prototype.transit_type
        local after_action = after_prototype.action
        local after_pos = BoardPositions.main[after_name]

        -- Create a space if space_name doesn't exist yet
        if not self.spaces[space_name] then
            self.spaces[space_name] = Space.new(space_name, space_transit, space_action, space_pos)
        end
        -- Create another space if after_name doesn't exist yet
        if not self.spaces[after_name] then
            self.spaces[after_name] = Space.new(after_name, after_transit, after_action, after_pos)
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
            linkConsecutiveSpaces(space, next_space)
        end
    end

    -- Create the Space objects and use them to populate the spaces field
    -- and link the spaces between each other
    linkPrototypeTrack(BoardPrototype.middle)
    linkPrototypeTrack(BoardPrototype.outer)
    linkPrototypeTrack(BoardPrototype.inner)

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
    linkBetweenPrototypeTracks(BoardPrototype.outer, BoardPrototype.middle, BoardPrototype.outer_to_middle)
    linkBetweenPrototypeTracks(BoardPrototype.middle, BoardPrototype.inner, BoardPrototype.middle_to_inner)

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

---Returns the spaces traversed for a particular dice roll.
---@param start Space
---@param roll number
---@param backwards boolean
---@return Space[]
function Board:diceRoll(start, roll, backwards)
    -- TODO: Add memoisation
    local is_even_roll = roll % 2 == 0
    local visited_spaces = {}
    local current_space = start
    -- If beginning from a transit station,
    -- move to the outer track if even roll
    -- Otherwise, move to the inner track
    if current_space.transit_type then
        if is_even_roll and current_space.transit_type == 1 then
            current_space = current_space.outer
        elseif not is_even_roll and current_space.transit_type == 0 then
            current_space = current_space.inner
        end
    end

    for i = roll, 1, -1 do
        if backwards then
            current_space = current_space.prev
        else
            current_space = current_space.next
        end
        table.insert(visited_spaces, current_space)

        -- Change tracks when passing through a transit station
        -- if an even number was rolled
        if is_even_roll then
            if current_space.transit_type == 1 then
                -- This space is an innermost transit station
                -- Move to the outer space
                current_space = current_space.outer
                table.insert(visited_spaces, current_space)
            elseif current_space.transit_type == 0 then
                -- This space is an outermost transit station
                -- Move to the inner space
                current_space = current_space.inner
                table.insert(visited_spaces, current_space)
            end
        end
    end

    return visited_spaces
end
