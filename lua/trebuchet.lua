local aoc = require"adventofcode"

local function find_first_of(str, pats)
    local found_pos = #str + 1
    local found
    for _, pat in pairs(pats) do
        local pos, pose = string.find(str, pat)
        if pos and pos < found_pos then
            found = string.sub(str, pos, pose)
            found_pos = pos
        end
        -- small optimization if we have the first possible match
        if pos == 1 then
            break
        end
    end
    return found
end

local function find_last_of(str, pats)
    for pos = -1, -#str, -1 do
        for _, pat in pairs(pats) do
            local found = string.match(str, pat, pos)
            if found then return found end
        end
    end
    return nil
end

function trebuchet1 (line)
    line = string.lower(line)
    local first = string.match(line, '%d') or ''
    local last = string.match(string.reverse(line), '%d') or ''
    return tonumber(first .. last) or 0
end

local number_words = {
    'one', 'two', 'three', 'four', 'five', 'six', 'seven', 'eight', 'nine', 'zero', '%d'
}
local function word_to_number (word)
    local num = tonumber(word)
    if num then return num end
    if word == 'zero' then return 0 end
    return aoc.index(number_words, word)
end

function trebuchet2 (line)
    line = string.lower(line)
    local first = find_first_of(line, number_words)
    local last = find_last_of(line, number_words)
    first = first and word_to_number(first) or ''
    last = last and word_to_number(last) or ''
    return tonumber(first .. last) or 0
end

-- main
local stage = ({['1']=trebuchet1, ['2']=trebuchet2})[arg[1]] or trebuchet1
local lines = {}
for line in io.lines() do
    lines[#lines+1] = stage(line)
end
print(aoc.reduce(lines, aoc.sum))
