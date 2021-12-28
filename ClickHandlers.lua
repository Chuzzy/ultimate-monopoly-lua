function endTurnClick(player)
    if Debug.let_anyone_act or player.color == UMGame.whoseTurn().color then
        UMGame.nextTurn()
        broadcastToAll(UMGame.whoseTurn():getName() .. "'s turn starts now.",
                       UMGame.whoseTurn().color)
        hideActionButtons()
        PropertyUI.hide()
        InGameObjects.gameboard.clearButtons()
        for _, die in ipairs({InGameObjects.dice.normal1, InGameObjects.dice.normal2, InGameObjects.dice.speed}) do
            die.setScale({1, 1, 1})
            die.setLock(false)
            die.interactable = true
        end
    end
end

function buyCurrentProperty(player)
    UMGame.sellPropertyTo()
    PropertyUI.hide()
    UMGame.state = GameState.POST_MOVEMENT
    createManagementBoardButtons(UMGame.whoseTurn())
end

function downgradeProperty(player)
    UMGame.downgradeProperty()
end

function upgradeProperty()
    UMGame.upgradeProperty()
end

function cancelImprovements()
    UMGame.cancelImprovements()
end

function confirmImprovements()
    UMGame.confirmImprovements()
end
