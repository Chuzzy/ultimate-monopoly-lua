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
    -- The board's local scale is different to the
    -- global scale. When creating buttons the position
    -- vectors have to be multiplied by 0.63 to appear normal.
    board_scale_vector = Vector(0.63, 0.3, -0.63)
}
