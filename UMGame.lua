require("GameState")
require("UMPlayer")
require("Property")
require("Properties")
require("Debt")

--- The game of Ultimate Monopoly.
---@class UMGame
---@field board Board The game board.
---@field players UMPlayer[] The players of the game.
---@field players_by_color table<string, UMPlayer> The players of the game by color.
---@field current_turn_index integer The current player.
---@field waiting_on UMPlayer The player who is holding up progression of the game.
---@field turn_count integer The number of turns.
---@field debts Debt[] Array of unpaid debts.
---@field properties table<string, Property> Array of all properties.
---@field cash_pool integer Number of dollars in the cash pool.
---@field house_count integer Number of remaining houses.
---@field hotel_count integer Number of remaining hotels.
---@field skyscraper_count integer Number of remaining skyscrapers.
---@field state GameState The current game state.
---@field selected_property Property The property that the player has chosen.
---@field transactions table<Property, integer> Array of transactions that have yet to be committed.
---@field dice_roll integer[] The values of the dice that were rolled this turn.
---@field dice_total integer The sum of the values of the dice.
---@field money_changed_handler function Event handler that is called when money changes hands.
---@field property_changed_handler function Event handler that is called when property changes owners.
---@field player_moved_handler function Event handler that is called when players move.
UMGame = {
    board = Board.new(),
    players = {},
    players_by_color = {},
    turn_count = 0,
    debts = {},
    properties = Property.generateUMProperties(),
    cash_pool = 0,
    house_count = 84,
    hotel_count = 36,
    skyscraper_count = 20,
    state = {name = GameState.UNBEGUN},
}

function UMGame.speedDieValue(die)
    if die > 3 then
        return 0
    else
        return die
    end
end

---Creates a new player and puts them on Go.
---@param color string The color of the seat the player is sitting at.
---@param token_guid string The GUID of the player's playing token.
---@param starting_money integer How much money the player starts with.
---@return UMPlayer new_player The new player.
function UMGame.createPlayer(color, token_guid, starting_money)
    assert(UMGame.state.name == GameState.UNBEGUN, "cannot create player when the game has started")
    local new_player = UMPlayer.new(color, token_guid, starting_money, UMGame.board.spaces[Names.go])
    table.insert(UMGame.players, new_player)
    UMGame.players_by_color[color] = new_player
    return new_player
end

---Returns an array of players who are on a particular space.
---@param space Space The space.
---@return table<integer, UMPlayer> occupants
function UMGame.getOccupantsOnSpace(space)
    local occupants = {}
    for _, player in ipairs(UMGame.players) do
        assert(player.location)
        if player.location == space then
            table.insert(occupants, player)
        end
    end
    return occupants
end

---Starts the game.
---@param starting_color string The player color who is going first.
function UMGame.start(starting_color)
    assert(starting_color, "UMGame.start - color is nil")
    for i, player in ipairs(UMGame.players) do
        if player.color == starting_color then
            UMGame.current_turn_index = i
            UMGame.state = GameState.PREMOVE
            return
        end
    end
    error("no such player " .. starting_color)
end

---Returns the player whose turn it is.
---@return UMPlayer current_player The player whose turn it is.
function UMGame.whoseTurn()
    return UMGame.players[UMGame.current_turn_index]
end

function UMGame.submitDiceRoll(die1, die2, speed_die)
    UMGame.dice_roll = {die1, die2, speed_die}
    local total = die1 + die2
    if speed_die == 6 then
        print("Bus")
    elseif speed_die == 5 or speed_die == 4 then
        print("Mr. Monopoly")
    else
        total = total + speed_die
    end
    UMGame.dice_total = total

    local visited_spaces = UMGame.board:diceRoll(UMGame.whoseTurn().location, total, UMGame.whoseTurn().reversed)
    local destination = visited_spaces[#visited_spaces]

    -- Handle passing Go, Payday and Bonus
    local has_passed_go, has_passed_payday, has_passed_bonus
    for _, space in ipairs(visited_spaces) do
        if not has_passed_go and space.name == Names.go then
            has_passed_go = true
        end
        if not has_passed_payday and space.name == Names.payday then
            has_passed_payday = true
        end
        if not has_passed_bonus and space.name == Names.bonus then
            has_passed_bonus = true
        end
    end

    if has_passed_go then
        UMGame.payFromBank(UMGame.whoseTurn(), 200, "for passing Go")
    end

    if has_passed_payday and destination ~= UMGame.board.spaces[Names.payday] then
        if total % 2 == 0 then
            UMGame.payFromBank(UMGame.whoseTurn(), 400, "for passing Payday with an even roll")
        else
            UMGame.payFromBank(UMGame.whoseTurn(), 300, "for passing Payday with an odd roll")
        end
    end

    if has_passed_bonus and destination ~= UMGame.board.spaces[Names.bonus] then
        UMGame.payFromBank(UMGame.whoseTurn(), 250, "for passing Bonus")
    end

    UMGame.movePlayer(UMGame.whoseTurn(), destination)

    if UMGame.whoseTurn().reversed then
        UMGame.whoseTurn().reversed = false
        if speed_die == 6 then
            broadcastToAll(UMGame.whoseTurn():getName() .. " has missed the bus!")
        end
    end
end

---Moves the current player directly to the specified space.
---Players do not pass salary squares or the like.
---@param destination Space The space to move the player.
function UMGame.moveDirectlyTo(destination)
    UMGame.movePlayer(UMGame.whoseTurn(), destination)
end

---Called when the current player lands on a new space.
function UMGame.handleSpaceAction()
    UMGame.whoseTurn():act()
end

---Shows the property UI.
---@param property Property The property to display.
---@param show_controls_to UMPlayer The player to show the building controls to, if any.
---@param show_purchase_controls boolean True to show buy/auction controls instead of building.
function UMGame.showPropertyInfo(property, show_controls_to, show_purchase_controls)
    UI.setValue("PropertyName", property.name)
    UI.setAttribute("PropertyTitle", "color", Property.colors[property.group])
    UI.setAttribute("PropertyName", "color", Property.bright_colors[property.group] and "Black" or "White")

    if property.group == "rail" then
        UI.setAttribute("RentMajorityRow", "active", "false")
        UI.setAttribute("RentMonopolyRow", "active", "false")
        UI.setAttribute("Rent5Row", "active", "false")
        UI.setAttribute("Rent6Row", "active", "false")
        UI.setAttribute("Rent7Row", "active", "false")
        UI.setValue("Rent2Label", "With Two Railroads")
        UI.setValue("Rent3Label", "With Three Railroads")
        UI.setValue("Rent4Label", "With Four Railroads")

        for i, rent in ipairs(property.rent_values) do
            UI.setValue("Rent" .. i .. "Value", "$" .. rent)
        end
    elseif property.group == "cab" then
        UI.setAttribute("RentMajorityRow", "active", "false")
        UI.setAttribute("RentMonopolyRow", "active", "false")
        UI.setAttribute("Rent5Row", "active", "false")
        UI.setAttribute("Rent6Row", "active", "false")
        UI.setAttribute("Rent7Row", "active", "false")
        UI.setValue("Rent2Label", "With Two Cab Companies")
        UI.setValue("Rent3Label", "With Three Cab Companies")
        UI.setValue("Rent4Label", "With Four Companies")

        for i, rent in ipairs(property.rent_values) do
            UI.setValue("Rent" .. i .. "Value", "$" .. rent)
        end
    elseif property.group == "utility" then
        UI.setAttribute("RentMajorityRow", "active", "true")
        UI.setAttribute("RentMonopolyRow", "active", "true")
        UI.setAttribute("Rent5Row", "active", "true")
        UI.setAttribute("Rent6Row", "active", "true")
        UI.setAttribute("Rent7Row", "active", "false")
        UI.setValue("RentMajorityLabel", "With Two Utilities")
        UI.setValue("RentMonopolyLabel", "With Three Utilities")
        UI.setValue("Rent2Label", "With Four Utilities")
        UI.setValue("Rent3Label", "With Five Utilities")
        UI.setValue("Rent4Label", "With Six Utilities")
        UI.setValue("Rent5Label", "With Seven Utilities")
        UI.setValue("Rent6Label", "With Eight Utilities")

        for i, id in ipairs({"Rent1Value", "RentMajorityValue", "RentMonopolyValue", "Rent2Value", "Rent3Value", "Rent4Value", "Rent5Value", "Rent6Value"}) do
            UI.setValue(id, property.rent_values[i] .. "x")
        end
    else
        UI.setAttribute("RentMajorityRow", "active", "true")
        UI.setAttribute("RentMonopolyRow", "active", "true")
        UI.setAttribute("Rent5Row", "active", "true")
        UI.setAttribute("Rent6Row", "active", "true")
        UI.setAttribute("Rent7Row", "active", "true")
        UI.setValue("RentMajorityLabel", "With Majority")
        UI.setValue("RentMonopolyLabel", "With Monopoly")
        UI.setValue("Rent2Label", "With 1 House")
        UI.setValue("Rent3Label", "With 2 Houses")
        UI.setValue("Rent4Label", "With 3 Houses")
        UI.setValue("Rent5Label", "With 4 Houses")
        UI.setValue("Rent6Label", "With Hotel")
        UI.setValue("Rent7Label", "With Skyscraper")
        UI.setValue("RentMajorityValue", "$" .. property.rent_values[1] * 2)
        UI.setValue("RentMonopolyValue", "$" .. property.rent_values[1] * 3)

        for i, rent in ipairs(property.rent_values) do
            UI.setValue("Rent" .. i .. "Value", "$" .. rent)
        end
        if Property.counts[property.group] == 2 then
            UI.setAttribute("RentMajorityRow", "active", "false")
        else
            UI.setAttribute("RentMajorityRow", "active", "true")
        end
    end
    if show_controls_to then
        UI.setAttribute("PropertyControlsRow", "visibility", show_controls_to.color)
        if show_purchase_controls then
            UI.setAttribute("DowngradeBtn", "text", "Auction")
            UI.setAttribute("DowngradeBtn", "tooltip", "Put " .. property.name .. " up for auction")
            UI.setAttribute("UpgradeBtn", "text", "Buy $" .. property.cost)
            UI.setAttribute("UpgradeBtn", "tooltip", "Buy " .. property.name .. " for $" .. property.cost)
            -- Bind the purchase/auction actions to the buttons underneath the property
            UI.setAttribute("UpgradeBtn", "onClick", "buyCurrentProperty")
            -- Use PropertyMortgagedRow to show improvement costs instead of mortgage information
            if property.improvement_cost then
                UI.setAttribute("PropertyMortgagedRow", "color", "White")
                UI.setAttribute("PropertyMortgagedText", "color", "Black")
                UI.setValue("PropertyMortgagedText", "Improvements cost $" .. property.improvement_cost .. " each")
                UI.setAttribute("PropertyMortgagedRow", "active", "true")
            else
                UI.setAttribute("PropertyMortgagedRow", "active", "false")
            end
        else
            UI.setAttribute("PropertyMortgagedRow", "color", "Red")
            UI.setAttribute("PropertyMortgagedText", "color", "White")
            UI.setValue("PropertyMortgagedText", "MORTGAGED")
            if property.improvements == -1 then
                UI.setAttribute("PropertyMortgagedRow", "active", "true")
            else
                UI.setAttribute("PropertyMortgagedRow", "active", "false")
            end
            --TODO: enable/disable buttons when property is mortgaged/has skyscraper
            UI.setAttribute("DowngradeBtn", "text", "+$" .. property.improvement_cost / 2)
            UI.setAttribute("DowngradeBtn", "tooltip", "Sell a building")
            UI.setAttribute("UpgradeBtn", "text", "-$" .. property.improvement_cost)
            UI.setAttribute("UpgradeBtn", "tooltip", "Buy a building")
            -- Bind the upgrade/downgrade actions to the buttons underneath the property
            UI.setAttribute("DowngradeBtn", "onClick", "downgradeProperty")
            UI.setAttribute("UpgradeBtn", "onClick", "upgradeProperty")
        end
        --Weird bug: changing the text also changes the text color to black.
        --Hence the text color is reset.
        UI.setAttribute("DowngradeBtn", "textColor", "White")
        UI.setAttribute("UpgradeBtn", "textColor", "White")
    end
    UI.setAttribute("PropertyCard", "active", "true")
    UMGame.selected_property = property
end

function UMGame.hidePropertyInfo()
    UI.setAttribute("PropertyCard", "active", "false")
    UMGame.selected_property = nil
end

---Puts the selected property up for auction.
function UMGame.downgradeProperty()
    if not UMGame.selected_property then
        error("No property is currently selected")
    end
    if not UMGame.transactions then
        --TODO: Rename top buttons
        UMGame.transactions = {}
    end
end

function UMGame.upgradeProperty()
    if not UMGame.selected_property then
        error("No property is currently selected")
    end
    if not UMGame.transactions then
        --TODO: Rename top buttons
        UMGame.transactions = {}
    end
    UMGame.transactions[UMGame.selected_property] = (UMGame.transactions[UMGame.selected_property] or 0) + 1
end

---Moves a player to a new position on the board.
---@param player UMPlayer The player to move.
---@param destination Space The space on the board to move to.
function UMGame.movePlayer(player, destination)
    if not destination then
        error("destination cannot be empty", 2)
    end
    local old_location = player.location
    player.location = destination
    if UMGame.player_moved_handler then
        UMGame.player_moved_handler(player, destination, old_location)
    end
end

function UMGame.nextTurn()
    if UMGame.state ~= GameState.POST_MOVEMENT then
        --error("game is not in the post movement state", 2)
    end
    UMGame.current_turn_index = (UMGame.current_turn_index % #UMGame.players) + 1
    UMGame.state = GameState.PREMOVE
end

---Gives a player money from the bank.
---@param creditor UMPlayer The recipient of the money.
---@param amount integer The amount of money to be paid.
---@param reason string The reason for getting the money
function UMGame.payFromBank(creditor, amount, reason)
    creditor.money = creditor.money + amount
    if UMGame.money_changed_handler then
        UMGame.money_changed_handler(Debt.new(nil, creditor, amount, reason))
    end
end

---Gives a player money from the cash pool.
---@param creditor UMPlayer The recipient of the money.
---@param amount integer The amount of money to be paid.
---@param reason string The reason for getting paid.
function UMGame.payFromPool(creditor, amount, reason)
    UMGame.cash_pool = UMGame.cash_pool - amount
    UMGame.payFromBank(creditor, amount, reason)
end

---Creates a new debt. If it can be paid off right now, it is paid off.
---Otherwise it is added to the list of unpaid debts.
---@param debtor UMPlayer
---@param creditor UMPlayer
---@param amount integer
---@param reason string
function UMGame.createDebt(debtor, creditor, amount, reason)
    local debt = Debt.new(debtor, creditor, amount, reason)
    if debt:isPayable() then
        UMGame.payDebt(debt)
    else
        table.insert(UMGame.debts, debt)
    end
end

---Pays off a debt. Will raise an error if the debtor can't pay it off.
---@param debt Debt A debt to be paid.
function UMGame.payDebt(debt)
    assert(debt:isPayable(), "Debtor is too poor: " .. debt:tostring() .. ". Debtor has $" .. debt.debtor.money)
    debt.debtor.money = debt.debtor.money - debt.amount
    if debt.creditor then
        debt.creditor.money = debt.creditor.money + debt.amount
    else
        UMGame.cash_pool = UMGame.cash_pool + debt.amount
    end
    if UMGame.money_changed_handler then
        UMGame.money_changed_handler(debt)
    end
end

---Gives money to a lucky player from everyone else's pockets.
---@param creditor UMPlayer The recipient of all the money.
---@param amount integer The amount of money to recieve from each player.
---@param reason string The reason for getting the money.
function UMGame.collectFromEachPlayer(creditor, amount, reason)
    for _, player in ipairs(UMGame.players) do
        if player ~= creditor then
            UMGame.createDebt(player, creditor, amount, reason)
        end
    end
end

---Gives money to everyone else from an unlucky player.
---@param debtor UMPlayer The player paying for all this.
---@param amount integer The amount of money to give each player.
---@param reason string The reason for paying the money
function UMGame.payEachPlayer(debtor, amount, reason)
    for _, player in ipairs(UMGame.players) do
        if player ~= debtor then
            UMGame.createDebt(debtor, player, amount, reason)
        end
    end
end

---Gives the player the property and deducts the cost from them.
---@param buyer UMPlayer The player buying the property. If nil, the current player.
---@param property Property The sold property. If nil, the buyer's location.
function UMGame.sellPropertyTo(buyer, property)
    buyer = buyer or UMGame.whoseTurn()
    property = property or Utils.spaceToProperty(buyer.location, UMGame)
    assert(buyer.money >= property.cost, buyer:getName() .. " can't afford " .. property.name)
    buyer.money = buyer.money - property.cost
    buyer.owned_properties[property.name] = property
    property.owner = buyer
    if UMGame.money_changed_handler then
        UMGame.money_changed_handler(Debt.new(buyer, nil, property.cost, "for " .. property.name))
    end
    if UMGame.property_changed_handler then
        UMGame.property_changed_handler(property)
    end
end
