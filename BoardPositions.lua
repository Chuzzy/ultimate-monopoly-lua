Names = require("Names")

local main_pos = {
    -- Bottom Middle Track
    [Names.go] = {8.33, 2.47, -8.33},
    [Names.medit] = {6.07, 2.01, -8.35},
    [Names.chest .. " 1"] = {4.55, 2.01, -8.35},
    [Names.baltic] = {3.03, 2.01, -8.35},
    [Names.income] = {1.53, 2.01, -8.35},
    [Names.reading .. " Inner"] = {0.00, 2.01, -8.35},
    [Names.oriental] = {-1.54, 2.01, -8.34},
    [Names.chance .. " 1"] = {-3.04, 2.01, -8.35},
    [Names.vermont] = {-4.56, 2.01, -8.35},
    [Names.connecticut] = {-6.08, 2.01, -8.35},

    -- Left Middle Track
    [Names.visit] = {-8.33, 2.47, -8.33},
    [Names.charles] = {-8.33, 2.01, -6.07},
    [Names.elec] = {-8.33, 2.01, -4.55},
    [Names.states] = {-8.33, 2.01, -3.03},
    [Names.virginia] = {-8.33, 2.01, -1.53},
    [Names.pennsylrr .. " Outer"] = {-8.33, 2.01, 0.00},
    [Names.james] = {-8.33, 2.01, 1.53},
    [Names.chest .. " 2"] = {-8.33, 2.01, 3.04},
    [Names.tennessee] = {-8.33, 2.01, 4.56},
    [Names.newyork] = {-8.33, 2.01, 6.08},

    -- Top Middle Track
    [Names.parking] = {-8.33, 2.47, 8.33},
    [Names.kentucky] = {-6.08, 2.01, 8.35},
    [Names.chance .. " 2"] = {-4.56, 2.01, 8.35},
    [Names.indiana] = {-3.04, 2.01, 8.35},
    [Names.illinois] = {-1.54, 2.01, 8.35},
    [Names.bno .. " Inner"] = {0.00, 2.01, 8.35},
    [Names.atlantic] = {1.53, 2.01, 8.35},
    [Names.ventura] = {3.03, 2.01, 8.35},
    [Names.water] = {4.55, 2.01, 8.35},
    [Names.marvin] = {6.07, 2.01, 8.35},

    -- Right Middle Track
    [Names.malloy] = {8.33, 2.47, 8.33},
    [Names.pacific] = {8.33, 2.01, 6.08},
    [Names.carolina] = {8.33, 2.01, 4.56},
    [Names.chest .. " 3"] = {8.33, 2.01, 3.04},
    [Names.pennsyl] = {8.33, 2.01, 1.53},
    [Names.short] = {8.33, 2.01, 0.00},
    [Names.chance .. " 3"] = {8.33, 2.01, -1.53},
    [Names.park] = {8.33, 2.01, -3.03},
    [Names.luxury] = {8.33, 2.01, -4.55},
    [Names.boardwalk] = {8.33, 2.01, -6.07},

    -- Bottom Outer Track
    [Names.stock] = {11.58, 2.47, -11.58},

    -- Left Outer Track
    [Names.holland .. " Outer"] = {-11.58, 2.47, -11.58},

    -- Top Outer Track
    [Names.payday] = {-11.58, 2.47, 11.58},

    -- Right Outer Track
    [Names.subway] = {11.58, 2.47, 11.58},

    -- Bottom Inner Track
    [Names.squeeze] = {5.17, 2.47, -5.17},
    [Names.embarca] = {2.97, 2.01, -5.17},
    [Names.fisher] = {1.50, 2.01, -5.17},
    [Names.tel] = {0.00, 2.01, -5.17},
    [Names.chest] = {-1.51, 2.01, -5.17}, -- TODO: which chest?
    [Names.beacon] = {-2.97, 2.01, -5.17},

    -- Left Inner Track
    [Names.bonus] = {-5.17, 2.47, -5.17},

    -- Top Inner Track
    [Names.roll3] = {-5.17, 2.47, 5.17},
    [Names.wall] = {-2.95, 2.01, 5.17},
    [Names.refund] = {-1.49, 2.01, 5.18},
    [Names.gas] = {0.00, 2.01, 5.17},
    [Names.chance] = {1.50, 2.01, 5.17}, -- TODO: which chance?
    [Names.florida] = {2.97, 2.01, 5.17},


    -- Right Inner Track
    [Names.holland .. " Inner"] = {5.17, 2.47, 5.17}
}

local direction = {
    
}

return {
    main = main_pos
}
