--- A game of Ultimate Monopoly.
---@class UMGame
---@field board Board The game board.
---@field players table<number, UMPlayer> The players of the game.
---@field players_by_color table<string, UMPlayer> The players of the game by color.
---@field current_turn_index integer The current player.
---@field waiting_on UMPlayer The player who is holding up progression of the game.
---@field turn_count integer The number of turns.
---@field debts table<number, Debt> Array of unpaid debts.
---@field unowned_properties table<integer, Property> Array of unowned_properties.
---@field cash_pool integer Number of dollars in the cash pool.
---@field state GameState The current game state.
---@field money_changed_handler function Event handler that is called when money changes hands.
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
    self.unowned_properties = Property.generateUMProperties()
    self.cash_pool = 0
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
---@param space_name string The name of the space.
---@return table<integer, UMPlayer> occupants
function UMGame:getOccupantsOnSpace(space_name)
    local occupants = {}
    for _, player in ipairs(self.players) do
        assert(player.location)
        if player.location.name == space_name then
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
    local total = die1 + die2
    if speed_die == 6 then
        print("Bus")
    elseif speed_die == 5 or speed_die == 4 then
        print("Mr. Monopoly")
    else
        total = total + speed_die
    end
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
    self:handleSpaceAction()
end

---Called when the current player lands on a new space.
function UMGame:handleSpaceAction()
    self.state = GameState.POST_MOVEMENT
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
        error("game is not in the post movement state", 2)
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
    pcall(self.money_changed_handler, Debt.new(nil, creditor, amount, reason))
end

---Gives the player the property and deducts the cost from them.
---@param buyer UMPlayer The player buying the property.
---@param property Property The sold property.
function UMGame:sellPropertyTo(buyer, property)
    --TODO: Game:sellPropertyTo
end
