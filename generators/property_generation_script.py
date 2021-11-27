"""Generates the Lua file which initialises all the properties."""
from csv import DictReader

with open("Properties.lua", "w") as lua_file:
    lua_file.write("function Property.generateUMProperties()\n")
    lua_file.write("    return {\n")
    with open("generators/PropertyCards.csv") as property_cards:
        reader = DictReader(property_cards)
        for property in reader:
            lua_file.write(f"        [\"{property['name']}\"] = Property.new(\"{property['name']}\", {property['price']}, \"{property['color']}\", {{{property['baserent']}, {property['onehouserent']}, {property['twohouserent']}, {property['threehouserent']}, {property['fourhouserent']}, {property['hotelrent']}, {property['skyscraperrent']}}}, {property['housecost']}, 6),\n")
    
    lua_file.write("        -- Railroads\n")
    for railroad in ["Reading Railroad", "Pennsylvania Railroad", "B&O Railroad", "Short Line"]:
        lua_file.write(f"        [\"{railroad}\"] = Property.new(\"{railroad}\", 200, \"rail\", {{25, 50, 100, 200}}, 100, 1),\n")
    
    lua_file.write("        -- Cab Companies\n")
    for cabco in ["Checker Cab Company", "Black & White Cab Company", "Yellow Cab Company", "Ute Cab Company"]:
        lua_file.write(f"        [\"{cabco}\"] = Property.new(\"{cabco}\", 300, \"cab\", {{30, 60, 120, 240}}, 150, 1),\n")

    
    lua_file.write("        -- Utilities\n")
    for utility in ["Electric Company", "Water Works", "Cable Company", "Internet Service Provider", "Trash Collector", "Sewage System", "Telephone Company", "Gas Company"]:
        lua_file.write(f"        [\"{utility}\"] = Property.new(\"{utility}\", 150, \"utility\", {{4, 10, 20, 40, 80, 100, 120, 150}}),\n")

    lua_file.writelines("    }\nend")
