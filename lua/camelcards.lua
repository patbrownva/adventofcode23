
function make_cards(cards)
    local map = {}
    for i = 1,#cards do
        map[i] = cards:sub(i,i)
        map[map[i]] = i
    end
    CARDS = map
end

function make_hand(str)
    local cards = {}
    for i = 1,#str do
        cards[#cards+1] = CARDS[str:sub(i,i)]
    end
    return cards
end

function less_cards(left, right)
    local lh,rh = score_hand(left), score_hand(right)
    if lh < rh then return true end
    if lh > rh then return false end
    for i = 1, #left do
        if left[i] < right[i] then return true end
        if left[i] > right[i] then return false end
    end
    return false
end

function less_cards_joker(left, right)
    local lh,rh = score_hand_joker(left), score_hand_joker(right)
    if lh < rh then return true end
    if lh > rh then return false end
    for i = 1, #left do
        if left[i] < right[i] then return true end
        if left[i] > right[i] then return false end
    end
    return false
end

local score_table = { 0, 1, 3, 5, 6 }
function score_hand(cards)
    local tally = {}
    for _, c in ipairs(cards) do
        tally[c] = (tally[c] or 0) + 1
    end
    local counts = {}
    for c,n in pairs(tally) do
        counts[#counts+1] = n
    end
    table.sort(counts, function(i,j) return j < i end)
    local score = score_table[counts[1]]
    if counts[2] == 2 and (score == 1 or score == 3) then
        score = score + 1
    end
    return score
end
function score_hand_joker(cards)
    local tally = {}
    for _, c in ipairs(cards) do
        tally[c] = (tally[c] or 0) + 1
    end
    local counts = {}
    for c,n in pairs(tally) do
        if c ~= 1 then
            counts[#counts+1] = n
        end
    end
    table.sort(counts, function(i,j) return j < i end)
    counts[1] = (counts[1] or 0) + (tally[1] or 0)
    local score = score_table[counts[1]]
    if counts[2] == 2 and (score == 1 or score == 3) then
        score = score + 1
    end
    return score
end

function read_hands(input)
    local hands = {}
    for line in input:lines() do
        local cards,bid = line:match("(%S+) +(%d+)")
        hands[#hands+1] = {make_hand(cards), tonumber(bid)}
    end
    return hands
end

function rank_hands(hands)
    local sum = 0
    for rank,hand in ipairs(hands) do
        sum = sum + hand[2] * rank
    end
    return sum
end

function camelcards1()
    make_cards("23456789TJQKA")
    local hands = read_hands(io.stdin)
    table.sort(hands, function(a,b) return less_cards(a[1],b[1]) end)
    return rank_hands(hands)
end

function camelcards2()
    make_cards("J23456789TQKA")
    local hands = read_hands(io.stdin)
    table.sort(hands, function(a,b) return less_cards_joker(a[1],b[1]) end)
    return rank_hands(hands)
end

-- main
require"adventofcode".run{camelcards1,camelcards2}
