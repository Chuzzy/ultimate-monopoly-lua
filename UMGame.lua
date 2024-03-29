require("GameState")
require("UMPlayer")
require("Property")
require("Properties")
require("PropertyUI")
require("Debt")

--- The game of Ultimate Monopoly.
---@class UMGame
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
---@field transactions table<Property, integer> Array of transactions that have yet to be committed.
---@field dice_roll integer[] The values of the dice that were rolled this turn.
---@field dice_total integer The sum of the values of the dice.
---@field money_changed_handler function Event handler that is called when money changes hands.
---@field property_changed_handler function Event handler that is called when property changes owners.
---@field player_moved_handler function Event handler that is called when players move.
UMGame = {
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
    local new_player = UMPlayer.new(color, token_guid, starting_money, Board.spaces[Names.go])
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

    local visited_spaces = Board.diceRoll(UMGame.whoseTurn().location, total, UMGame.whoseTurn().reversed)
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

    if has_passed_payday and destination ~= Board.spaces[Names.payday] then
        if total % 2 == 0 then
            UMGame.payFromBank(UMGame.whoseTurn(), 400, "for passing Payday with an even roll")
        else
            UMGame.payFromBank(UMGame.whoseTurn(), 300, "for passing Payday with an odd roll")
        end
    end

    if has_passed_bonus and destination ~= Board.spaces[Names.bonus] then
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
    --TODO: Call this only when game state is post move
    createManagementBoardButtons(UMGame.whoseTurn())
end

---Downgrades the selected property.
function UMGame.downgradeProperty()
    assert(PropertyUI.selected_property, "No property is currently selected to be downgraded")
    if not UMGame.transactions then
        changeActionButtonsToImprovementMode()
        UMGame.transactions = {}
    end
    if PropertyUI.selected_property.improvements + (UMGame.transactions[PropertyUI.selected_property] or 0) == -1 then
        Utils.safeMsg(PropertyUI.selected_property.name .. " is already mortgaged.", Color.Red, UMGame.whoseTurn().color)
        return
    end
    UMGame.transactions[PropertyUI.selected_property] = (UMGame.transactions[PropertyUI.selected_property] or 0) - 1
    UMGame.updateSideTextWithTransactions()
    UMGame.updatePropertyUI()
end

---Upgrades the selected property.
function UMGame.upgradeProperty()
    assert(PropertyUI.selected_property, "No property is currently selected to be upgraded")
    if not UMGame.transactions then
        changeActionButtonsToImprovementMode()
        UMGame.transactions = {}
    end
    if PropertyUI.selected_property.improvements + (UMGame.transactions[PropertyUI.selected_property] or 0) == PropertyUI.selected_property.max_improvements then
        Utils.safeMsg(PropertyUI.selected_property.name .. " is already at the maximum number of buildings.", Color.Red, UMGame.whoseTurn().color)
        return
    end
    UMGame.transactions[PropertyUI.selected_property] = (UMGame.transactions[PropertyUI.selected_property] or 0) + 1
    UMGame.updateSideTextWithTransactions()
    UMGame.updatePropertyUI()
end

function UMGame.cancelImprovements()
    PropertyUI.hide()
    resetActionButtons()
    UMGame.transactions = nil
    Notes.setNotes("")
end

function UMGame.confirmImprovements()
   --TODO: Validate even build rule
   --TODO: Implement UMGame.confirmImprovements
end

---Updates the text on the side with info about
function UMGame.updateSideTextWithTransactions()
    local result = {}
    local net_profit = 0
    for property, upgrade_count in pairs(UMGame.transactions) do
        if upgrade_count ~= 0 then
            local buy_or_sell_text
            local cost_or_gain_text

            if upgrade_count > 0 then
                buy_or_sell_text = "[00FF00]Buy[-]"
                cost_or_gain_text = property.improvement_cost * upgrade_count
                net_profit = net_profit - cost_or_gain_text
            else
                buy_or_sell_text = "[CC0000]Sell[-]"
                cost_or_gain_text = property.improvement_cost / 2 * upgrade_count * -1
                net_profit = net_profit + cost_or_gain_text
            end

            upgrade_count = math.abs(upgrade_count)
            local buildings_text = upgrade_count == 1 and "building" or "buildings"
            local property_text = string.format("[%s]%s[-]", Property.colors[property.group]:sub(2), property.name)
            table.insert(result, string.format("%s %i %s on %s for $%s", buy_or_sell_text, upgrade_count, buildings_text, property_text, cost_or_gain_text))
        end
    end
    local net_profit_prefix = net_profit < 0 and "-$" or "+$"
    table.insert(result, "\nTotal: " .. net_profit_prefix .. math.abs(net_profit))
    Notes.setNotes(table.concat(result, "\n"))
end

function UMGame.updatePropertyUI()
    -- The final number of improvements the player wants to have on this property once they confirm the transcations.
    local proposed_improvement_count = PropertyUI.selected_property.improvements + (UMGame.transactions and UMGame.transactions[PropertyUI.selected_property] or 0)
    local property_is_mortgaged = proposed_improvement_count == -1
    local property_is_maxed_out = proposed_improvement_count == PropertyUI.selected_property.max_improvements

    PropertyUI.setMortgaged(property_is_mortgaged)

    -- Highlight the correct rent row based on the proposed improvement count
    -- TODO: Calculate transport properties correctly
    if not property_is_mortgaged then
        if PropertyUI.selected_property.group == "rail" or PropertyUI.selected_property.group == "cab" then
            PropertyUI.multiplyTransportRentValues(1 + proposed_improvement_count)
            PropertyUI.setActiveRentRow(PropertyUI.selected_property.owner:countPropertiesOwnedInGroup(PropertyUI.selected_property.group))
        elseif proposed_improvement_count == 0 then
            local rent_multiplier = PropertyUI.selected_property:rent_multiplier()
            if rent_multiplier == 3 then
                PropertyUI.setActiveRentRow("Monopoly")
            elseif rent_multiplier == 2 then
                PropertyUI.setActiveRentRow("Majority")
            else
                PropertyUI.setActiveRentRow(1)
            end
        else
            PropertyUI.setActiveRentRow(proposed_improvement_count + 1)
        end
    end

    if property_is_mortgaged then
        PropertyUI.setUpgradeButtonUnmortgage()
    else
        PropertyUI.setUpgradeButtonBuy()
        if proposed_improvement_count == 0 then
            PropertyUI.setDowngradeButtonMortgage()
        else
            PropertyUI.setDowngradeButtonSell()
        end
    end

    -- Show the upgrade button if fewer than the max amount of improvements are present
    PropertyUI.setUpgradeButtonVisible(not property_is_maxed_out)

    -- Show the downgrade button if the property is not mortgaged
    PropertyUI.setDowngradeButtonVisible(not property_is_mortgaged)
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
        UMGame.player_moved_handler(player, destination)
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
    property = property or Utils.spaceToProperty(buyer.location)
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
