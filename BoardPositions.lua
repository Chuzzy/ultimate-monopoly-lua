require("Names")

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
    [Names.ventnor] = {3.03, 2.01, 8.35},
    [Names.water] = {4.55, 2.01, 8.35},
    [Names.marvin] = {6.07, 2.01, 8.35},

    -- Right Middle Track
    [Names.malloy] = {8.33, 2.47, 8.33},
    [Names.pacific] = {8.33, 2.01, 6.08},
    [Names.carolina] = {8.33, 2.01, 4.56},
    [Names.chest .. " 3"] = {8.33, 2.01, 3.04},
    [Names.pennsyl] = {8.33, 2.01, 1.53},
    [Names.short .. " Outer"] = {8.33, 2.01, 0.00},
    [Names.chance .. " 3"] = {8.33, 2.01, -1.53},
    [Names.park] = {8.33, 2.01, -3.03},
    [Names.luxury] = {8.33, 2.01, -4.55},
    [Names.boardwalk] = {8.33, 2.01, -6.07},

    -- Bottom Outer Track
    [Names.stock] = {11.58, 2.47, -11.58},
    [Names.lake] = {9.26, 2.01, -11.58},
    [Names.chest .. " 4"] = {7.72, 2.01, -11.58},
    [Names.nicollet] = {6.17, 2.01, -11.58},
    [Names.hennepin] = {4.63, 2.01, -11.58},
    [Names.bus .. " 1"] = {3.09, 2.01, -11.58},
    [Names.checker] = {1.55, 2.01, -11.58},
    [Names.reading .. " Outer"] = {0.00, 2.01, -11.58},
    [Names.esplanade] = {-1.55, 2.01, -11.58},
    [Names.canal] = {-3.09, 2.01, -11.58},
    [Names.chance .. " 4"] = {-4.63, 2.01, -11.58},
    [Names.cable] = {-6.18, 2.01, -11.58},
    [Names.magazine] = {-7.72, 2.01, -11.58},
    [Names.bourbon] = {-9.26, 2.01, -11.58},

    -- Left Outer Track
    [Names.holland .. " Outer"] = {-11.58, 2.47, -11.58},
    [Names.auction] = {-11.58, 2.01, -9.26},
    [Names.katy] = {-11.58, 2.01, -7.72},
    [Names.westheimer] = {-11.58, 2.01, -6.17},
    [Names.isp] = {-11.58, 2.01, -4.63},
    [Names.kirby] = {-11.58, 2.01, -3.09},
    [Names.cullen] = {-11.58, 2.01, -1.58},
    [Names.chance .. " 5"] = {-11.58, 2.01, 0.00},
    [Names.black] = {-11.58, 2.01, 1.58},
    [Names.dekalb] = {-11.58, 2.01, 3.09},
    [Names.chest .. " 5"] = {-11.58, 2.01, 4.63},
    [Names.andrew] = {-11.58, 2.01, 6.17},
    [Names.decatur] = {-11.58, 2.01, 7.72},
    [Names.peach] = {-11.58, 2.01, 9.26},

    -- Top Outer Track
    [Names.payday] = {-11.58, 2.47, 11.58},
    [Names.randolph] = {-9.26, 2.01, 11.58},
    [Names.chance .. " 6"] = {-7.72, 2.01, 11.58},
    [Names.shore] = {-6.17, 2.01, 11.58},
    [Names.wacker] = {-4.63, 2.01, 11.58},
    [Names.michigan] = {-3.09, 2.01, 11.58},
    [Names.yellow] = {-1.55, 2.01, 11.58},
    [Names.bno .. " Outer"] = {0.00, 2.01, 11.58},
    [Names.chest .. " 6"] = {1.55, 2.01, 11.58},
    [Names.south] = {3.09, 2.01, 11.58},
    [Names.west] = {4.63, 2.01, 11.58},
    [Names.trash] = {6.18, 2.01, 11.58},
    [Names.north] = {7.72, 2.01, 11.58},
    [Names.square] = {9.26, 2.01, 11.58},

    -- Right Outer Track
    [Names.subway] = {11.58, 2.47, 11.58},
    [Names.southst] = {11.58, 2.01, 9.26},
    [Names.broad] = {11.58, 2.01, 7.72},
    [Names.walnut] = {11.58, 2.01, 6.17},
    [Names.chest .. " 7"] = {11.58, 2.01, 4.63},
    [Names.market] = {11.58, 2.01, 3.09},
    [Names.bus .. " 2"] = {11.58, 2.01, 1.58},
    [Names.sewer] = {11.58, 2.01, 0.00},
    [Names.ute] = {11.58, 2.01, -1.58},
    [Names.birthday] = {11.58, 2.01, -3.09},
    [Names.mulholland] = {11.58, 2.01, -4.63},
    [Names.ventura] = {11.58, 2.01, -6.17},
    [Names.chance .. " 7"] = {11.58, 2.01, -7.72},
    [Names.rodeo] = {11.58, 2.01, -9.26},

    -- Bottom Inner Track
    [Names.squeeze] = {5.17, 2.47, -5.17},
    [Names.embarca] = {2.97, 2.01, -5.17},
    [Names.fisher] = {1.50, 2.01, -5.17},
    [Names.tel] = {0.00, 2.01, -5.17},
    [Names.chest .. " 8"] = {-1.51, 2.01, -5.17},
    [Names.beacon] = {-2.97, 2.01, -5.17},

    -- Left Inner Track
    [Names.bonus] = {-5.17, 2.47, -5.17},
    [Names.boylston] = {-5.17, 2.01, -2.96},
    [Names.newbury] = {-5.17, 2.01, -1.49},
    [Names.pennsylrr .. " Inner"] = {-5.17, 2.01, 0.00},
    [Names.fifth] = {-5.17, 2.01, 1.49},
    [Names.madison] = {-5.17, 2.01, 2.96},

    -- Top Inner Track
    [Names.roll3] = {-5.17, 2.47, 5.17},
    [Names.wall] = {-2.95, 2.01, 5.17},
    [Names.refund] = {-1.49, 2.01, 5.18},
    [Names.gas] = {0.00, 2.01, 5.17},
    [Names.chance .. " 8"] = {1.50, 2.01, 5.17},
    [Names.florida] = {2.97, 2.01, 5.17},

    -- Right Inner Track
    [Names.holland .. " Inner"] = {5.17, 2.47, 5.17},
    [Names.miami] = {5.17, 2.01, 2.96},
    [Names.biscayne] = {5.17, 2.01, 1.49},
    [Names.short .. " Inner"] = {5.17, 2.01, 0.00},
    [Names.reverse] = {5.17, 2.01, -1.49},
    [Names.lombard] = {5.17, 2.01, -2.96}
}

local direction = {}

BoardPositions = {main = main_pos}
