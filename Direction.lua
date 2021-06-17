Direction = {
    ---@type Direction
    LEFT = {
        vector = {0, 0, 0},
        board_side = "bottom",
        clockwise = function() return Direction.UP end,
        anticlockwise = function() return Direction.DOWN end
    },
    ---@type Direction
    UP = {
        vector = {0, 90, 0},
        board_side = "left",
        clockwise = function() return Direction.RIGHT end,
        anticlockwise = function() return Direction.LEFT end
    },
    ---@type Direction
    RIGHT = {
        vector = {0, 180, 0},
        board_side = "top",
        clockwise = function() return Direction.DOWN end,
        anticlockwise = function() return Direction.UP end
    },
    ---@type Direction
    DOWN = {
        vector = {0, 270, 0},
        board_side = "right",
        clockwise = function() return Direction.LEFT end,
        anticlockwise = function() return Direction.RIGHT end
    }
}
---@class Direction
---@field vector table
---@field board_side string
---@field clockwise function
---@field anticlockwise function
