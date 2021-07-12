require("Names")

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
        name = Names.go,
        action = function(space, game, player)
            --TODO: Handle landing on go
        end
    })
end

local function createBonusPrototype(track)
    table.insert(track, {
        name = Names.bonus,
        action = function(space, game, player)
            game:payFromBank(player, 300, "for landing on Bonus")
        end
    })
end

local function createSqueezePlayPrototype(track)
    table.insert(track, {
        name = Names.squeeze,
        action = function(space, game, player) print("Lucky you!") end
    })
end

local function createRollThreePrototype(track)
    table.insert(track, {
        name = Names.roll3,
        action = function(space, game, player)
            print("Roll the dice to win some cash.")
        end
    })
end

local function createTaxRefundPrototype(track)
    table.insert(track, {
        name = Names.refund,
        action = function(space, game, player) print("Here you go!") end
    })
end

local function createReverseDirectionPrototype(track)
    table.insert(track, {
        name = Names.reverse,
        action = function(space, game, player)
            print("Moving backwards.")
        end
    })
end

local function createPayDayPrototype(track)
    table.insert(track, {
        name = Names.payday,
        action = function(space, game, player)
            game:payFromBank(player, 400, "for landing on Pay Day")
        end
    })
end

local function createStockExchangePrototype(track)
    table.insert(track, {
        name = Names.stock,
        action = function(space, game, player)
            print("Buy! Buy! Sell! Sell!")
        end
    })
end

local function createAuctionPrototype(track)
    table.insert(track, {
        name = Names.auction,
        action = function(space, game, player)
            print("Sold to the highest bidder.")
        end
    })
end

local function createBirthdayPrototype(track)
    table.insert(track, {
        name = Names.birthday,
        action = function(space, game, player) print("Happy birthday!") end
    })
end

local function createSubwayPrototype(track)
    table.insert(track, {
        name = Names.subway,
        action = function(space, game, player)
            print("Going round the underground.")
        end
    })
end

local function createHollandTunnelPrototype(track, is_inner)
    local suffix = is_inner and " Inner" or " Outer"
    table.insert(track, {
        name = Names.holland .. suffix,
        action = function(space, game, player)
            if is_inner then
                game:moveDirectlyTo(game.board.spaces[Names.holland .. " Outer"])
                broadcastToAll(player:getName() .. " took the Holland Tunnel to the Outer track", player.color)
            else
                game:moveDirectlyTo(game.board.spaces[Names.holland .. " Inner"])
                broadcastToAll(player:getName() .. " took the Holland Tunnel to the Inner track", player.color)
            end
        end
    })
end

---@param space Space
---@param game UMGame
---@param player UMPlayer
local function propertyAction(space, game, player)
    local property = Utils.spaceToProperty(space, game)
    if not property.owner then
        broadcastToColor(property.name .. " is for sale for $" .. property.cost .. ". You want it?", player.color, player.color)
        game:showPropertyInfo(property, game:whoseTurn(), true)
        game.state = GameState.PROPERTY_SALE
    else
        local rent_owed = property:rent(game.dice_total)
        if rent_owed > 0 then
            game:createDebt(player, property.owner, rent_owed, "rent for landing on " .. property.name)
        end
    end
end

---@param track table
---@param name string
local function createPropertyPrototype(track, name)
    table.insert(track, {name = name, action = propertyAction})
end

local function transitStationAction(space, game, player)
    print("Here's your travel voucher, " .. player:getName())
    propertyAction(space, game, player)
end

---@param track table
---@param name string
---@param is_inner boolean
local function createTransitStationPrototype(track, name, is_inner)
    local suffix = is_inner and " Inner" or " Outer"
    table.insert(track, {
        name = name .. suffix,
        transit_type = is_inner and 1 or 0,
        action = transitStationAction
    })
end

local function cabCompanyAction(space, player, params)
    print("Taxi!") -- Putting this here so formatter doesn't screw it up
end

---@param track table
---@param name string
local function createCabCompanyPrototype(track, name)
    table.insert(track, {
        name = name,
        action = cabCompanyAction
    })
end

local function createIncomeTaxPrototype(track)
    table.insert(track, {
        name = Names.income,
        action = function(space, game, player)
            --TODO: Offer the choice of 10%
            game:createDebt(player, nil, 200, "in Income Tax")
        end
    })
end

local function createLuxuryTaxPrototype(track)
    table.insert(track, {
        name = Names.luxury,
        action = function(space, game, player)
            game:createDebt(player, nil, 75, "in Luxury Tax")
        end
    })
end

local function chestAction(space, player, params)
    print("Community Chest says...")
end

---@param track table
local function createChestPrototype(track)
    local chest_id = getChestId()
    table.insert(track, {
        name = Names.chest .. chest_id,
        action = chestAction
    })
end

local function chanceAction(space, player, params)
    print("Feeling lucky?")
end

---@param track table
local function createChancePrototype(track)
    local chance_id = getChanceId()
    table.insert(track, {
        name = Names.chance .. chance_id,
        action = chanceAction
    })
end

local function busTicketAction(space, player, params)
    print("Bus ticket.")
end

local function createBusTicketPrototype(track)
    table.insert(track, {
        name = Names.bus .. getTicketId(),
        action = busTicketAction
    })
end

---@param track table
local function createJustVisitingPrototype(track)
    table.insert(track, {
        name = Names.visit,
        action = function(space, game, player) print("Just Visiting") end
    })
end

---@param track table
local function createFreeParkingPrototype(track)
    table.insert(track, {
        name = Names.parking,
        action = function(space, game, player)
            print("Free Parking. Beep beep.")
        end
    })
end

---@param track table
local function createGoToJailPrototype(track)
    table.insert(track, {
        name = Names.malloy,
        action = function(space, game, player) print("GO TO JAIL") end
    })
end

local mid_track = {}
-- Bottom side
createGoPrototype(mid_track)
createPropertyPrototype(mid_track, Names.medit)
createChestPrototype(mid_track)
createPropertyPrototype(mid_track, Names.baltic)
createIncomeTaxPrototype(mid_track)
createTransitStationPrototype(mid_track, Names.reading, true)
createPropertyPrototype(mid_track, Names.oriental)
createChancePrototype(mid_track)
createPropertyPrototype(mid_track, Names.vermont)
createPropertyPrototype(mid_track, Names.connecticut)

-- Left side
createJustVisitingPrototype(mid_track)
createPropertyPrototype(mid_track, Names.charles)
createPropertyPrototype(mid_track, Names.elec)
createPropertyPrototype(mid_track, Names.states)
createPropertyPrototype(mid_track, Names.virginia)
createTransitStationPrototype(mid_track, Names.pennsylrr, false)
createPropertyPrototype(mid_track, Names.james)
createChestPrototype(mid_track)
createPropertyPrototype(mid_track, Names.tennessee)
createPropertyPrototype(mid_track, Names.newyork)

-- Top side
createFreeParkingPrototype(mid_track)
createPropertyPrototype(mid_track, Names.kentucky)
createChancePrototype(mid_track)
createPropertyPrototype(mid_track, Names.indiana)
createPropertyPrototype(mid_track, Names.illinois)
createTransitStationPrototype(mid_track, Names.bno, true)
createPropertyPrototype(mid_track, Names.atlantic)
createPropertyPrototype(mid_track, Names.ventnor)
createPropertyPrototype(mid_track, Names.water)
createPropertyPrototype(mid_track, Names.marvin)

-- Right side
createGoToJailPrototype(mid_track)
createPropertyPrototype(mid_track, Names.pacific)
createPropertyPrototype(mid_track, Names.carolina)
createChestPrototype(mid_track)
createPropertyPrototype(mid_track, Names.pennsyl)
createTransitStationPrototype(mid_track, Names.short, false)
createChancePrototype(mid_track)
createPropertyPrototype(mid_track, Names.park)
createLuxuryTaxPrototype(mid_track)
createPropertyPrototype(mid_track, Names.boardwalk)

local outer_track = {}
-- Bottom side
createStockExchangePrototype(outer_track)
createPropertyPrototype(outer_track, Names.lake)
createChestPrototype(outer_track)
createPropertyPrototype(outer_track, Names.nicollet)
createPropertyPrototype(outer_track, Names.hennepin)
createBusTicketPrototype(outer_track)
createCabCompanyPrototype(outer_track, Names.checker)
createTransitStationPrototype(outer_track, Names.reading, false)
createPropertyPrototype(outer_track, Names.esplanade)
createPropertyPrototype(outer_track, Names.canal)
createChancePrototype(outer_track)
createPropertyPrototype(outer_track, Names.cable)
createPropertyPrototype(outer_track, Names.magazine)
createPropertyPrototype(outer_track, Names.bourbon)

-- Left side
createHollandTunnelPrototype(outer_track, false)
createAuctionPrototype(outer_track)
createPropertyPrototype(outer_track, Names.katy)
createPropertyPrototype(outer_track, Names.westheimer)
createPropertyPrototype(outer_track, Names.isp)
createPropertyPrototype(outer_track, Names.kirby)
createPropertyPrototype(outer_track, Names.cullen)
createChancePrototype(outer_track)
createCabCompanyPrototype(outer_track, Names.black)
createPropertyPrototype(outer_track, Names.dekalb)
createChestPrototype(outer_track)
createPropertyPrototype(outer_track, Names.andrew)
createPropertyPrototype(outer_track, Names.decatur)
createPropertyPrototype(outer_track, Names.peach)

-- Top side
createPayDayPrototype(outer_track)
createPropertyPrototype(outer_track, Names.randolph)
createChancePrototype(outer_track)
createPropertyPrototype(outer_track, Names.shore)
createPropertyPrototype(outer_track, Names.wacker)
createPropertyPrototype(outer_track, Names.michigan)
createCabCompanyPrototype(outer_track, Names.yellow)
createTransitStationPrototype(outer_track, Names.bno, false)
createChestPrototype(outer_track)
createPropertyPrototype(outer_track, Names.south)
createPropertyPrototype(outer_track, Names.west)
createPropertyPrototype(outer_track, Names.trash)
createPropertyPrototype(outer_track, Names.north)
createPropertyPrototype(outer_track, Names.square)

-- Right side
createSubwayPrototype(outer_track)
createPropertyPrototype(outer_track, Names.southst)
createPropertyPrototype(outer_track, Names.broad)
createPropertyPrototype(outer_track, Names.walnut)
createChestPrototype(outer_track)
createPropertyPrototype(outer_track, Names.market)
createBusTicketPrototype(outer_track)
createPropertyPrototype(outer_track, Names.sewer)
createCabCompanyPrototype(outer_track, Names.ute)
createBirthdayPrototype(outer_track)
createPropertyPrototype(outer_track, Names.mulholland)
createPropertyPrototype(outer_track, Names.ventura)
createChancePrototype(outer_track)
createPropertyPrototype(outer_track, Names.rodeo)

local inner_track = {}
-- Bottom side
createSqueezePlayPrototype(inner_track)
createPropertyPrototype(inner_track, Names.embarca)
createPropertyPrototype(inner_track, Names.fisher)
createPropertyPrototype(inner_track, Names.tel)
createChestPrototype(inner_track)
createPropertyPrototype(inner_track, Names.beacon)

-- Left side
createBonusPrototype(inner_track)
createPropertyPrototype(inner_track, Names.boylston)
createPropertyPrototype(inner_track, Names.newbury)
createTransitStationPrototype(inner_track, Names.pennsylrr, true)
createPropertyPrototype(inner_track, Names.fifth)
createPropertyPrototype(inner_track, Names.madison)

-- Top side
createRollThreePrototype(inner_track)
createPropertyPrototype(inner_track, Names.wall)
createTaxRefundPrototype(inner_track)
createPropertyPrototype(inner_track, Names.gas)
createChancePrototype(inner_track)
createPropertyPrototype(inner_track, Names.florida)

-- Right side
createHollandTunnelPrototype(inner_track, true)
createPropertyPrototype(inner_track, Names.miami)
createPropertyPrototype(inner_track, Names.biscayne)
createTransitStationPrototype(inner_track, Names.short, true)
createReverseDirectionPrototype(inner_track)
createPropertyPrototype(inner_track, Names.lombard)

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

BoardPrototype = {
    middle = mid_track,
    outer = outer_track,
    inner = inner_track,
    outer_to_middle = outer_to_middle_mappings,
    middle_to_inner = middle_to_inner_mappings
}
