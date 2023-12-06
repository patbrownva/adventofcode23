local aoc = require"adventofcode"

function input_seeds(file)
    local seeds
    line = file:read()
    while line do
        if line:match("seeds:") then
            seeds = aoc.map(aoc.findall(line, "%d+"), tonumber)
            break
        end
        line = file:read()
    end
    return seeds
end

function input_map(file)
    local map, name = {}
    line = file:read()
    while line do
        name = line:match("([%S]+) map:")
        if name then
            break
        end
        line = file:read()
    end
    if not name then
        return nil
    end
    line = file:read()
    while line do
        if line == "" then
            break
        end
        local dst, src, len = line:match("(%d+) (%d+) (%d+)")
        map[#map+1] = {dst = tonumber(dst), src = tonumber(src), n = tonumber(len)}
        line = file:read()
    end
    return name, map
end

local function split_map_range(range, len)
    if len > 0 and len < range.n then
        local left = {dst = range.dst, src = range.src, n = len}
        local right = {dst = range.dst+len, src = range.src+len, n = range.n-len}
        --print(string.format("{%d,%d,%d}->{%d+%d}/{%d+%d}",
        --      range.src,range.dst,range.n,left.src,left.n,right.src,right.n))
        return left,right
    end
    return range
end

function map_sort_dst(map)
    table.sort(map, function(i,j) return i.dst < j.dst end)
end

function map_sort_src(map)
    table.sort(map, function(i,j) return i.src < j.src end)
end

function merge_map(left, right)
    map_sort_dst(left)
    map_sort_src(right)
    local merged = {}
    local lr, next = left[1], 2
    for _,rr in ipairs(right) do
        while lr and rr.src+rr.n > lr.dst do
            -- Left side is behind or overlapping right
            if lr.dst+lr.n <= rr.src then
                -- Left range completely behind right side, catch up
                merged[#merged+1] = lr
                lr, next = left[next], next+1
            else
                -- Left and right overlap, transform them
                if lr.dst < rr.src then
                    -- Leading left
                    local sp
                    sp, lr = split_map_range(lr, rr.src-lr.dst)
                    merged[#merged+1] = sp
                end
                if rr.src < lr.dst then
                    -- Leading right
                    local sp
                    sp, rr = split_map_range(rr, lr.dst-rr.src)
                    merged[#merged+1] = sp
                end
                assert(lr.dst == rr.src)
                if lr.n < rr.n then
                    local sp
                    sp, rr = split_map_range(rr, lr.n)
                    sp.src = lr.src
                    merged[#merged+1] = sp
                    lr, next = left[next], next+1
                else
                    local sp
                    sp, lr = split_map_range(lr, rr.n)
                    sp.dst = rr.dst
                    merged[#merged+1] = sp
                    if not lr then
                        lr, next = left[next], next+1
                    end
                    rr = nil
                    break
                end
            end
        end
        if rr and (not lr or rr.src+rr.n <= lr.dst) then
            -- Left range completely in front of right side, pass through
            merged[#merged+1] = rr
        end
    end
    while lr do
        -- Remaining left side ranges
        merged[#merged+1] = lr
        lr, next = left[next], next+1
    end
    return merged
end

function lookup(map, value)
    for _,range in ipairs(map) do
        if value >= range.src and value < range.src+range.n then
            return value + range.dst - range.src
        end
    end
    return value
end

function input_almanac(file)
    local seeds = input_seeds(file)
    local maps = {}
    for name, map in input_map,file do
        maps[name] = map
    end
    local seed_map = maps['seed-to-soil']
    local map_name = 'soil'
    for _,name in ipairs{'fertilizer'
    ,'water'
    ,'light'
    ,'temperature'
    ,'humidity'
    ,'location'
    } do
        --print(map_name,name)
        seed_map = merge_map(seed_map, maps[map_name..'-to-'..name])
        map_name = name
    end
    return seeds, seed_map
end

function part1(seeds, seed_map)
    local location = math.huge
    for _,s in ipairs(seeds) do
        local l = lookup(seed_map, s)
        if l < location then location = l end
    end
    return location
end

local function overlap(left,right)
    return left[1] < right[2] and right[1] < left[2]
end

function part2(seeds, seed_map)
    local seed_ranges = {}
    for i = 1,#seeds-1,2 do
        seed_ranges[#seed_ranges+1] = {seeds[i], seeds[i]+seeds[i+1]}
    end
    map_sort_dst(seed_map)
    for _,loc in ipairs(seed_map) do
        local l = {loc.src, loc.src+loc.n}
        for _,r in ipairs(seed_ranges) do
            if overlap(l, r) then
                if l[1] > r[1] then
                    return loc.dst
                else
                    return loc.dst + r[1] - l[1]
                end
            end
        end
    end
end

-- main
local stage = part1
if arg[1] == '2' then stage = part2 end
local seeds, seed_map = input_almanac(io.stdin)
print(stage(seeds, seed_map))

