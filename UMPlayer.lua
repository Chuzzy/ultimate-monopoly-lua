--- A player in the game of Ultimate Monopoly.
---@class UMPlayer
---@field color string The color of the seat this player is sitting at.
---@field token_guid string GUID of this player's token.
---@field money integer The amount of money this player has.
---@field location Space The space this player is currently on.
---@field lost_turns integer The number of turns this player is set to "lose".
---@field turns_in_jail integer The number of turns this player has spent in jail.
---@field owned_properties table<integer, Property> The properties owned by this player.
---@field action_cards table<integer, ActionCard> The action cards owned by this player.
---@field bankrupt boolean Whether this player is bankrupt.
UMPlayer = {}
UMPlayer.__index = UMPlayer

require("Names")

---Creates a new UMPlayer.
---@param color string The color of the seat.
---@param token_guid string The GUID of the playing token.
---@param starting_money integer The amount of money to start with.
---@param location Space The location of the player. Usually Go.
---@return UMPlayer
function UMPlayer.new(color, token_guid, starting_money, location)
    ---@type UMPlayer
    local self = setmetatable({}, UMPlayer)
    self.color = color
    self.token_guid = token_guid
    self.money = starting_money
    assert(location, "location is nil")
    self.location = location
    assert(self.location, "self.location is nil")
    self.lost_turns = 0
    self.turns_in_jail = 0
    self.owned_properties = {}
    self.action_cards = {}
    self.bankrupt = false
    return self
end

function UMPlayer:getName()
    return Player[self.color] and Player[self.color].steam_name or self.color
end

function UMPlayer:act(game)
    self.location:act(game, self)
end

function UMPlayer:railroadCount()
    local count = 0
    for _, property in ipairs(self.owned_properties) do
        if property.group == "rail" then
            count = count + 1
        end
    end
    return count
end

function UMPlayer:cabCompanyCount()
    local count = 0
    for _, property in ipairs(self.owned_properties) do
        if property.group == "cab" then
            count = count + 1
        end
    end
    return count
end

function UMPlayer:utilityCount()
    local count = 0
    for _, property in ipairs(self.owned_properties) do
        if property.group == "utility" then
            count = count + 1
        end
    end
    return count
end
