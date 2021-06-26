--- A game of Ultimate Monopoly.
---@class Game
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
Game = {}
Game.__index = Game

require("GameState")
require("UMPlayer")
require("Property")
require("Properties")

function Game.new()
    --TODO: Allow loading game from JSON savedata
    local self = setmetatable({}, Game)
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

function Game.speedDieValue(die)
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
function Game:createPlayer(color, token_guid, starting_money)
    assert(self.state.name == GameState.UNBEGUN, "cannot create player when the game has started")
    local new_player = UMPlayer.new(color, token_guid, starting_money, self.board.spaces[Names.go])
    table.insert(self.players, new_player)
    self.players_by_color[color] = new_player
end

---Returns an array of players who are on a particular space.
---@param space_name string The name of the space.
---@return table<integer, UMPlayer> occupants
function Game:getOccupantsOnSpace(space_name)
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
function Game:start(starting_color)
    assert(starting_color, "Game:start - color is nil")

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
function Game:whoseTurn()
    return self.players[self.current_turn_index]
end

function Game:submitDiceRoll(die1, die2, speed_die)
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
    self:movePlayer(self:whoseTurn(), destination)
end

function Game:handle()
    
end

---Moves a player to a new position on the board.
---@param player UMPlayer The player to move.
---@param destination Space The space on the board to move to.
function Game:movePlayer(player, destination)
    if not destination then
        error("destination cannot be empty", 2)
    end
    player.location = destination
end

function Game:nextTurn()
    if self.state ~= GameState.POST_MOVEMENT then
        error("game is not in the post movement state", 2)
    end
    self.current_turn_index = (self.current_turn_index % #self.players) + 1
    self.state = GameState.PREMOVE
end

---Gives the player the property and deducts the cost from them.
---@param buyer UMPlayer The player buying the property.
---@param property Property The sold property.
function Game:sellPropertyTo(buyer, property)
    --TODO: Game:sellPropertyTo
end
