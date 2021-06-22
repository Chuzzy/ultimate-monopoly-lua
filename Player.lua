--- A player in the game of Ultimate Monopoly.
---@class Player
---@field color string The color of the seat this player is sitting at.
---@field token_guid string GUID of this player's token.
---@field money integer The amount of money this player has.
---@field location Space The space this player is currently on.
---@field lost_turns integer The number of turns this player is set to "lose".
---@field turns_in_jail integer The number of turns this player has spent in jail.
---@field owned_properties table<integer, Property> The properties owned by this player.
---@field action_cards table<integer, ActionCard> The action cards owned by this player.
---@field bankrupt boolean Whether this player is bankrupt.
local Player = {}
Player.__index = {}

require("Names")

---Creates a new Player.
---@param color string The color of the seat.
---@param token_guid string The GUID of the playing token.
---@param starting_money integer The amount of money to start with.
---@param game Game The instance of Game this player is using.
---@return Player
function Player.new(color, token_guid, starting_money, game)
    ---@type Player
    local self = setmetatable({}, Player)
    self.color = color
    self.token_guid = token_guid
    self.money = starting_money
    self.location = game.board.spaces[Names.Go]
    return self
end
