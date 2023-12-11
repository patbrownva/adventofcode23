local aoc = require"adventofcode"

-- Directions of travel
Direction = {
    E = {1, 0},
    W = {-1, 0},
    N = {0, -1},
    S = {0, 1}
}

-- Transform direction of travel
Transform = {
    ['|'] = {S='S', N='N',
    sides = {S={O={{1,0}}, I={{-1,0}} },
             N={O={{-1,0}}, I={{1,0}} }
            }
    },
    ['-'] = {E='E', W='W',
    sides = {W={O={{0,1}}, I={{0,-1}} },
             E={O={{0,-1}}, I={{0,1}} }
            }
    },
    ['L'] = {S='E', W='N',
    sides = {S={O={}, I={{-1,0},{-1,1},{0,1}} },
             W={O={{-1,0},{-1,1},{0,1}}, I={} }
            }
    },
    ['J'] = {S='W', E='N',
    sides = {S={O={{1,0},{1,1},{0,1}}, I={} },
             E={O={}, I={{1,0},{1,1},{0,1}} }
            }
    },
    ['7'] = {N='W', E='S',
    sides = {N={O={}, I={{1,0},{1,-1},{0,-1}} },
             E={O={{1,0},{1,-1},{0,-1}}, I={} }
            }
    },
    ['F'] = {W='S', N='E',
    sides = {N={O={{-1,0},{-1,-1},{0,-1}}, I={} },
             W={O={}, I={{-1,0},{-1,-1},{0,-1}} }
            }
    }
}

-- Mark coverage
--[[
 .0. .~. .0. .0. .~~ ~~.
 ~|+ 0-0 ~L0 0J~ 07~ ~F0
 .0. .+. ~~. .~~ .0. .0.
]]

Map = {}
Coverage = {}

function read_map(input)
    local start
    local y = 1
    for line in input:lines() do
        Map[#Map+1] = aoc.findall(line, ".")
        local S = line:find('S')
        if S then
            start = {S, y}
        end
        Coverage[#Coverage+1] = {}
        y = y + 1
    end
    return start
end

function cover(at, what)
    local row = Coverage[at[2]]
    if row and at[1] <= #Map[at[2]] then
        if what and row[at[1]] ~= 'P' then
            row[at[1]] = what
        end
        return row[at[1]]
    end
    return nil
end

function get(at)
    local row = Map[at[2]]
    return row and row[at[1]]
end

function move(from, to)
    return {from[1]+to[1], from[2]+to[2]}
end

function mark(at, dir)
    cover(at, 'P') -- mark the pipe itself
    local pipe = get(at)
    local sides
    if pipe == 'S' then
        if dir == 'N' or dir == 'S' then
            sides = Transform['|'].sides[dir]
        else -- dir == 'W' or dir == 'E'
            sides = Transform['-'].sides[dir]
        end
    else
        sides = Transform[pipe].sides[dir]
    end
    for i = 1,#sides.I do
        cover(move(at, sides.I[i]), 'I')
    end
    for i = 1,#sides.O do
        cover(move(at, sides.O[i]), 'O')
    end
end

function pick_a_direction(start)
    for dir,step in pairs(Direction) do
        local pipe = get(move(start, step))
        if Transform[pipe] and Transform[pipe][dir] then
            return dir
        end
    end
    error"Can't go anywhere!"
end

function inside(start)
    if cover(start) == 'P' then
        return false
    end
    local row = Map[start[2]]
    local function _inside(at,dir)
        local count = false
        local pipe = get(at)
        while pipe do
            if pipe == 'S' then
                dir[1] = -dir[1]
                return _inside(move(start,dir), dir)
            end
            if cover(at) == 'P' then
                if pipe == '|' or pipe == 'F' or pipe == '7' then
                    count = not count
                end
            end
            at = move(at, dir)
            pipe = get(at)
        end
        return count
    end
    local dir
    if start[1] <= #row-start[1] then
        dir = {-1,0}
    else
        dir = {1,0}
    end
    return _inside(move(start,dir), dir)
end

local BORDER = {{-1,-1},{0,-1},{1,-1},{-1,0},{1,0},{-1,1},{0,1},{1,1}}
function fill(from)
    local what = cover(from)
    local atlist = {from}
    while #atlist > 0 do
        local at = atlist[#atlist]
        atlist[#atlist] = nil
        --print(at[1],at[2])
        for _,d in ipairs(BORDER) do
            local p = move(at,d)
            if not cover(p) then
                cover(p, what)
                atlist[#atlist+1] = p
            end
        end
    end
end

function step(start, dir, count)
    start = move(start, Direction[dir])
    mark(start, dir)
    local pipe = get(start)
    if pipe == 'S' then
        return count
    end
    return step(start, Transform[pipe][dir], count+1)
end

function pipemaze1(start)
    local dir = pick_a_direction(start)
    -- I don't believe it's possible for this to be odd
    -- but just in case
    mark(start, dir)
    return math.ceil(step(start, dir, 1) / 2)
end

function pipemaze2(start)
    pipemaze1(start)
    local inmark, top
    for y = 1,#Map do
        for x = 1,#Map[y] do
            if cover{x,y} == 'I' or cover{x,y} == 'O' then
                if inside{x,y} then
                    inmark = cover{x,y}
                    top = y
                    goto foundmark
                end
            end
        end
    end
    error"No marks found"
    ::foundmark::
    for y = top,#Map do
        for x = 1,#Map[y] do
            if cover{x,y} == inmark then
                fill({x,y})
            end
        end
    end
    local count = 0
    for y = 1,#Map do
      for x = 1,#Map[y] do
        if Coverage[y][x] == inmark then
            count = count + 1
        end
      end
    end
    return count
end

-- main 
do
    local start = read_map(io.stdin)
    print(pipemaze1(start))
    print(pipemaze2(start))
end
