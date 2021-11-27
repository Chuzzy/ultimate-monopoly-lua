--- A property in Ultimate Monopoly.
---@class Property
---@field name string The name of the property.
---@field cost integer The price of the property.
---@field group string The name of the group this property belongs to.
---@field rent_values integer[] The amounts of rent owed on this property.
---@field improvement_cost integer The cost to build an improvement.
---@field max_improvements integer The maximum number of improvements - 6 on normal properties and 1 on railroads and cab companies.
---@field improvements integer The number of improvements.
---@field mortgage_value integer The income when the property is mortgaged.
---@field unmortgage_cost integer The cost to unmortgage the property.
---@field owner UMPlayer The owner of the property.
Property = {}
Property.__index = Property
---@type table<string, integer>
Property.counts = {}
---@type table<string, Property[]>
Property.properties_in_group = {}

--- Create a new Property.
---@param name string
---@param cost integer
---@param group string
---@param rent_values table
---@param improvement_cost integer
---@param max_improvements integer
---@return Property
function Property.new(name, cost, group, rent_values, improvement_cost, max_improvements)
    local self = setmetatable({}, Property)
    self.name = name
    self.cost = cost
    self.group = group
    self.rent_values = rent_values
    self.improvement_cost = improvement_cost
    self.max_improvements = max_improvements
    self.improvements = 0
    self.mortgage_value = math.floor(cost / 2)
    self.unmortgage_cost = math.floor(cost * 0.55)
    Property.counts[self.group] = (Property.counts[self.group] or 0) + 1
    Property.properties_in_group[self.group] = Property.properties_in_group[self.group] or {}
    table.insert(Property.properties_in_group[self.group], self)
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
    brown = "#aa4400",
    rail = "#000000",
    cab = "#FFFF8D",
    utility = "#696969"
}

---Set containing properties which have bright colors
---and should be displayed with black text.
Property.bright_colors = {
    ["light pink"] = true,
    ["light green"] = true,
    cream = true,
    peach = true,
    ["light blue"] = true,
    pink = true,
    yellow = true,
    white = true,
    cab = true,
}

--- Calculates the rent multiplier on this property.
--- This determines whether a player collects triple rent
--- for a monopoly or double rent for a majority.
---@return integer
function Property:rent_multiplier()
    local rent_multiplier = 1
    local properties_owned_in_group = self.owner:countPropertiesOwnedInGroup(self.group)
    local properties_in_group = Property.counts[self.group]
    if properties_owned_in_group == properties_in_group then
        rent_multiplier = 3
    elseif properties_owned_in_group > properties_in_group / 2 then
        rent_multiplier = 2
    end
    return rent_multiplier
end

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
        return self.rent_values[1] * self:rent_multiplier()
    end
end
