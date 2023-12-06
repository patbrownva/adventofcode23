local aoc = require"adventofcode"

function input1(file)
    local times = aoc.map(aoc.findall(file:read(), "%d+"), tonumber)
    local distances = aoc.map(aoc.findall(file:read(), "%d+"), tonumber)
    assert(#times == #distances)
    local races = {}
    for i = 1,#times do
        races[#races+1] = {times[i],distances[i]}
    end
    return races
end

function input2(file)
    local times = file:read():gsub("%s", "")
    local distances = file:read():gsub("%s", "")
    return tonumber(times:match("%d+")), tonumber(distances:match("%d+"))
end

function trials(time)
    local distances = {}
    for x = 0,time do
        distances[#distances+1] = (time - x) * x
    end
    return distances
end

--[[ Plot of a typical trial 
              __
        |   ~~  ~~
        | /        \
        |'          `
        0------------T

Or expressed as -x^2 + T*x - D
              __
     |      ~~  ~~
     |    /        \
     0---'----------`---T

It's symmetrical at T/2 which makes me think I could even
find the first root and double to get total number of solutions.
]]--

function shortest_trial(time, distance)
    local peak = 0
    for x = 0,time do
        local d = (time - x) * x
        if d > distance then
            return x
        end
        if d < peak then
            break
        end
        peak = d
    end
    return nil
end

function longest_trial(time, distance)
    local peak = 0
    for x = time,0,-1 do
        local d = (time - x) * x
        if d > distance then
            return x
        end
        if d < peak then
            break
        end
        peak = d
    end
    return nil
end

function part1(file)
    local races = input1(file)
    local score = 1
    for i,race in ipairs(races) do
        local wins = 0
        for _,distance in ipairs(trials(race[1])) do
            if distance > race[2] then
                wins = wins + 1
            end
        end
        score = score * wins
    end
    return score
end

function part2(file)
    local time, distance = input2(file)
    local short = shortest_trial(time, distance)
    --[[
    local long = longest_trial(time, distance)
    if short and long then
        return long - short + 1
    end
    ]]
    if short then return time - short*2 + 1 end
    return 0
end

-- main
local stage = part1
if arg[1] == '2' then stage = part2 end
print(stage(io.stdin))
