require("GUIDs")
require("Board")
require("BoardPositions")
require("Utils")
require("UMGame")

function doNothing() end
TheGame = UMGame.new()
local board = TheGame.board
local board_btns = {}
local mutated_btns = {}
local player_tokens = {}
Rigged = {}
local normaldie1 = getObjectFromGUID(GUIDs.dice.normal1)
local normaldie2 = getObjectFromGUID(GUIDs.dice.normal2)
local speeddie = getObjectFromGUID(GUIDs.dice.speedie)

function onLoad()
    Gameboard = getObjectFromGUID(GUIDs.gameboard)
    normaldie1 = getObjectFromGUID(GUIDs.dice.normal1)
    normaldie2 = getObjectFromGUID(GUIDs.dice.normal2)
    speeddie = getObjectFromGUID(GUIDs.dice.speedie)
    Gameboard.interactable = false
    -- createAllBoardButtons()
    registerNewPlayer("Blue", GUIDs.tokens.car)
    registerNewPlayer("Yellow", GUIDs.tokens.hat)
    registerNewPlayer("Green", GUIDs.tokens.iron)
    TheGame.money_changed_handler = function(debt)
        if debt.debtor then
            UI.setValue(debt.debtor.color .. "Money", "$" .. debt.debtor.money)
            broadcastToAll(debt:tostring(true), debt.debtor.color)
        end
        if debt.creditor then
            UI.setValue(debt.creditor.color .. "Money", "$" .. debt.creditor.money)
            if not debt.debtor then
                broadcastToAll(debt:tostring(true), debt.creditor.color)
            end
        end
    end
    TheGame:start("Blue")
    hideActionButtons()
end

function registerNewPlayer(color, token_guid)
    TheGame:createPlayer(color, token_guid, 3200)
    player_tokens[color] = getObjectFromGUID(token_guid)
    player_tokens[color].setColorTint(color)
    movePlayerToken(color, "Go")
end

---Moves a token to the specified space.
---@param player_color string The player's color.
---@param destination Space|string The space to move to.
---@param callback function Optional callback function to execute when the movement is complete.
function movePlayerToken(player_color, destination, callback)
    local occupant_position_index = #TheGame:getOccupantsOnSpace(destination) + 1
    ---@type Space
    local new_space
    if destination.occupant_positions and destination.direction then
        new_space = destination
    elseif type(destination) == "string" then
        new_space = TheGame.board.spaces[destination]
    else
        error("wanted a space or string but received " .. type(destination), 2)
    end
    assert(new_space, "new_space is nil")
    player_tokens[player_color].setPositionSmooth(new_space.occupant_positions[occupant_position_index])
    player_tokens[player_color].setRotationSmooth(new_space.direction.vector)
    if type(callback) == "function" then
        Wait.time(callback, 2)
    end
end

--#region Board button CUD
function createAllBoardButtons()
    -- TODO: Allow creation of buttons on specific spaces
    local i = 0
    for name, space in pairs(board.spaces) do
        -- Create a global function for the space event
        _G[name .. "_click"] = function(_, player_color)
            resetBoardButtons()
            colorBoardButton(name, Color.Green)
            --[[
            for i = 1, 15 do
                local visited_spaces = board:diceRoll(board.spaces[name], i, false)
                local last_space = visited_spaces[#visited_spaces]
                labelBoardButton(last_space.name, "" .. i)
                colorBoardButton(last_space.name, Color.Blue)
            end
            ]]
            local roll = 12
            local visited_spaces = board:diceRoll(board.spaces[name], roll,
                                                  false)
            local current_index = 1
            local last_space_was_transit = false
            local transit_count = 0
            local function animateSpaces()
                local current_space = visited_spaces[current_index]

                if last_space_was_transit and current_space.transit_type then
                    transit_count = transit_count + 1
                    last_space_was_transit = false
                elseif current_space.transit_type then
                    last_space_was_transit = true
                else
                    last_space_was_transit = false
                end

                labelBoardButton(current_space.name,
                                 "" .. current_index - transit_count)
                colorBoardButton(current_space.name, Color.Blue)

                if current_index < #visited_spaces then
                    current_index = current_index + 1
                    Wait.frames(animateSpaces, 10)
                end
            end

            Wait.frames(animateSpaces, 10)

            --[[             printToAll("============================")
            if space.outer then
                broadcastToAll("Outside is " .. space.outer.name, Color.Yellow)
                colorBoardButton(space.outer.name, Color.Yellow)
                table.insert(mutated_btns, space.outer.name)
            end
            broadcastToAll("Behind is " .. space.prev.name, Color.Red)
            colorBoardButton(space.prev.name, Color.Red)
            table.insert(mutated_btns, space.prev.name)
            broadcastToAll("Current is " .. name, Color.Green)
            colorBoardButton(name, Color.Green)
            table.insert(mutated_btns, name)
            broadcastToAll("Ahead is " .. space.next.name, Color.Blue)
            colorBoardButton(space.next.name, Color.Blue)
            table.insert(mutated_btns, space.next.name)
            if space.inner then
                broadcastToAll("Inside is " .. space.inner.name, Color.Pink)
                colorBoardButton(space.inner.name, Color.Pink)
                table.insert(mutated_btns, space.inner.name)
            end ]]
            for h, GUID in ipairs({
                GUIDs.tokens.car, GUIDs.tokens.cannon, GUIDs.tokens.lantern,
                GUIDs.tokens.moneybag, GUIDs.tokens.shoe, GUIDs.tokens.horse,
                GUIDs.tokens.thimble, GUIDs.tokens.train, GUIDs.tokens.hat,
                GUIDs.tokens.wheelbarrow
            }) do
                getObjectFromGUID(GUID).setPositionSmooth(Vector(
                                                              space.occupant_positions[h]),
                                                          false, true)
                getObjectFromGUID(GUID).setRotation(
                    Vector(space.direction.vector))
            end
            spawnAvatarOnSpace(player_color, space.name)
        end

        Gameboard.createButton({
            click_function = name .. "_click",
            color = {1, 1, 1, 0.8},
            label = name,
            font_size = 35,
            position = Vector(space.camera_pos):scale(Utils.board_scale_vector),
            rotation = space.direction.vector,
            tooltip = name,
            width = 300,
            height = 300
        })
        board_btns[name] = i
        i = i + 1
    end
end

function resetBoardButtons()
    for name in pairs(mutated_btns) do
        Gameboard.editButton({
            index = board_btns[name],
            color = {1, 1, 1, 0.8},
            label = name,
            font_size = 35
        })
        mutated_btns[name] = nil
    end
end

function colorBoardButton(name, new_color)
    Gameboard.editButton({index = board_btns[name], color = new_color})
    mutated_btns[name] = true
end

function labelBoardButton(name, new_text)
    Gameboard.editButton({
        index = board_btns[name],
        label = new_text,
        font_size = 100
    })
    mutated_btns[name] = true
end
--#endregion Board Button CUD

local die_launch_radius = 15

local function rollDieRoutine(die)
    local twopi = 2 * math.pi

    -- First, generate a random angle
    local angle = math.random() * 2 * twopi

    -- Calculate position based on the angle
    local x = die_launch_radius * math.cos(angle)
    local z = die_launch_radius * math.sin(angle)

    -- Move the die to that position
    die.setScale({1, 1, 1})
    die.setPosition({x, 11.3, z})
    die.setLock(false)

    -- Calculate launch angle - opposite initial angle
    -- This way the die is launched towards the center
    local launch = (angle + math.pi) % twopi

    -- Calculate launch vector coords
    local launch_x = die_launch_radius * math.cos(launch)
    local launch_z = die_launch_radius * math.sin(launch)

    -- Launch the die
    Wait.frames(function()
        die.interactable = false
        die.addForce({launch_x, 1, launch_z})
        die.addTorque({
            Utils.randomFloat(0, 20), Utils.randomFloat(0, 20),
            Utils.randomFloat(0, 20)
        })
    end)
end

local function speedDieString()
    local value = getObjectFromGUID(GUIDs.dice.speedie).getValue()
    if value == 6 then
        return "Bus"
    elseif value == 5 or value == 4 then
        return "Mr. Monopoly"
    else
        return value
    end
end

function showActionButtons()
    UI.setAttribute("tradeBtn", "visibility", TheGame:whoseTurn().color)
    UI.setAttribute("endTurnBtn", "visibility", TheGame:whoseTurn().color)
end

function hideActionButtons()
    UI.setAttribute("tradeBtn", "visibility", "0")
    UI.setAttribute("endTurnBtn", "visibility", "0")
end

---Called when the token has finished moving.
local function postMoveHandler()
    Gameboard.clearButtons()
    TheGame:submitDiceRoll(normaldie1.getValue(), normaldie2.getValue(), speeddie.getValue())
    movePlayerToken(TheGame:whoseTurn().color, TheGame:whoseTurn().location, function()
        showActionButtons()
        TheGame:handleSpaceAction()
    end)
    broadcastToAll(TheGame:whoseTurn():getName() .. " landed on " .. TheGame:whoseTurn().location.name, TheGame:whoseTurn().color)
end

local function animateDiceRoll(start, roll)
    local visited_spaces = board:diceRoll(board.spaces[start], roll, false)
    local current_index = 1
    local last_space_was_transit = false
    local transit_count = 0
    local function animateSpaces()
        local current_space = visited_spaces[current_index]

        if last_space_was_transit and current_space.transit_type then
            transit_count = transit_count + 1
            last_space_was_transit = false
        elseif current_space.transit_type then
            last_space_was_transit = true
        else
            last_space_was_transit = false
        end

        Gameboard.createButton({
            click_function = "doNothing",
            color = TheGame:whoseTurn().color,
            label = current_index - transit_count,
            font_size = 100,
            position = Vector(current_space.camera_pos):scale(Utils.board_scale_vector),
            rotation = current_space.direction.vector,
            width = 300,
            height = 300
        })

        if current_index < #visited_spaces then
            current_index = current_index + 1
            Wait.frames(animateSpaces, 10)
        else
            Wait.time(postMoveHandler, 1.5)
        end
    end

    Wait.frames(animateSpaces, 10)
end

local function rollRegularDice()
    if #Rigged == 3 then
        normaldie1.setValue(Rigged[1])
        normaldie2.setValue(Rigged[2])
        speeddie.setValue(Rigged[3])
    else
        rollDieRoutine(normaldie1)
        rollDieRoutine(normaldie2)
        rollDieRoutine(speeddie)
    end

    local function centerDiceAndBroadcastResult()
        normaldie1.scale(2)
        normaldie2.scale(2)
        speeddie.scale(2)
        normaldie1.setPositionSmooth({-2, 3.5, 0}, false)
        normaldie2.setPositionSmooth({0, 3.5, 0}, false)
        speeddie.setPositionSmooth({2, 3.5, 0}, false)
        local total_rolled = normaldie1.getValue() + normaldie2.getValue() + UMGame.speedDieValue(speeddie.getValue())
        broadcastToAll(TheGame:whoseTurn():getName() .. " rolled " .. normaldie1.getValue() .. ", " ..
                           normaldie2.getValue() .. " and " .. speedDieString() .. " = " .. total_rolled, TheGame:whoseTurn().color)
        Wait.frames(function()
            normaldie1.setLock(true)
            normaldie2.setLock(true)
            speeddie.setLock(true)
        end)
        -- Move the player to the spot
        animateDiceRoll(TheGame:whoseTurn().location.name, total_rolled)
    end

    local function allThreeDiceAreResting()
        return normaldie1.resting and normaldie2.resting and speeddie.resting
    end

    local function broadcastErrorMessage()
        broadcastToAll("Could not get the die result", "Red")
    end

    -- Notify of the number
    Wait.frames(function()
        Wait.condition(centerDiceAndBroadcastResult, allThreeDiceAreResting, 7,
                       broadcastErrorMessage)
    end)
end

function onObjectPickUp(player_color, object)
    if Utils.equalsAny(object.getGUID(), GUIDs.dice) then
        object.drop()
        if player_color == TheGame:whoseTurn().color then
            rollRegularDice()
        else
            --TODO: Specify what is being waited on
            --e.g. Blue is waiting to roll the dice
            --Yellow is considering the trade offer
            --Green is building stuff
            broadcastToColor("It is " .. TheGame:whoseTurn():getName() .. "'s turn right now.", player_color, "Red")
        end
    end
end

function endTurnClick(player)
    if player.color == TheGame:whoseTurn().color then
        TheGame:nextTurn()
        broadcastToAll(TheGame:whoseTurn():getName() .. "'s turn starts now.", TheGame:whoseTurn().color)
        hideActionButtons()
        for _, die in ipairs({normaldie1, normaldie2, speeddie}) do
            die.scale(0.5)
            die.setLock(false)
            die.interactable = true
        end
    end
end

function spawnAvatarOnSpace(color, space_name)
    local player_id = Player[color].steam_id
    local space = board.spaces[space_name]
    local customCard = spawnObject({
        type = "Card",
        position = Vector(space.avatar_pos),
        rotation = Vector(space.direction.clockwise().clockwise().vector),
        sound = false,
        scale = {0.25, 1, 0.25}
    })
    WebRequest.get("https://steamcommunity.com/profiles/" .. player_id ..
                       "?xml=1",
    -- TODO: Fallback when the steam avatar can't be fetched
                   function(response)
        local regex = "<avatarFull><!%[CDATA%[([%w%p]+)%]%]></avatarFull>"
        local image_url = assert(response.text:match(regex),
                                 "Unable to fetch the steam avatar of " ..
                                     Player[color].steam_name)
        customCard.setCustomObject({face = image_url, back = image_url})
    end)
end

function lookAtJail(color)
    Player[color].lookAt({
        position = {x = -5, y = 0, z = -5},
        pitch = 30,
        yaw = 45,
        distance = 10
    })
end
