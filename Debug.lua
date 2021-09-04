Debug = {}

---Sells some property to some people.
function Debug.handOut()
    UMGame.sellPropertyTo(UMGame.players_by_color.Blue, UMGame.properties[Names.wall])
end
