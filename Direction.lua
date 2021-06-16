Direction = {
    LEFT = {
        clockwise = function() return Direction.UP end,
        anticlockwise = function() return Direction.DOWN end
    },
    UP = {
        clockwise = function() return Direction.RIGHT end,
        anticlockwise = function() return Direction.LEFT end
    },
    RIGHT = {
        clockwise = function() return Direction.DOWN end,
        anticlockwise = function() return Direction.UP end
    },
    DOWN = {
        clockwise = function() return Direction.LEFT end,
        anticlockwise = function() return Direction.RIGHT end
    }
}
