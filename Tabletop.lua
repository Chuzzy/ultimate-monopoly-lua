require("GUIDs")
require("Board")
require("BoardPositions")

local board = Board.new()
local board_btns = {}
local mutated_btns = {}


function onLoad()
    -- triggerPoliceLights()
    Gameboard = getObjectFromGUID(GUIDs.gameboard)
    createAllBoardButtons()
end

function createAllBoardButtons()
    local i = 0
    for name, space in pairs(board.spaces) do
        -- The board's local scale is different to the
        -- global scale. When creating buttons the position
        -- vectors have to be multiplied by 0.63 to appear normal.
        local board_scale_vector = Vector(0.63, 0.3, -0.63)

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
            local visited_spaces = board:diceRoll(board.spaces[name], roll, false)
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

                labelBoardButton(current_space.name, "" .. current_index - transit_count)
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
            for h, GUID in ipairs({GUIDs.tokens.car, GUIDs.tokens.cannon, GUIDs.tokens.lantern, GUIDs.tokens.moneybag, GUIDs.tokens.shoe, GUIDs.tokens.horse, GUIDs.tokens.thimble, GUIDs.tokens.train, GUIDs.tokens.hat, GUIDs.tokens.wheelbarrow}) do
                getObjectFromGUID(GUID).setPositionSmooth(Vector(space.occupant_positions[h]), false, true)
                getObjectFromGUID(GUID).setRotation(Vector(space.direction.vector))
            end
            spawnAvatarOnSpace(player_color, space.name)
        end

        Gameboard.createButton({
            click_function = name .. "_click",
            color = {1, 1, 1, 0.8},
            label = name,
            font_size = 35,
            position = Vector(space.camera_pos):scale(board_scale_vector),
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
    Gameboard.editButton({index = board_btns[name], label = new_text, font_size = 100})
    mutated_btns[name] = true
end

function triggerPoliceLights()
    local normal_light_intensity = 0.54
    local normal_light_color = Color.new(255, 251, 228)
    local is_blue = false

    function toggleLights()
        local light_color = is_blue and Color.Red or Color.Blue
        Lighting.setLightColor(light_color)
        Lighting.apply()
        is_blue = not is_blue
    end

    function normalLight()
        Lighting.setLightColor(normal_light_color)
        Lighting.light_intensity = normal_light_intensity
        Lighting.apply()
    end

    Lighting.light_intensity = 1.5

    toggleLights()
    Wait.time(toggleLights, 0.5, 14)
    Wait.time(normalLight, 7)
end

function spawnAvatarOnSpace(color, space_name)
    local player_id = Player[color].steam_id
    local space = board.spaces[space_name]
    customCard = spawnObject({
        type = "Card",
        position = Vector(space.avatar_pos),
        rotation = Vector(space.direction.clockwise().clockwise().vector),
        sound = false,
        scale = {0.25, 1, 0.25}
    })
    WebRequest.get("https://steamcommunity.com/profiles/" .. player_id .. "?xml=1",
    function (response)
        local regex = "<avatarFull><!%[CDATA%[([%w%p]+)%]%]></avatarFull>"
        local image_url = assert(response.text:match(regex), "Unable to fetch the steam avatar of " .. Player[color].steam_name)
        customCard.setCustomObject({
            face = image_url,
            back = image_url
        })
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
