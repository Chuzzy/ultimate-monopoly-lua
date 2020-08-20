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
    local function createGoPrototype(track)
        local name = names.go
        track[name] = function(space, player, params)
            print("Landed on go.")
        end
    end

    ---@param track table
    ---@param name string
    local function createPropertyPrototype(track, name)
        track[name] = function(space, player, params)
            print("Property function: " .. space)
        end
    end

    ---@param track table
    ---@param name string
    ---@param is_inner boolean
    local function createTransitStationPrototype(track, name, is_inner)
        local suffix = is_inner and " Inner" or " Outer"
        track[name .. suffix] = function(space, player, params)
            print("Here's your travel voucher, " .. player.name)
        end
    end

    ---@param track table
    ---@param name string
    local function createCabCompanyPrototype(track, name)
        track[name] = function(space, player, params)
            print("Taxi!")
        end
    end

    local function createIncomeTaxPrototype(track)
        local name = names.income
        track[name] = function (space, player, params)
            print("Taxes due.")
        end
    end

    local function createLuxuryTaxPrototype(track)
        local name = names.luxury
        track[name] = function(space, player, params)
            print("Good ol' Uncle Sam.")
        end
    end

    ---@param track table
    local function createChestPrototype(track)
        local name = names.chest .. getChestId()
        track[name] = function(space, player, params)
            print("Community Chest says...")
        end
    end

    ---@param track table
    local function createChancePrototype(track)
        local name = names.chance .. getChanceId()
        track[name] = function(space, player, params)
            print("Feeling lucky?")
        end
    end

    local function createBusTicketPrototype(track)
        local name = names.bus .. getTicketId()
        track[name] = function(space, player, params)
            print("Bus ticket.")
        end
    end

    ---@param track table
    local function createJustVisitingPrototype(track)
        local name = names.visit
        track[name] = function(space, player, params)
            print("Just Visiting")
        end
    end

    ---@param track table
    local function createFreeParkingPrototype(track)
        local name = names.parking
        track[name] = function(space, player, params)
            print("Free Parking. Beep beep.")
        end
    end

    ---@param track table
    local function createGoToJailPrototype(track)
        local name = names.jail
        track[name] = function(space, player, params)
            print("GO TO JAIL")
        end
    end

    local mid_track = Ordered()
    -- Bottom side
    createGoPrototype(mid_track)
    createPropertyPrototype(mid_track, names.medit)
    createChestPrototype(mid_track)
    createPropertyPrototype(mid_track, names.baltic)
    createIncomeTaxPrototype(mid_track)
    createTransitStationPrototype(mid_track, names.reading, true)
    createPropertyPrototype(mid_track, names.oriental)
    createChancePrototype(mid_track)
    createPropertyPrototype(mid_track, names.vermont)
    createPropertyPrototype(mid_track, names.connecticut)

    -- Left side
    createJustVisitingPrototype(mid_track)
    createPropertyPrototype(mid_track, names.charles)
    createPropertyPrototype(mid_track, names.elec)
    createPropertyPrototype(mid_track, names.states)
    createPropertyPrototype(mid_track, names.virginia)
    createTransitStationPrototype(mid_track, names.pennsylrr, false)
    createPropertyPrototype(mid_track, names.charles)
    createChestPrototype(mid_track)
    createPropertyPrototype(mid_track, names.tennessee)
    createPropertyPrototype(mid_track, names.newyork)

    -- Top side
    createFreeParkingPrototype(mid_track)
    createPropertyPrototype(mid_track, names.kentucky)
    createChancePrototype(mid_track)
    createPropertyPrototype(mid_track, names.indiana)
    createPropertyPrototype(mid_track, names.illinois)
    createTransitStationPrototype(mid_track, names.bno, true)
    createPropertyPrototype(mid_track, names.atlantic)
    createPropertyPrototype(mid_track, names.vermont)
    createPropertyPrototype(mid_track, names.water)
    createPropertyPrototype(mid_track, names.marvin)

    -- Right side
    createGoToJailPrototype(mid_track)
    createPropertyPrototype(mid_track, names.pacific)
    createPropertyPrototype(mid_track, names.carolina)
    createChestPrototype(mid_track)
    createPropertyPrototype(mid_track, names.pennsyl)
    createTransitStationPrototype(mid_track, names.short, false)
    createChancePrototype(mid_track)
    createPropertyPrototype(mid_track, names.park)
    createLuxuryTaxPrototype(mid_track)
    createPropertyPrototype(mid_track, names.boardwalk)

    for key in pairs(mid_track) do print(key) end

    return self
end

Board.new()
