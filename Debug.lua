Debug = {
    let_anyone_act = false,
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

function Debug.toggleLetAnyoneAct()
    Debug.let_anyone_act = not Debug.let_anyone_act
    log(Debug.let_anyone_act and "Anyone can act." or "Only one player can act.", "Debug.toggleLetAnyoneAct", "debug")
end
