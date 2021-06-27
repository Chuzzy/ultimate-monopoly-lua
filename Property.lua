--- A property in Ultimate Monopoly.
---@class Property
---@field name string The name of the property.
---@field cost integer The price of the property.
---@field group string The name of the group this property belongs to.
---@field rent_values integer[] The amounts of rent owed on this property.
---@field improvement_cost integer The cost to build an improvement.
---@field improvements integer The number of improvements.
---@field owner UMPlayer The owner of the property.
Property = {}
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

Property.colors = {
    ["light pink"] = "#ffaaaa",
    ["light green"] = "#80ff80",
    cream = "#ffe680",
    teal = "#008066",
    wine = "#800033",
    gold = "#aa8800",
    peach = "#ffb380",
    maroon = "#800000",
    purple = "#580c39",
    ["light blue"] = "#87a5d7",
    pink = "#ef3878",
    orange = "#f58023",
    red = "#d40000",
    yellow = "#ffcc00",
    green = "#098733",
    ["dark blue"] = "#284e9c",
    white = "#ffffff",
    black = "#000000",
    gray = "#808080",
    brown = "#aa4400"
}

--- Calculate the rent on this property.
---@param dice_total integer
---@return integer
function Property:rent(dice_total)
    if not self.owner or self.improvements == -1 then
        return 0
    elseif self.group == "rail" or self.group == "cab" then
        local rent_multiplier = self.improvements + 1 -- Double rent for improved transit station/cab company
        return self.rent_values[self.owner:countPropertiesOwnedInGroup(self.group)] * rent_multiplier
    elseif self.group == "utility" then
        return dice_total * self.rent_values[self.owner:countPropertiesOwnedInGroup("utility")]
    elseif self.improvements > 1 then -- If property has buildings
        return self.rent_values[self.improvements]
    else
        local unimproved_rent = self.rent_values[0]
        -- TODO: Calculate double/triple rent if necessary
        return unimproved_rent
    end
end
