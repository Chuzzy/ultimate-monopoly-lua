--- A game of Ultimate Monopoly.
---@class Game
---@field board Board The game board.
---@field players table<number, Player> The players of the game.
---@field current_turn Player The current player.
---@field waiting_on Player The player who is holding up progression of the game.
---@field turn_count integer The number of turns.
---@field debts table<number, Debt> Array of unpaid debts.
---@field cash_pool integer Number of dollars in the cash pool.
---@field state GameState The current game state.
local Game = {}
Game.__index = Game

function Game.new()
    --TODO: Allow loading game from JSON savedata
    local self = setmetatable({}, Game)
    self.board = Board.new()
    self.players = {}
    self.turn_count = 0
    self.debts = {}
    self.cash_pool = 0
    self.state = 0
    return self
end
