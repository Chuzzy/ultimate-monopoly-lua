Direction = {
    LEFT = {
        vector = {0, 0, 0},
        clockwise = function() return Direction.UP end,
        anticlockwise = function() return Direction.DOWN end
    },
    UP = {
        vector = {0, 90, 0},
        clockwise = function() return Direction.RIGHT end,
        anticlockwise = function() return Direction.LEFT end
    },
    RIGHT = {
        vector = {0, 180, 0},
        clockwise = function() return Direction.DOWN end,
        anticlockwise = function() return Direction.UP end
    },
    DOWN = {
        vector = {0, 270, 0},
        clockwise = function() return Direction.LEFT end,
        anticlockwise = function() return Direction.RIGHT end
    }
}
