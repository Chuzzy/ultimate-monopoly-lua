require("Space")
require("BoardPrototype")
require("BoardPositions")

--- The Ultimate Monopoly game board.
---@class Board
---@field spaces table<string, Space>
Board = {spaces = {}}

--- Creates a forward link between two spaces.
---@param space_prototype table
---@param after_prototype table
local function linkConsecutiveSpaces(space_prototype, after_prototype)
    local space_name = space_prototype.name
    local space_transit = space_prototype.transit_type
    local space_action = space_prototype.action
    local space_pos = BoardPositions.main[space_name]
    local space_direction = BoardPositions.direction[space_name]
    local after_name = after_prototype.name
    local after_transit = after_prototype.transit_type
    local after_action = after_prototype.action
    local after_pos = BoardPositions.main[after_name]
    local after_direction = BoardPositions.direction[after_name]

    -- Create a space if space_name doesn't exist yet
    if not Board.spaces[space_name] then
        local space_occupant_positions = {}
        for _, offset in ipairs(BoardPositions.token[space_direction.board_side]) do
            table.insert(space_occupant_positions, offset + space_pos)
        end
        local space_avatar_pos = BoardPositions.avatar[space_direction.board_side] + space_pos
        Board.spaces[space_name] = Space.new(space_name, space_transit, space_action, space_pos, space_occupant_positions, space_direction, space_avatar_pos)
    end
    -- Create another space if after_name doesn't exist yet
    if not Board.spaces[after_name] then
        local after_occupant_positions = {}
        for _, offset in ipairs(BoardPositions.token[after_direction.board_side]) do
            table.insert(after_occupant_positions, offset + after_pos)
        end
        local after_avatar_pos = BoardPositions.avatar[after_direction.board_side] + after_pos
        Board.spaces[after_name] = Space.new(after_name, after_transit, after_action, after_pos, after_occupant_positions, after_direction, after_avatar_pos)
    end
    -- Make the "after" space point backwards to the current space
    Board.spaces[after_name].prev = Board.spaces[space_name]
    -- Make the current space point forward to the "after" space
    Board.spaces[space_name].next = Board.spaces[after_name]
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
    Board.spaces[space_name].inner = Board.spaces[inner_name]
    -- Make the "inner" space point outwards to the current space
    Board.spaces[inner_name].outer = Board.spaces[space_name]
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
Board.spaces[Names.go].outer = Board.spaces[Names.stock]
Board.spaces[Names.visit].outer = Board.spaces[Names.holland .. " Outer"]
Board.spaces[Names.parking].outer = Board.spaces[Names.payday]
Board.spaces[Names.malloy].outer = Board.spaces[Names.subway]

-- Fix edge cases where the corner squares on inner track have incorrect `outer` fields
Board.spaces[Names.squeeze].outer = Board.spaces[Names.go]
Board.spaces[Names.bonus].outer = Board.spaces[Names.visit]
Board.spaces[Names.roll3].outer = Board.spaces[Names.parking]
Board.spaces[Names.holland .. " Inner"].outer = Board.spaces[Names.malloy]

---Returns the spaces traversed for a particular dice roll.
---@param start Space
---@param roll number
---@param backwards boolean
---@return Space[]
function Board.diceRoll(start, roll, backwards)
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
