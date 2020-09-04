local names = require("Names")

local chance_space_count, chest_space_count, ticket_space_count = 0, 0, 0

local function getChanceId()
    chance_space_count = chance_space_count + 1
    return " " .. chance_space_count
end

local function getChestId()
    chest_space_count = chest_space_count + 1
    return " " .. chest_space_count
end

local function getTicketId()
    ticket_space_count = ticket_space_count + 1
    return " " .. ticket_space_count
end

---@param track table
local function createGoPrototype(track)
    table.insert(track, {
        name = names.go,
        action = function(space, player, params) print("Landed on go.") end
    })
end

local function createBonusPrototype(track)
    table.insert(track, {
        name = names.bonus,
        action = function(space, player, params) print("Dosh!") end
    })
end

local function createSqueezePlayPrototype(track)
    table.insert(track, {
        name = names.squeeze,
        action = function(space, player, params) print("Lucky you!") end
    })
end

local function createRollThreePrototype(track)
    table.insert(track, {
        name = names.roll3,
        action = function(space, player, params)
            print("Roll the dice to win some cash.")
        end
    })
end

local function createTaxRefundPrototype(track)
    table.insert(track, {
        name = names.refund,
        action = function(space, player, params) print("Here you go!") end
    })
end

local function createReverseDirectionPrototype(track)
    table.insert(track, {
        name = names.reverse,
        action = function(space, player, params)
            print("Moving backwards.")
        end
    })
end

local function createPayDayPrototype(track)
    table.insert(track, {
        name = names.payday,
        action = function(space, player, params) print("It's PAYDAY!") end
    })
end

local function createStockExchangePrototype(track)
    table.insert(track, {
        name = names.stock,
        action = function(space, player, params)
            print("Buy! Buy! Sell! Sell!")
        end
    })
end

local function createAuctionPrototype(track)
    table.insert(track, {
        name = names.auction,
        action = function(space, player, params)
            print("Sold to the highest bidder.")
        end
    })
end

local function createBirthdayPrototype(track)
    table.insert(track, {
        name = names.birthday,
        action = function(space, player, params) print("Happy birthday!") end
    })
end

local function createSubwayPrototype(track)
    table.insert(track, {
        name = names.subway,
        action = function(space, player, params)
            print("Going round the underground.")
        end
    })
end

local function createHollandTunnelPrototype(track, is_inner)
    local suffix = is_inner and " Inner" or " Outer"
    table.insert(track, {
        name = names.holland .. suffix,
        action = function(space, player, params) print("Holland!") end
    })
end

---@param track table
---@param name string
local function createPropertyPrototype(track, name)
    table.insert(track, {
        name = name,
        action = function(space, player, params)
            print("Property function: " .. space)
        end
    })
end

---@param track table
---@param name string
---@param is_inner boolean
local function createTransitStationPrototype(track, name, is_inner)
    local suffix = is_inner and " Inner" or " Outer"
    table.insert(track, {
        name = name .. suffix,
        action = function(space, player, params)
            print("Here's your travel voucher, " .. player.name)
        end
    })
end

---@param track table
---@param name string
local function createCabCompanyPrototype(track, name)
    table.insert(track, {
        name = name,
        action = function(space, player, params)
            print("Taxi!") -- Putting this here so formatter doesn't screw it up
        end
    })
end

local function createIncomeTaxPrototype(track)
    table.insert(track, {
        name = names.income,
        action = function(space, player, params) print("Taxes due.") end
    })
end

local function createLuxuryTaxPrototype(track)
    table.insert(track, {
        name = names.luxury,
        action = function(space, player, params)
            print("Good ol' Uncle Sam.")
        end
    })
end

---@param track table
local function createChestPrototype(track)
    local chest_id = getChestId()
    table.insert(track, {
        name = names.chest .. chest_id,
        action = function(space, player, params)
            print("Community Chest says...")
        end
    })
end

---@param track table
local function createChancePrototype(track)
    local chance_id = getChanceId()
    table.insert(track, {
        name = names.chance .. chance_id,
        action = function(space, player, params) print("Feeling lucky?") end
    })
end

local function createBusTicketPrototype(track)
    table.insert(track, {
        name = names.bus .. getTicketId(),
        action = function(space, player, params) print("Bus ticket.") end
    })
end

---@param track table
local function createJustVisitingPrototype(track)
    table.insert(track, {
        name = names.visit,
        action = function(space, player, params) print("Just Visiting") end
    })
end

---@param track table
local function createFreeParkingPrototype(track)
    table.insert(track, {
        name = names.parking,
        action = function(space, player, params)
            print("Free Parking. Beep beep.")
        end
    })
end

---@param track table
local function createGoToJailPrototype(track)
    table.insert(track, {
        name = names.malloy,
        action = function(space, player, params) print("GO TO JAIL") end
    })
end

local mid_track = {}
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

local outer_track = {}
-- Bottom side
createStockExchangePrototype(outer_track)
createPropertyPrototype(outer_track, names.lake)
createChestPrototype(outer_track)
createPropertyPrototype(outer_track, names.nicollet)
createPropertyPrototype(outer_track, names.hennepin)
createBusTicketPrototype(outer_track)
createCabCompanyPrototype(outer_track, names.checker)
createTransitStationPrototype(outer_track, names.reading, false)
createPropertyPrototype(outer_track, names.esplanade)
createPropertyPrototype(outer_track, names.canal)
createChancePrototype(outer_track)
createPropertyPrototype(outer_track, names.cable)
createPropertyPrototype(outer_track, names.magazine)
createPropertyPrototype(outer_track, names.bourbon)

-- Left side
createHollandTunnelPrototype(outer_track, false)
createAuctionPrototype(outer_track)
createPropertyPrototype(outer_track, names.katy)
createPropertyPrototype(outer_track, names.westheimer)
createPropertyPrototype(outer_track, names.isp)
createPropertyPrototype(outer_track, names.kirby)
createPropertyPrototype(outer_track, names.cullen)
createChancePrototype(outer_track)
createCabCompanyPrototype(outer_track, names.black)
createPropertyPrototype(outer_track, names.dekalb)
createChestPrototype(outer_track)
createPropertyPrototype(outer_track, names.andrew)
createPropertyPrototype(outer_track, names.decatur)
createPropertyPrototype(outer_track, names.peach)

-- Top side
createPayDayPrototype(outer_track)
createPropertyPrototype(outer_track, names.randolph)
createChancePrototype(outer_track)
createPropertyPrototype(outer_track, names.shore)
createPropertyPrototype(outer_track, names.wacker)
createPropertyPrototype(outer_track, names.michigan)
createCabCompanyPrototype(outer_track, names.yellow)
createTransitStationPrototype(outer_track, names.bno, false)
createChestPrototype(outer_track)
createPropertyPrototype(outer_track, names.south)
createPropertyPrototype(outer_track, names.west)
createPropertyPrototype(outer_track, names.trash)
createPropertyPrototype(outer_track, names.north)
createPropertyPrototype(outer_track, names.square)

-- Right side
createSubwayPrototype(outer_track, names.subway)
createPropertyPrototype(outer_track, names.southst)
createPropertyPrototype(outer_track, names.broad)
createPropertyPrototype(outer_track, names.walnut)
createChestPrototype(outer_track)
createPropertyPrototype(outer_track, names.market)
createBusTicketPrototype(outer_track)
createPropertyPrototype(outer_track, names.sewer)
createCabCompanyPrototype(outer_track, names.ute)
createBirthdayPrototype(outer_track)
createPropertyPrototype(outer_track, names.mulholland)
createPropertyPrototype(outer_track, names.ventura)
createChancePrototype(outer_track)
createPropertyPrototype(outer_track, names.rodeo)

local inner_track = {}
-- Bottom side
createSqueezePlayPrototype(inner_track)
createPropertyPrototype(inner_track, names.embarca)
createPropertyPrototype(inner_track, names.fisher)
createPropertyPrototype(inner_track, names.tel)
createChestPrototype(inner_track)
createPropertyPrototype(inner_track, names.beacon)

-- Left side
createBonusPrototype(inner_track)
createPropertyPrototype(inner_track, names.boylston)
createPropertyPrototype(inner_track, names.newbury)
createTransitStationPrototype(inner_track, names.pennsylrr, true)
createPropertyPrototype(inner_track, names.fifth)
createPropertyPrototype(inner_track, names.madison)

-- Top side
createRollThreePrototype(inner_track)
createPropertyPrototype(inner_track, names.wall)
createTaxRefundPrototype(inner_track)
createPropertyPrototype(inner_track, names.gas)
createChancePrototype(inner_track)
createPropertyPrototype(inner_track, names.florida)

-- Right side
createHollandTunnelPrototype(inner_track, true)
createPropertyPrototype(inner_track, names.miami)
createPropertyPrototype(inner_track, names.biscayne)
createTransitStationPrototype(inner_track, names.short, true)
createReverseDirectionPrototype(inner_track)
createPropertyPrototype(inner_track, names.lombard)

---Maps outer track spaces to middle track spaces by index.
local outer_to_middle_mappings = {
    01, 01, 01, 02, 03, 04, 05, 06, 07, 08, 09, 10, 11, 11, -- Bottom side
    11, 11, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 21, -- Left side
    21, 21, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 31, -- Top side
    31, 31, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 01, 01 -- Right side
}

-- Maps middle track spaces to inner track spaces by index.
local middle_to_inner_mappings = {
    01, 01, 01, 02, 03, 04, 05, 06, 07, 07, -- Bottom side
    07, 07, 07, 08, 09, 10, 11, 12, 13, 13, -- Left side
    13, 13, 13, 14, 15, 16, 17, 18, 19, 19, -- Top side
    19, 19, 19, 20, 21, 22, 23, 24, 01, 01 -- Right side
}

return {
    middle = mid_track,
    outer = outer_track,
    inner = inner_track,
    outer_to_middle = outer_to_middle_mappings,
    middle_to_inner = middle_to_inner_mappings
}
