--- A game of Ultimate Monopoly.
---@class Game
---@field board Board The game board.
---@field players table<number, Player> The players of the game.
---@field current_turn_index integer The current player.
---@field waiting_on Player The player who is holding up progression of the game.
---@field turn_count integer The number of turns.
---@field debts table<number, Debt> Array of unpaid debts.
---@field cash_pool integer Number of dollars in the cash pool.
---@field state GameState The current game state.
Game = {}
Game.__index = Game

require("GameState")

function Game.new(json_save)
    --TODO: Allow loading game from JSON savedata
    local self = setmetatable({}, Game)
    self.board = Board.new()
    self.players = {}
    self.turn_count = 0
    self.debts = {}
    self.cash_pool = 0
    self.state = GameState.UNBEGUN
    return self
end

---Creates a new player and puts them on Go.
---@param color string The color of the seat the player is sitting at.
---@param token_guid string The GUID of the player's playing token.
---@param starting_money integer How much money the player starts with.
function Game:createPlayer(color, token_guid, starting_money)
    if self.state ~= GameState.UNBEGUN then
        error("cannot create player when the game has started", 2)
    end
    local new_player = Player.new(color, token_guid, starting_money)
    table.insert(self.players, new_player)
end

---Starts the game.
---@param color string The player color who is going first.
function Game:start(color)
    for i, player in ipairs(self.players) do
        if player.color == color then
            self.current_turn_index = i
            self.state = GameState.PREMOVE
            return
        end
    end
end

---Returns the player whose turn it is.
---@return Player current_player The player whose turn it is.
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
    self.state = GameState.POST_MOVEMENT
end

---Moves a player to a new position on the board.
---@param player Player The player to move.
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
