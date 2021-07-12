require("GUIDs")
require("Board")
require("BoardPositions")
require("Utils")
require("UMGame")
require("InGameObjects")
require("ClickHandlers")

function doNothing() end
TheGame = UMGame.new()
local board = TheGame.board
local board_btns = {}
local mutated_btns = {}
local player_tokens = {}
Rigged = { force = 0 }

function onLoad()
    populateInGameObjects(GUIDs)
    InGameObjects.gameboard.interactable = false
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
    TheGame.property_changed_handler = function (property)
        --TODO: Replace existing avatar
        spawnAvatarOnSpace(property.owner.color, Utils.propertyToSpace(property.name))
    end
    TheGame.player_moved_handler = movePlayerToken
    TheGame:start("Blue")
    hideActionButtons()
end

function registerNewPlayer(color, token_guid)
    player_tokens[color] = getObjectFromGUID(token_guid)
    player_tokens[color].setColorTint(color)
    player_tokens[color].interactable = false
    movePlayerToken(TheGame:createPlayer(color, token_guid, 3200), board.spaces[Names.go])
end

---Moves a token to the specified space.
---@param player UMPlayer The player.
---@param destination Space The space to move to.
function movePlayerToken(player, destination)
    local occupant_position_index = #TheGame:getOccupantsOnSpace(destination)
    assert(destination, "destination is nil")
    local player_color = player.color
    player_tokens[player_color].setPositionSmooth(destination.occupant_positions[occupant_position_index])
    player_tokens[player_color].setRotationSmooth(destination.direction.vector)
    if Player[player_color].seated then
        Player[player_color].pingTable(destination.camera_pos)
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

        InGameObjects.gameboard.createButton({
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
        InGameObjects.gameboard.editButton({
            index = board_btns[name],
            color = {1, 1, 1, 0.8},
            label = name,
            font_size = 35
        })
        mutated_btns[name] = nil
    end
end

function colorBoardButton(name, new_color)
    InGameObjects.gameboard.editButton({index = board_btns[name], color = new_color})
    mutated_btns[name] = true
end

function labelBoardButton(name, new_text)
    InGameObjects.gameboard.editButton({
        index = board_btns[name],
        label = new_text,
        font_size = 100
    })
    mutated_btns[name] = true
end

---Creates property management buttons on the board.
---This subroutine creates a button on each space the player owns.
---When clicked it shows the title deed allowing the player to buy/sell improvements.
---@param player UMPlayer The player to create property management buttons for.
function createManagementBoardButtons(player)
    local i = 0
    for name, property in pairs(player.owned_properties) do
        local space = Utils.propertyToSpace(property, TheGame)
        -- Create the event handler when the button is clicked
        _G[name .. " Clicked"] = function (_, player_color)
            TheGame:showPropertyInfo(property, player)
        end

        -- Create the board button
        InGameObjects.gameboard.createButton({
            click_function = name .. " Clicked",
            color = {1, 1, 1, 0.8},
            label = name:gsub(" ", "\n"),
            font_size = 65,
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
    local value = getObjectFromGUID(GUIDs.dice.speed).getValue()
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
    InGameObjects.gameboard.clearButtons()
    TheGame:submitDiceRoll(InGameObjects.dice.normal1.getValue(), InGameObjects.dice.normal2.getValue(), InGameObjects.dice.speed.getValue())
    broadcastToAll(TheGame:whoseTurn():getName() .. " landed on " .. TheGame:whoseTurn().location.name, TheGame:whoseTurn().color)
    Wait.time(function()
       showActionButtons()
       TheGame:handleSpaceAction()
    end, 2)
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

        InGameObjects.gameboard.createButton({
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
    if Rigged.force > 0 then
        TheGame:submitDiceRoll(Rigged.force, 0, 0)
        broadcastToAll(TheGame:whoseTurn():getName() .. " \"landed\" on " .. TheGame:whoseTurn().location.name, TheGame:whoseTurn().color)
        Wait.time(function()
            showActionButtons()
            TheGame:handleSpaceAction()
        end, 2)
        return
    elseif #Rigged == 3 then
        InGameObjects.dice.normal1.setValue(Rigged[1])
        InGameObjects.dice.normal2.setValue(Rigged[2])
        InGameObjects.dice.speed.setValue(Rigged[3])
    else
        rollDieRoutine(InGameObjects.dice.normal1)
        rollDieRoutine(InGameObjects.dice.normal2)
        rollDieRoutine(InGameObjects.dice.speed)
    end

    local function centerDiceAndBroadcastResult()
        local die_positions = {{-2, 3.5, 0}, {0, 3.5, 0}, {2, 3.5, 0}}
        do
            local i = 1
            for name, die in pairs(InGameObjects.dice) do
                if name ~= "normal3" and name ~= "voucher" then
                    die.setScale({2, 2, 2})
                    die.setPositionSmooth(die_positions[i], false)
                    -- "Straighten" the die by getting its current value
                    -- then looping through all rotation values until the
                    -- current die value is found, then set the die's rotation
                    for _, rot_value in ipairs(die.getRotationValues()) do
                        if rot_value.value == die.getValue() then
                            die.setRotationSmooth(rot_value.rotation)
                        end
                    end
                    i = i + 1
                end
            end
        end

        local total_rolled = InGameObjects.dice.normal1.getValue() + InGameObjects.dice.normal2.getValue() + UMGame.speedDieValue(InGameObjects.dice.speed.getValue())
        broadcastToAll(TheGame:whoseTurn():getName() .. " rolled " .. InGameObjects.dice.normal1.getValue() .. ", " ..
                           InGameObjects.dice.normal2.getValue() .. " and " .. speedDieString() .. " = " .. total_rolled, TheGame:whoseTurn().color)
        Wait.frames(function()
            InGameObjects.dice.normal1.setLock(true)
            InGameObjects.dice.normal2.setLock(true)
            InGameObjects.dice.speed.setLock(true)
        end)
        -- Move the player to the spot
        animateDiceRoll(TheGame:whoseTurn().location.name, total_rolled)
    end

    local function allThreeDiceAreResting()
        return InGameObjects.dice.normal1.resting and InGameObjects.dice.normal2.resting and InGameObjects.dice.speed.resting
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

function spawnAvatarOnSpace(color, space_name)
    local player_id = Player[color].steam_id
    local space = board.spaces[space_name]
    WebRequest.get("https://steamcommunity.com/profiles/" .. player_id ..
                       "?xml=1",
    -- TODO: Fallback when the steam avatar can't be fetched
                   function(response)
        local regex = "<avatarFull><!%[CDATA%[([%w%p]+)%]%]></avatarFull>"
        local image_url = assert(response.text:match(regex),
                                 "Unable to fetch the steam avatar of " ..
                                        Player[color].steam_name)
        local customCard = spawnObject({
            type = "Custom_Tile",
            position = Vector(space.avatar_pos):add(Vector{0, 4, 0}),
            rotation = Vector(space.direction.clockwise().clockwise().vector),
            sound = false,
            scale = {0.36, 1, 0.36}
        })
        customCard.setColorTint(color)
        customCard.setCustomObject({image = image_url, thickness = 0.03})
        customCard.interactable = false
        Wait.time(function () customCard.setLock(true) end, 2)
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
