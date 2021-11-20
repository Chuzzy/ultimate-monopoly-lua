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
        local args
        if type(select(1, ...)) == "table" then
            args = select(1, ...)
        else
            args = table.pack(...)
        end
        for _, other in pairs(args) do
            if thing == other then
                return true
            end
        end
        return false
    end,
    triggerPoliceLights = function ()
        local normal_light_intensity = 0.54
        local normal_light_color = Color.new(255, 251, 228)
        local is_blue = false

        local function toggleLights()
            local light_color = is_blue and Color.Red or Color.Blue
            Lighting.setLightColor(light_color)
            Lighting.apply()
            is_blue = not is_blue
        end

        local function normalLight()
            Lighting.setLightColor(normal_light_color)
            Lighting.light_intensity = normal_light_intensity
            Lighting.apply()
        end

        Lighting.light_intensity = 1.5

        toggleLights()
        Wait.time(toggleLights, 0.5, 14)
        Wait.time(normalLight, 7)
    end,
    spaceToProperty = function(space)
        if space.transit_type then
            -- Removes the " Outer" or " Inner" at the end of the transit station's name
            return UMGame.properties[space.name:sub(0, space.name:len() - 6)]
        else
            return UMGame.properties[space.name]
        end
    end,
    propertyToSpace = function(property)
        if property.group == "rail" then
            return Board.spaces[property.name .. " Outer"]
        else
            return Board.spaces[property.name]
        end
    end,
    -- The board's local scale is different to the
    -- global scale. When creating buttons the position
    -- vectors have to be multiplied by 0.63 to appear normal.
    board_scale_vector = Vector(0.63, 0.3, -0.63),
    ---Splits an integer value into the smallest number of subdivisions
    ---of Monopoly™ money sizes.
    ---@param value integer The integer value to split.
    ---@return table<string, integer> denominations
    moneySplit = function(value)
        local fiveHundreds = math.floor(value / 500)
        value = value % 500
        local hundreds = math.floor(value / 100)
        value = value % 100
        local fifties = math.floor(value / 50)
        value = value % 50
        local twenties = math.floor(value / 20)
        value = value % 20
        local tens = math.floor(value / 10)
        value = value % 10
        local fives = math.floor(value / 5)
        value = value % 5

        return {fiveHundreds=fiveHundreds,
                hundreds=hundreds,
                fifties=fifties,
                twenties=twenties,
                tens=tens,
                fives=fives,
                ones=value
            }
    end,
    ---Safely broadcasts a message.
    ---@param message string The message to broadcast.
    ---@param text_color any Color of the text
    ---@param player_color any The color of the player to broadcast to.
    ---@return boolean success true if a message was broadcast.
    safeMsg = function (message, text_color, player_color)
        if player_color then
            if Player[player_color].seated then
                broadcastToColor(message, player_color, text_color)
                return true
            end
        else
            broadcastToAll(message, text_color)
            return true
        end
    end,
    ---Converts a number to its ordinal representation.
    ---@param n integer
    ---@return string ordinal
    toOrdinal = function(n)
        if n % 100 == 11 or n % 100 == 12 or n % 100 == 13 then
            return n .. "th"
        elseif n % 10 == 1 then
            return n .. "st"
        elseif n % 10 == 2 then
            return n .. "nd"
        elseif n % 10 == 3 then
            return n .. "rd"
        else
            return n .. "th"
        end
    end,
}
