local aoc = require"adventofcode"
    
function list_of_nums(line)
    return aoc.map(aoc.findall(line, "%d+"), tonumber)
end

function card(line)
    local card_num, left, right = line:match("Card *(%d+):([^|]+)|(.*)")
    return tonumber(card_num), list_of_nums(left), list_of_nums(right)
end

local CARDS = {}

function scratchcards1(line)
    local card_num, winning, drawn = card(line)
    local matches = aoc.intersect(winning, drawn)
    return #matches > 0 and math.tointeger(2^(#matches-1)) or 0
end

function scratchcards2(line)
    local card_num, winning, drawn = card(line)
    CARDS[card_num] = (CARDS[card_num] or 0) + 1
    local matches = aoc.intersect(winning, drawn)
    if #matches > 0 then
        for win_card = card_num+1, card_num+#matches do
            CARDS[win_card] = (CARDS[win_card] or 0) + CARDS[card_num]
        end
    end
    return CARDS[card_num]
end

-- main
aoc.run_reduce_sum({scratchcards1, scratchcards2})
