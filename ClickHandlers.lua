function endTurnClick(player)
    if player.color == TheGame:whoseTurn().color then
        TheGame:nextTurn()
        broadcastToAll(TheGame:whoseTurn():getName() .. "'s turn starts now.",
                       TheGame:whoseTurn().color)
        hideActionButtons()
        TheGame:hidePropertyInfo()
        InGameObjects.gameboard.clearButtons()
        for _, die in ipairs({InGameObjects.dice.normal1, InGameObjects.dice.normal2, InGameObjects.dice.speed}) do
            die.scale(0.5)
            die.setLock(false)
            die.interactable = true
        end
    end
end

function buyCurrentProperty(player)
    TheGame:sellPropertyTo()
    TheGame:hidePropertyInfo()
    TheGame.state = GameState.POST_MOVEMENT
    createManagementBoardButtons(TheGame.players_by_color[player.color])
end
