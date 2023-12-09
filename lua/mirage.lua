local aoc = require"adventofcode"

local function extrapolate(seq)
    local dif = {}
    local zero = true
    for n = 1,#seq-1 do
        dif[n] = seq[n+1] - seq[n]
        zero = zero and dif[n] == 0
    end
    if zero then
        return seq[#seq]
    end
    return seq[#seq] + extrapolate(dif)
end

local function exbackolate(seq)
    local dif = {}
    local zero = true
    for n = 1,#seq-1 do
        dif[n] = seq[n+1] - seq[n]
        zero = zero and dif[n] == 0
    end
    if zero then
        return seq[1]
    end
    return seq[1] - exbackolate(dif)
end

function mirage1(line)
    local seq = aoc.map(aoc.findall(line, "%-?%d+"), tonumber)
    return extrapolate(seq)
end

function mirage2(line)
    local seq = aoc.map(aoc.findall(line, "%-?%d+"), tonumber)
    return exbackolate(seq)
end

-- main
aoc.run_reduce_sum{mirage1, mirage2}
