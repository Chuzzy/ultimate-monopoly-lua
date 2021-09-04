Debug = {
    let_anyone_roll = false
}

---Sells a fixed list of properties to Blue, Green and Yellow.
function Debug.handOut()
    local properties_to_hand_out = {
        Blue = {
            Names.fifth,
            Names.madison,
            Names.wall,
        },
        Yellow = {
            Names.esplanade,
            Names.canal,
            Names.magazine,
        },
        Green = {
            Names.cable,
            Names.vermont,
            Names.reading,
            Names.checker,
            Names.yellow
        }
    }
    for player_color, properties_for_player in pairs(properties_to_hand_out) do
        for _, property_name in ipairs(properties_for_player) do
            UMGame.sellPropertyTo(UMGame.players_by_color[player_color], UMGame.properties[property_name])
        end
    end
end

function Debug.toggleLetAnyoneRoll()
    Debug.let_anyone_roll = not Debug.let_anyone_roll
    print(Debug.let_anyone_roll and "Anyone can roll." or "Only one player can roll.")
end
