--- A game of Ultimate Monopoly.
---@class UMGame
---@field board Board The game board.
---@field players table<number, UMPlayer> The players of the game.
---@field players_by_color table<string, UMPlayer> The players of the game by color.
---@field current_turn_index integer The current player.
---@field waiting_on UMPlayer The player who is holding up progression of the game.
---@field turn_count integer The number of turns.
---@field debts table<number, Debt> Array of unpaid debts.
---@field properties table<string, Property> Array of all properties.
---@field cash_pool integer Number of dollars in the cash pool.
---@field house_count integer Number of remaining houses.
---@field hotel_count integer Number of remaining hotels.
---@field skyscraper_count integer Number of remaining skyscrapers.
---@field state GameState The current game state.
---@field dice_roll integer[] The values of the dice that were rolled this turn.
---@field dice_total integer The sum of the values of the dice.
---@field money_changed_handler function Event handler that is called when money changes hands.
---@field property_changed_handler function Event handler that is called when property changes owners.
UMGame = {}
UMGame.__index = UMGame

require("GameState")
require("UMPlayer")
require("Property")
require("Properties")
require("Debt")

function UMGame.new()
    --TODO: Allow loading game from JSON savedata
    local self = setmetatable({}, UMGame)
    self.board = Board.new()
    self.players = {}
    self.players_by_color = {}
    self.turn_count = 0
    self.debts = {}
    self.properties = Property.generateUMProperties()
    self.cash_pool = 0
    self.house_count = 84
    self.hotel_count = 36
    self.skyscraper_count = 20
    self.state = {name = GameState.UNBEGUN}
    return self
end

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
function UMGame:createPlayer(color, token_guid, starting_money)
    assert(self.state.name == GameState.UNBEGUN, "cannot create player when the game has started")
    local new_player = UMPlayer.new(color, token_guid, starting_money, self.board.spaces[Names.go])
    table.insert(self.players, new_player)
    self.players_by_color[color] = new_player
end

---Returns an array of players who are on a particular space.
---@param space Space The space.
---@return table<integer, UMPlayer> occupants
function UMGame:getOccupantsOnSpace(space)
    local occupants = {}
    for _, player in ipairs(self.players) do
        assert(player.location)
        if player.location == space then
            table.insert(occupants, player)
        end
    end
    return occupants
end

---Starts the game.
---@param starting_color string The player color who is going first.
function UMGame:start(starting_color)
    assert(starting_color, "UMGame:start - color is nil")
    for i, player in ipairs(self.players) do
        if player.color == starting_color then
            self.current_turn_index = i
            self.state = GameState.PREMOVE
            return
        end
    end
    error("no such player " .. starting_color)
end

---Returns the player whose turn it is.
---@return UMPlayer current_player The player whose turn it is.
function UMGame:whoseTurn()
    return self.players[self.current_turn_index]
end

function UMGame:submitDiceRoll(die1, die2, speed_die)
    self.dice_roll = {die1, die2, speed_die}
    local total = die1 + die2
    if speed_die == 6 then
        print("Bus")
    elseif speed_die == 5 or speed_die == 4 then
        print("Mr. Monopoly")
    else
        total = total + speed_die
    end
    self.dice_total = total
    local visited_spaces = self.board:diceRoll(self:whoseTurn().location, total)
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
        self:payFromBank(self:whoseTurn(), 200, "for passing Go")
    end
    if has_passed_payday and destination ~= self.board.spaces[Names.payday] then
        if total % 2 == 0 then
            self:payFromBank(self:whoseTurn(), 400, "for passing Payday with an even roll")
        else
            self:payFromBank(self:whoseTurn(), 300, "for passing Payday with an odd roll")
        end
    end
    if has_passed_bonus and destination ~= self.board.spaces[Names.bonus] then
        self:payFromBank(self:whoseTurn(), 250, "for passing Bonus")
    end
    self:movePlayer(self:whoseTurn(), destination)
end

---Called when the current player lands on a new space.
function UMGame:handleSpaceAction()
    self:whoseTurn():act(self)
end

---Shows the property UI.
---@param property Property The property to display.
---@param show_controls_to UMPlayer The player to show the building controls to, if any.
---@param show_purchase_controls boolean True to show buy/auction controls instead of building.
function UMGame:showPropertyInfo(property, show_controls_to, show_purchase_controls)
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
        end
        --Weird bug: changing the text also changes the text color to black.
        --Hence the text color is reset.
        UI.setAttribute("DowngradeBtn", "textColor", "White")
        UI.setAttribute("UpgradeBtn", "textColor", "White")
    end
    UI.setAttribute("PropertyCard", "active", "true")
end

function UMGame:hidePropertyInfo()
    UI.setAttribute("PropertyCard", "active", "false")
end

---Moves a player to a new position on the board.
---@param player UMPlayer The player to move.
---@param destination Space The space on the board to move to.
function UMGame:movePlayer(player, destination)
    if not destination then
        error("destination cannot be empty", 2)
    end
    player.location = destination
end

function UMGame:nextTurn()
    if self.state ~= GameState.POST_MOVEMENT then
        --error("game is not in the post movement state", 2)
    end
    self.current_turn_index = (self.current_turn_index % #self.players) + 1
    self.state = GameState.PREMOVE
end

---Gives a player money from the bank.
---@param creditor UMPlayer The recipient of the money.
---@param amount integer The amount of money to be paid.
---@param reason string The reason for getting the money
function UMGame:payFromBank(creditor, amount, reason)
    creditor.money = creditor.money + amount
    if self.money_changed_handler then
        self.money_changed_handler(Debt.new(nil, creditor, amount, reason))
    end
end

---Gives the player the property and deducts the cost from them.
---@param buyer UMPlayer The player buying the property. If nil, the current player.
---@param property Property The sold property. If nil, the buyer's location.
function UMGame:sellPropertyTo(buyer, property)
    buyer = buyer or self:whoseTurn()
    property = property or Utils.spaceToProperty(buyer.location, self)
    assert(buyer.money >= property.cost, buyer:getName() .. " can't afford " .. property.name)
    buyer.money = buyer.money - property.cost
    buyer.owned_properties[property.name] = property
    property.owner = buyer
    if self.money_changed_handler then
        self.money_changed_handler(Debt.new(buyer, nil, property.cost, "for " .. property.name))
    end
    if self.property_changed_handler then
        self.property_changed_handler(property)
    end
end
