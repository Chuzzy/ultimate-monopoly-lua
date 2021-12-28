---Controls the Property info UI in the top-left.
---@class PropertyUI
---@field selected_property Property The property that is currently selected.
PropertyUI = {
    row_index = "",
    shown_property_type = "",
    all_rent_rows = {
        "Rent1Row", "RentMajorityRow", "RentMonopolyRow", "Rent2Row",
        "Rent3Row", "Rent4Row", "Rent5Row", "Rent6Row", "Rent7Row"
    },
    transport_unused_row_ids = {
        "RentMajorityRow", "RentMonopolyRow", "Rent5Row", "Rent6Row", "Rent7Row"
    },
    utility_rent_value_ids = {
        "Rent1Value", "RentMajorityValue", "RentMonopolyValue", "Rent2Value",
        "Rent3Value", "Rent4Value", "Rent5Value", "Rent6Value"
    },
    rail_rent_labels = {
        Rent2Label = "With Two Railroads",
        Rent3Label = "With Three Railroads",
        Rent4Label = "With Four Railroads"
    },
    cab_rent_labels = {
        Rent2Label = "With Two Cab Companies",
        Rent3Label = "With Three Cab Comapnies",
        Rent4Label = "With Four Cab Companies"
    },
    utility_rent_labels = {
        RentMajorityLabel = "With Two Utilities",
        RentMonopolyLabel = "With Three Utilities",
        Rent2Label = "With Four Utilities",
        Rent3Label = "With Five Utilities",
        Rent4Label = "With Six Utilities",
        Rent5Label = "With Seven Utilities",
        Rent6Label = "With Eight Utilities"
    },
    normal_rent_labels = {
        RentMajorityLabel = "With Majority",
        RentMonopolyLabel = "With Monopoly",
        Rent2Label = "With 1 House",
        Rent3Label = "With 2 Houses",
        Rent4Label = "With 3 Houses",
        Rent5Label = "With 4 Houses",
        Rent6Label = "With Hotel"
    },
    rent_row_element_id_suffixes = {
        "LabelCell", "Label", "ValueCell", "Value", "Row"
    }
}

---Shows the property UI.
---@param property Property
function PropertyUI.show(property)
    UI.setValue("PropertyName", property.name)
    UI.setAttribute("PropertyTitle", "color", Property.colors[property.group])
    UI.setAttribute("PropertyName", "color",
                    Property.bright_colors[property.group] and "Black" or
                        "White")
    UI.setAttribute("PropertyCard", "active", "true")
    if property.group == "rail" or property.group == "cab" then
        PropertyUI.shown_property_type = property.group
        PropertyUI.showTransportInfo(property)
    elseif property.group == "utility" then
        PropertyUI.shown_property_type = "utility"
        PropertyUI.showUtilityInfo(property)
    else
        PropertyUI.shown_property_type = "normal"
        PropertyUI.showNormalPropertyInfo(property)
    end
    PropertyUI.setMortgaged(property.improvements == -1)
    PropertyUI.selected_property = property
end

function PropertyUI.showNormalPropertyInfo(property)
    for _, row_id in ipairs(PropertyUI.transport_unused_row_ids) do
        UI.setAttribute(row_id, "active", "true")
    end
    for row_id, text in pairs(PropertyUI.normal_rent_labels) do
        UI.setValue(row_id, text)
    end

    for i, rent in ipairs(property.rent_values) do
        UI.setValue("Rent" .. i .. "Value", "$" .. rent)
    end
    UI.setValue("RentMajorityValue", "$" .. property.rent_values[1] * 2)
    UI.setValue("RentMonopolyValue", "$" .. property.rent_values[1] * 3)

    if Property.counts[property.group] == 2 then
        UI.setAttribute("RentMajorityRow", "active", "false")
    else
        UI.setAttribute("RentMajorityRow", "active", "true")
    end
end

function PropertyUI.showUtilityInfo(utility)
    for _, row_id in ipairs(PropertyUI.transport_unused_row_ids) do
        UI.setAttribute(row_id, "active", "true")
    end
    UI.setAttribute("Rent7Row", "active", "false")
    for row_id, text in pairs(PropertyUI.utility_rent_labels) do
        UI.setValue(row_id, text)
    end
    for i, id in ipairs(PropertyUI.utility_rent_value_ids) do
        UI.setValue(id, utility.rent_values[i] .. "x")
    end
end

function PropertyUI.showTransportInfo(transport)
    for _, row_id in ipairs(PropertyUI.transport_unused_row_ids) do
        UI.setAttribute(row_id, "active", "false")
    end
    for row_id, text in pairs(transport.group == "rail" and
                                   PropertyUI.rail_rent_labels or
                                   PropertyUI.cab_rent_labels) do
        UI.setValue(row_id, text)
    end
    for i, rent in ipairs(transport.rent_values) do
        UI.setValue("Rent" .. i .. "Value", "$" .. rent)
    end
end

function PropertyUI.multiplyTransportRentValues(multiplier)
    for i, rent in ipairs(PropertyUI.selected_property.rent_values) do
        UI.setValue("Rent" .. i .. "Value", "$" .. multiplier * rent)
    end
end

function PropertyUI.setActiveRentRow(row_index)
    if row_index ~= PropertyUI.row_index then
        if PropertyUI.row_index then
            PropertyUI.disableActiveRentOnRow(PropertyUI.row_index)
        end
        PropertyUI.enableActiveRentOnRow(row_index)
        PropertyUI.row_index = row_index
    end
end

function PropertyUI.disableActiveRentOnRow(row_index)
    for _, suffix in pairs(PropertyUI.rent_row_element_id_suffixes) do
        local id = "Rent" .. row_index .. suffix
        UI.setClass(id, "inactiveRent")
    end
end

function PropertyUI.enableActiveRentOnRow(row_index)
    for _, suffix in pairs(PropertyUI.rent_row_element_id_suffixes) do
        local id = "Rent" .. row_index .. suffix
        UI.setClass(id, "activeRent")
    end
end

---Sets whether this property should be mortgaged or not.
---@param is_mortgaged boolean
function PropertyUI.setMortgaged(is_mortgaged)
    if is_mortgaged then
        for _, row_id in ipairs(PropertyUI.all_rent_rows) do
            UI.setAttribute(row_id, "active", "false")
        end
        local mortgaged_text = "MORTGAGED\nfor $" .. PropertyUI.selected_property.mortgage_value
        .. "\nUnmortgage for $" .. PropertyUI.selected_property.unmortgage_cost
        UI.setAttribute("PropertyMortgagedRow", "color", "Red")
        UI.setAttribute("PropertyMortgagedText", "color", "White")
        UI.setValue("PropertyMortgagedText", mortgaged_text)
        UI.setAttribute("PropertyMortgagedRow", "active", "true")
    else
        UI.setAttribute("PropertyMortgagedRow", "active", "false")
        for i = 1, 4 do
            UI.setAttribute("Rent" .. i .. "Row", "active", "true")
        end
        if PropertyUI.shown_property_type ~= "rail" and
            PropertyUI.shown_property_type ~= "cab" then
            for _, row_id in ipairs(PropertyUI.transport_unused_row_ids) do
                UI.setAttribute(row_id, "active", "true")
            end
            if PropertyUI.shown_property_type == "utility" then
                UI.setAttribute("Rent7Row", "active", "false")
            end
        end
    end
end

---Shows the build controls on this property.
---@param player UMPlayer
function PropertyUI.showBuildControlsTo(player)
    local property = assert(PropertyUI.selected_property,
                            "There is no selected property to show build controls for.")

    UI.setAttribute("PropertyControlsRow", "visibility",
                    Debug.let_anyone_act and "" or player.color)

    UI.setAttribute("DowngradeBtn", "text",
                    "+$" .. (property.improvement_cost or 0) / 2)
    UI.setAttribute("DowngradeBtn", "tooltip", "Sell a building")

    UI.setAttribute("UpgradeBtn", "text", "-$" .. (property.improvement_cost or 0))
    UI.setAttribute("UpgradeBtn", "tooltip", "Buy a building")

    UI.setAttribute("DowngradeBtn", "onClick", "downgradeProperty")
    UI.setAttribute("UpgradeBtn", "onClick", "upgradeProperty")

    -- Weird bug: changing anything about the button also changes the text color to black.
    -- Hence the text color is reset.
    UI.setAttribute("DowngradeBtn", "textColor", "White")
    UI.setAttribute("UpgradeBtn", "textColor", "White")
end

function PropertyUI.setDowngradeButtonVisible(is_visible)
    UI.setAttribute("DowngradeBtn", "active", is_visible)
    UI.setAttribute("DowngradeBtn", "textColor", "White")
end

function PropertyUI.setDowngradeButtonMortgage()
    UI.setAttribute("DowngradeBtn", "text", "+$" .. PropertyUI.selected_property.mortgage_value)
    UI.setAttribute("DowngradeBtn", "tooltip", "Mortgage this property")
    UI.setAttribute("DowngradeBtn", "textColor", "White")
end

function PropertyUI.setDowngradeButtonSell()
    UI.setAttribute("DowngradeBtn", "text", "+$" .. (PropertyUI.selected_property.improvement_cost or 0) / 2)
    UI.setAttribute("DowngradeBtn", "tooltip", "Sell a building")
    UI.setAttribute("DowngradeBtn", "textColor", "White")
end

function PropertyUI.setUpgradeButtonVisible(is_visible)
    UI.setAttribute("UpgradeBtn", "active", is_visible)
    UI.setAttribute("UpgradeBtn", "textColor", "White")
end

function PropertyUI.setUpgradeButtonUnmortgage()
    UI.setAttribute("UpgradeBtn", "text", "-$" .. PropertyUI.selected_property.unmortgage_cost)
    UI.setAttribute("UpgradeBtn", "tooltip", "Unmortgage this property")
    UI.setAttribute("UpgradeBtn", "textColor", "White")
end

function PropertyUI.setUpgradeButtonBuy()
    UI.setAttribute("UpgradeBtn", "text", "-$" .. (PropertyUI.selected_property.improvement_cost or 0))
    UI.setAttribute("UpgradeBtn", "tooltip", "Buy a building")
    UI.setAttribute("UpgradeBtn", "textColor", "White")
end

---Shows the buy/auction buttons on this property.
---@param player UMPlayer
function PropertyUI.showPurchaseControlsTo(player)
    local property = assert(PropertyUI.selected_property,
                            "There is no selected property to show purchase controls for.")
    UI.setAttribute("PropertyControlsRow", "visibility",
                    Debug.let_anyone_act and "" or player.color)

    UI.setAttribute("DowngradeBtn", "text", "Auction")
    UI.setAttribute("DowngradeBtn", "tooltip",
                    "Put " .. property.name .. " up for auction")

    UI.setAttribute("UpgradeBtn", "text", "Buy $" .. property.cost)
    UI.setAttribute("UpgradeBtn", "tooltip",
                    "Buy " .. property.name .. " for $" .. property.cost)
    UI.setAttribute("UpgradeBtn", "onClick", "buyCurrentProperty")

    if property.improvement_cost then
        -- Use mortgage row to display improvement cost instead
        UI.setAttribute("PropertyMortgagedRow", "color", "White")
        UI.setAttribute("PropertyMortgagedText", "color", "Black")
        UI.setValue("PropertyMortgagedText", "Improvements cost $" ..
                        property.improvement_cost .. " each")
        UI.setAttribute("PropertyMortgagedRow", "active", "true")
    else
        UI.setAttribute("PropertyMortgagedRow", "active", "false")
    end

    -- Weird bug: changing anything about the button also changes the text color to black.
    -- Hence the text color is reset.
    UI.setAttribute("DowngradeBtn", "textColor", "White")
    UI.setAttribute("UpgradeBtn", "textColor", "White")
end

function PropertyUI.hideControls()
    UI.setAttribute("PropertyControlsRow", "visibility", "0")
end

function PropertyUI.hide()
    UI.setAttribute("PropertyCard", "active", "false")
    PropertyUI.selected_property = nil
end
