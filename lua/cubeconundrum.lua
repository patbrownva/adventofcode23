local aoc = require"adventofcode"

function game_set(line)
    local set = { red=0, green=0, blue=0 }
    for num,color in line:gmatch("(%d+) +(%a+)") do
        set[color] = tonumber(num)
    end
    return set
end

function play_set(game, set)
    local function set_color(color)
        if set[color] > game[color] then
            game[color] = set[color]
        end
    end
    set_color"red"
    set_color"green"
    set_color"blue"
end

function play_game(game, line)
    local start = 1
    while start do
        local sep_start, sep_stop = line:find('; *', start)
        play_set(game, game_set(line:sub(start, sep_start)))
        start = sep_start and sep_stop+1
    end
    return game
end

function start_game(line)
    local game = { red=0, green=0, blue=0 }
    local game_num = line:match("Game (%d+): ")
    if not game_num then return nil end
    game.num = tonumber(game_num)
    line = line:sub(8 + #game_num)
    return play_game(game, line)
end

function cubeconundrum1(line, max_cubes)
    local game = start_game(line)
    if game.red > max_cubes.red
    or game.green > max_cubes.green
    or game.blue > max_cubes.blue then
        return 0
    end
    return game.num
end

function cubeconundrum2(line)
    local game = start_game(line)
    return game.red * game.green * game.blue
end

-- main
aoc.run_reduce_sum({cubeconundrum1, cubeconundrum2}, {red=12, green=13, blue=14})
