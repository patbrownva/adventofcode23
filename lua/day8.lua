local aoc = require"adventofcode"

function maps(input)
    local turns = input:read()
    local nodes = {}
    for line in input:lines() do
        local here, left, right = line:match[[(%w+) = %((%w+), (%w+)%)]]
        if here then
            nodes[here] = {here, L=left, R=right, key=here:sub(-1)}
        end
    end
    return turns, nodes
end

function follow_turns(turns)
    local yield = coroutine.yield
    local substr = string.sub
    return coroutine.wrap(function()
        local n = 1
        while true do
            for i = 1,#turns do
                yield(n, i, substr(turns, i, i))
                n = n + 1
            end
        end
    end)
end

function part1(turns, nodes)
    local here = nodes['AAA']
    for steps, _, turn in follow_turns(turns) do
        --print(here[1], turn, here[turn])
        if here[turn] == 'ZZZ' then
            return steps
        end
        here = nodes[here[turn]]
        if not here then
            return "broken path at step "..tostring(steps)
        end
    end
end

function part2(turns, nodes)
    local function trace(here)
        for steps, _, turn in follow_turns(turns) do
            here = nodes[here[turn]]
            if here.key == 'Z' then
                return steps
            end
        end
    end

    local paths = {}
    for _,node in pairs(nodes) do
        if node.key == 'A' then
            paths[#paths+1] = trace(node)
            --print(node[1], paths[#paths], paths[#paths]/#turns)
        end
    end
    return math.tointeger(aoc.reduce(paths, aoc.lcm, 1))
end

-- main
aoc.run({part1, part2}, maps(io.stdin))
