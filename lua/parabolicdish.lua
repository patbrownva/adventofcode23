-- Advent of Code 2023
-- Day 14: Parabolic Reflector Dish

function compile(L)
    L = L or require"lpeg"
    local concat, reverse, rep = table.concat, string.reverse, string.rep

    local blank = "."
    local stop = "#"
    local rock = "O"
    local roll = L.P(rock)+blank
    local any = stop+roll
    local eol = L.P"\n"
    local eof = L.P(-1)

    local function rotate(rows, col)
        for i = 1,#col do
            local r = rows[i] or {}
            r[#r+1] = col[i]
            rows[i] = r
        end
        return rows
    end

    local function join(rows)
        local collect = {}
        for i = 1,#rows do
            collect[#collect+1] = reverse(concat(rows[i]))
            collect[#collect+1] = "\n"
        end
        return concat(collect)
    end

    local function clockwise()
        local col = L.C(any)
        local row = L.Ct(col^0) * eol
        local grid =  L.Cf(L.Cc{} * row^0, rotate) * eof
        return grid / join
    end

    local function sum(a, b)
        return a + (b or 0)
    end

    local function minus(a, b)
        return b - a
    end

    function weight()
        local start = L.Cg(L.Cp(), "start")
        local col = (rock * L.Cb"start" * L.Cp() / minus) + any
        local row = start * L.Cf(L.Cc(0) * col^0, sum) * eol
        local grid = L.Cf(L.Cc(0) * row^0 * eof , sum)
        return grid
    end

    local function tally(key, count)
        count[key] = (count[key] or 0) + 1
        return true
    end
    
    local function shift(count)
        local empty = count.tally[blank] or 0
        local filled =  count.tally[rock] or 0
        count.tally[blank] = 0
        count.tally[rock] = 0
        return rep(blank, empty) .. rep(rock, filled)
    end
    
    local function tilt()
        local count = L.C(roll) * L.Cb"tally" / tally
        local run = L.Ct(L.Cg(L.Cc{}, "tally") * count^1) / shift
        return L.Cs((run^-1 * (stop + eol))^0) * eof
    end

    local function template(pattern)
        return function(input)
            return pattern():match(input)
        end
    end

    return template(clockwise), template(weight), template(tilt)
end

-- main
local clockwise, weight, tilt = compile()
local grid = io.read"all"
-- turn once so North faces toward each eol
grid = clockwise(grid)

local function tilt_and_turn(g)
    return clockwise(tilt(g))
end

local function cycle()
    grid = tilt_and_turn(tilt_and_turn(
           tilt_and_turn(tilt_and_turn(grid))))
end
    
-- part 1
print(weight(tilt(grid)))

-- part 2
local loop = {}
local iter = tonumber(arg[1] or 1000000000)
for I = 1, iter do
    if loop[grid] then
        local depth = I - loop[grid]
        --print("Loop of length "..(depth).." detected after "..(I-1).." steps")
        --print((iter - I) % depth, (iter - I) % depth + loop[grid] + 1)
        grid = loop[(iter - I) % depth + loop[grid] + 1]
        break
    end
    loop[grid] = I
    loop[I] = grid
    cycle()
end
print(weight(grid))
