---@class GameState
GameState = {
    -- The game hasn't started yet.
    UNBEGUN = 0,
    -- The player is about to move by choosing to roll or using a travel voucher.
    PREMOVE = 1,
    -- The dice are being rolled.
    ROLLING = 2,
    -- The player is moving.
    MOVING = 3,
    -- The player has finished moving.
    POST_MOVEMENT = 4,
    -- The player is managing their assets.
    MANAGING = 5,
    -- The player is setting up a trade.
    TRADING = 6,
    -- The game is waiting for an acceptance or refusal of a trade.
    TRADE_OFFER = 7,
}
