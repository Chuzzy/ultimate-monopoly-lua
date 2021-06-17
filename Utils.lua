---A table containing utility functions, particularly mathematical ones.
Utils = {
    ---Returns a random floating point number in a specified range.
    ---@param lower number inclusive lower bound
    ---@param upper number exclusive upper bound
    ---@return number
    randomFloat = function(lower, upper)
        return lower + math.random() * (upper - lower)
    end,
    ---Determines whether thing matches any of the following arguments.
    ---@param thing any the thing to test equality for
    ---@vararg table an array of things to test equality against
    ---@return boolean success
    equalsAny = function (thing, ...)
        for _, other in ipairs(table.pack(...)) do
            if thing == other then
                return true
            end
        end
        return false
    end,
}
