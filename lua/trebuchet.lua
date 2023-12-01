local aoc = require"adventofcode"

function trebuchet1 (line)
    local first = string.match(line, '%d') or ''
    local last = string.match(string.reverse(line), '%d') or ''
    return tonumber(first .. last) or 0
end

-- main
local stage = ({['1']=trebuchet1, ['2']=trebuchet2})[arg[1]] or trebuchet1
local lines = {}
for line in io.lines() do
    lines[#lines+1] = stage(line)
end
print(aoc.reduce(aoc.sum, lines))
