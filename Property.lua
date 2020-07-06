--- A property in Ultimate Monopoly.
---@class Property
---@field cost integer
---@field group string
---@field rent_values table
---@field improvement_cost integer
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
    return self
end

--- Calculate the rent on this property.
---@return integer
function Property:rent()
    if not self.owner then
        return 0
    else
        if self.group == "rail" then
            return self.rent_values[self.owner.railroadCount()]
        elseif self.group == "cab" then
            return self.rent_values[self.owner.cabCompanyCount()]
        elseif self.group == "utility" then
            return self.rent_values[self.owner.utilityCount()]
        else
            -- Calculate rent for any normal property here
        end
    end
end

