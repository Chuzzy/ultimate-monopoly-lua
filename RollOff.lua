RollOff = {
    dice = {},
    dice_totals = {}
}

function RollOff.rollTheDie(die) Wait.time(function() die.randomize() end, 0.1, 15) end

function RollOff.rollOff(participants)
    local die_size = 2
    local die_distance_apart = 2
    RollOff.dice_totals = {}
    participants = participants or Player.getPlayers()
    -- Give every single player a pair of six-sided dice
    for _, player in ipairs(participants) do
        -- Calculate locations for the two dice.
        -- These locations are the position of the player's hand zone.
        local spawn_location = player.getHandTransform().position:add(
                                   player.getHandTransform().forward:scale(3))
        local spawn_location_left = player.getHandTransform().right:scale(
                                        -die_distance_apart):add(spawn_location)
        local spawn_location_right = player.getHandTransform().right:scale(
                                         die_distance_apart):add(spawn_location)

        -- If there aren't roll off dice already, spawn them in
        if not RollOff.dice[player.color .. "1"] then

            RollOff.dice[player.color .. "1"] = spawnObject {
                type = "Die_6",
                position = spawn_location_left,
                scale = {die_size, die_size, die_size},
                sound = false,
                callback_function = function(die)
                    die.interactable = false
                    die.setColorTint(player.color)
                    RollOff.rollTheDie(die)
                end
            }

            RollOff.dice[player.color .. "2"] = spawnObject {
                type = "Die_6",
                position = spawn_location_right,
                scale = {die_size, die_size, die_size},
                sound = false,
                callback_function = function(die)
                    die.interactable = false
                    die.setColorTint(player.color)
                    RollOff.rollTheDie(die)
                end
            }
        else
            RollOff.rollTheDie(RollOff.dice[player.color .. "1"])
            RollOff.rollTheDie(RollOff.dice[player.color .. "2"])
        end

        RollOff.dice_totals[player.color] = nil

        -- Once the dice are resting, broadcast this player's roll
        -- and add the result to the dice_totals table
        local function broadcastMyRoll()
            local total_rolled = RollOff.Dice[player.color .. "1"].getValue() +
                                     RollOff.Dice[player.color .. "2"].getValue()
            broadcastToAll(player.steam_name .. " rolled " .. total_rolled,
                           player.color)
            RollOff.dice_totals[player.color] = total_rolled
        end

        local function onceMyDiceAreResting()
            return RollOff.Dice[player.color .. "1"].resting and
                       RollOff.Dice[player.color .. "2"].resting
        end

        Wait.frames(function()
            Wait.condition(broadcastMyRoll, onceMyDiceAreResting)
        end, 20)
    end

    local function onceAllDiceAreResting()
        for _, die in pairs(RollOff.Dice) do
            if not die.resting then return false end
        end
        return true
    end

    local function showWinnerOrReroll()
        local highest_roll
        local best_players = {}
        for color, total_rolled in pairs(RollOff.dice_totals) do
            if total_rolled > (highest_roll or 0) then
                highest_roll = total_rolled
                best_players = {Player[color]}
            elseif total_rolled == highest_roll then
                table.insert(best_players, Player[color])
            end
        end
        Wait.time(function()
            if #best_players == 1 then
                broadcastToAll(best_players[1].steam_name .. " rolled " ..
                                   highest_roll .. " and won the roll off.",
                               best_players[1].color)
                onLoad()
            else
                -- Concatenate the best players' names
                local best_players_names = {}
                for _, p in ipairs(best_players) do
                    table.insert(best_players_names, p.steam_name)
                end
                broadcastToAll(table.concat(best_players_names, ", ") ..
                                   " tied on " .. highest_roll ..
                                   " and need to reroll.")
                -- Re-roll off
                Wait.time(function() RollOff.rollOff(best_players) end, 2)
            end
        end, 1)
    end

    Wait.frames(function()
        Wait.condition(showWinnerOrReroll, onceAllDiceAreResting, 10,
                       function() error("Took too long to settle it") end)
    end, 25)
end
