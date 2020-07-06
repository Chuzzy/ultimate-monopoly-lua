--- A property in Ultimate Monopoly.
---@class Property
---@field cost integer
---@field group string
---@field rent_values table
---@field improvement_cost integer
---@field improvements integer
---@field owner Player
local Property = {}
Property.__index = Property
setmetatable(Property, {
    __call = function (cls, ...)
        return cls.new(...)
    end
})

--- Create a new Property.
---@param cost integer
---@param group string
---@param rent_values table
---@param improvement_cost integer
---@return Property
function Property.new(cost, group, rent_values, improvement_cost)
    local self = setmetatable({}, Property)
    self.cost = cost
    self.group = group
    self.rent_values = rent_values
    self.improvement_cost = improvement_cost
    self.improvements = 0
    return self
end

--- Calculate the rent on this property.
---@return integer
function Property:rent()
    if not self.owner then
        return 0
    else
        if self.group == "rail" then
            local rent_multiplier = self.improvements + 1
            return self.rent_values[self.owner.railroadCount()] * rent_multiplier
        elseif self.group == "cab" then
            local rent_multiplier = self.improvements + 1
            return self.rent_values[self.owner.cabCompanyCount()] * rent_multiplier
        elseif self.group == "utility" then
            return self.rent_values[self.owner.utilityCount()]
        else
            -- TODO: Calculate rent for any normal property here
        end
    end
end
