--- The Ultimate Monopoly game board.
---@class Board
---@field game Game
---@field spaces table
local Board = {}
Board.__index = Board

Space = require("Space")
local names = require("Names")
Ordered = require("Ordered")

function Board.new()
    local self = setmetatable({}, Board)
    -- Initialise the spaces. All 111 of them.
    self.spaces = {}

    --- Creates a forward link between two spaces.
    ---@param space_name string
    ---@param after_name string
    ---@param space_action function
    ---@param after_action function
    local function linkConsecutiveSpaces(space_name, after_name, space_action,
                                         after_action)
        -- Create a space if space_name doesn't exist yet
        if not self.spaces[space_name] then
            self.spaces[space_name] = Space.new(space_name, space_action)
        end
        -- Create another space if after_name doesn't exist yet
        if not self.spaces[after_name] then
            self.spaces[after_name] = Space.new(after_name, after_action)
        end
        -- Make the "after" space point backwards to the current space
        self.spaces[after_name].prev = self.spaces[space_name]
        -- Make the current space point forward to the "after" space
        self.spaces[space_name].next = self.spaces[after_name]
    end

    local function getChanceId()
        ChanceSpaceCount = 0
        ChanceSpaceCount = ChanceSpaceCount + 1
        return " " .. ChanceSpaceCount
    end

    local function getChestId()
        CommunityChestSpaceCount = 0
        CommunityChestSpaceCount = CommunityChestSpaceCount + 1
        return " " .. CommunityChestSpaceCount
    end

    local function getTicketId()
        BusTicketSpaceCount = 0
        BusTicketSpaceCount = BusTicketSpaceCount + 1
        return " " .. BusTicketSpaceCount
    end

    ---@param track table
    local function createGoSpace(track)
        local name = names.go
        track[name] = function(space, player, params)
            print("Landed on go.")
        end
    end

    ---@param track table
    ---@param name string
    local function createPropertySpace(track, name)
        track[name] = function(space, player, params)
            print("Property function: " .. space)
        end
    end

    ---@param track table
    ---@param name string
    ---@param is_inner boolean
    local function createTransitStationSpace(track, name, is_inner)
        local prefix = is_inner and " Inner" or " Outer"
        track[name .. prefix] = function(space, player, params)
            print("Here's your travel voucher, " .. player.name)
        end
    end

    ---@param track table
    ---@param name string
    local function createCabCompanySpace(track, name)
        track[name] = function(space, player, params)
            print("Taxi!")
        end
    end

    local function createIncomeTaxSpace(track)
        local name = names.income
        track[name] = function (space, player, params)
            print("Taxes due.")
        end
    end

    ---@param track table
    local function createChestSpace(track)
        local name = names.chest .. getChestId()
        track[name] = function(space, player, params)
            print("Community Chest says...")
        end
    end

    ---@param track table
    local function createChanceSpace(track)
        local name = names.chance .. getChanceId()
        track[name] = function(space, player, params)
            print("Feeling lucky?")
        end
    end

    local function createBusTicketSpace(track)
        local name = names.bus .. getTicketId()
        track[name] = function(space, player, params)
            print("Bus ticket.")
        end
    end

    ---@param track table
    local function createJustVisitingSpace(track)
        local name = names.visit
        track[name] = function(space, player, params)
            print("Just Visiting")
        end
    end

    ---@param track table
    local function createFreeParkingSpace(track)
        local name = names.parking
        track[name] = function(space, player, params)
            print("Free Parking. Beep beep.")
        end
    end

    ---@param track table
    local function createGoToJailSpace(track)
        local name = names.jail
        track[name] = function(space, player, params)
            print("GO TO JAIL")
        end
    end

    local mid_track = Ordered()

    for key in pairs(mid_track) do print(key) end

    return self
end

Board.new()
