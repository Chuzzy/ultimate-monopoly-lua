---A table containing utility functions, particularly mathematical ones.
Utils = {
    ---Returns a random floating point number in a specified range.
    ---@param lower number inclusive lower bound
    ---@param upper number exclusive upper bound
    ---@return number
    randomFloat = function(lower, upper)
        return lower + math.random() * (upper - lower)
    end,
}
