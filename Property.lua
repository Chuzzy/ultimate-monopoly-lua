--- A property in Ultimate Monopoly.
---@class Property
---@field name string
---@field cost integer
---@field group string
---@field rent_values table
---@field improvement_cost integer
---@field improvements integer
---@field owner Player
local Property = {}
Property.__index = Property

--- Create a new Property.
---@param name string
---@param cost integer
---@param group string
---@param rent_values table
---@param improvement_cost integer
---@return Property
function Property.new(name, cost, group, rent_values, improvement_cost)
    local self = setmetatable({}, Property)
    self.name = name
    self.cost = cost
    self.group = group
    self.rent_values = rent_values
    self.improvement_cost = improvement_cost
    self.improvements = 0
    return self
end

--- Calculate the rent on this property.
---@param dice_total integer
---@return integer
function Property:rent(dice_total)
    if not self.owner then
        return 0
    else
        if self.group == "rail" then
            local rent_multiplier = self.improvements + 1 -- Double rent for improved railroad
            return self.rent_values[self.owner.railroadCount()] * rent_multiplier
        elseif self.group == "cab" then
            local rent_multiplier = self.improvements + 1 -- Double rent for improved cab co
            return self.rent_values[self.owner.cabCompanyCount()] * rent_multiplier
        elseif self.group == "utility" then
            return dice_total * self.rent_values[self.owner.utilityCount()]
        else
            if self.improvements == -1 then -- If property is mortgaged
                return 0 -- No rent for mortgaged properties
            elseif self.improvements > 1 then -- If property has buildings
                return self.rent_values[self.improvements]
            else
                local unimproved_rent = self.rent_values[0]
                -- TODO: Calculate double/triple rent if necessary
                return unimproved_rent
            end
        end
    end
end
