local aoc = require"adventofcode"
    
function list_of_nums(line)
    local list = {}
    for match in line:gmatch("%d+") do
        list[#list+1] = tonumber(match)
    end
    return list
end

function union(left, right)
    local source = {}
    for _, item in ipairs(left) do
        source[item] = 1
    end
    local collect = {}
    for _, item in ipairs(right) do
        collect[#collect+1] = source[item] and item
    end
    return collect
end

function card(line)
    local card_num = line:match("Card( *%d+):")
    line = line:sub(6+#card_num)
    local split = line:find('|')
    return tonumber(card_num), list_of_nums(line:sub(1,split-1)), list_of_nums(line:sub(split+1))
end

local CARDS = {}

function scratchcards1(line)
    local card_num, winning, drawn = card(line)
    local matches = union(winning, drawn)
    return #matches > 0 and math.tointeger(2^(#matches-1)) or 0
end

function scratchcards2(line)
    local card_num, winning, drawn = card(line)
    CARDS[card_num] = (CARDS[card_num] or 0) + 1
    local matches = union(winning, drawn)
    if #matches > 0 then
        for win_card = card_num+1, card_num+#matches do
            CARDS[win_card] = (CARDS[win_card] or 0) + CARDS[card_num]
        end
    end
    return CARDS[card_num]
end

-- main
aoc.run_reduce_sum({scratchcards1, scratchcards2})
