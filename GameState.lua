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
}
