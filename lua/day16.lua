local aoc = require"adventofcode"
local Point,Grid = aoc.Point,aoc.Grid
local format,remove,extend = string.format,table.remove,aoc.extend

local Directions = {
    N = Point(0,-1);
    S = Point(0,1);
    W = Point(-1,0);
    E = Point(1,0);
}

local Reflections = {
    ['/'] = function (out)
                return {N={out.E}, S={out.W}, W={out.S}, E={out.N}}
            end;
   ['\\'] = function (out)
                return {N={out.W}, S={out.E}, W={out.N}, E={out.S}}
            end;
    ['|'] = function (out)
                local refl = {N={out.N}, S={out.S}, W={out.N,out.S}}
                refl.E = refl.W
                return refl
            end;
    ['-'] = function (out)
                local refl = {W={out.W}, E={out.E}, N={out.W,out.E}}
                refl.S = refl.N
                return refl
            end;
}

function analyze(grid)

    local function measure(start, dir)
        local steps = 0
        local stop = start
        local delta = Directions[dir]
        local mark = grid[stop+delta]
        while mark do
            steps = steps + 1
            stop = stop + delta
            if mark ~= '.' then
                break
            end
            mark = grid[stop+delta]
        end
        local beam = format("X%dY%d%s%d", start.x, start.y, dir, steps)
        return {beam, stop, dir}
    end

    local function make_beams(mirror, start)
        local out = {
            N = measure(start, 'N');
            S = measure(start, 'S');
            W = measure(start, 'W');
            E = measure(start, 'E');
        }
        return Reflections[mirror](out)
    end

    local beams = {}
    for j = 1,grid.height do
        beams[j] = {}
    end
    local found = grid:find("[/\\|-]")
    while found do
        local mirror = grid[found]
        beams[found.row][found.col] = make_beams(mirror, found)
        found = grid:next(found)
        if found then
            found = grid:find("[/\\|-]", found)
        end
    end

    local paths = {height=grid.height, width=grid.width}
    function trace(reflection, start)
        for i = #reflection,1,-1 do
            local beam = reflection[i]
            local key = beam[1]
            if not paths[key] then
                local stop = beam[2]
                if stop ~= start then
                    local dir = beam[3]
                    local mirror = beams[stop.j][stop.i]
                    if mirror then
                        bounce = mirror[dir]
                        paths[key] = {key, start, stop, bounce}
                        trace(bounce, stop)
                    else
                        paths[key] = {key, start, stop, {}}
                    end
                end
            end
            if not paths[key] then
                remove(reflection, i)
            else
                reflection[i] = paths[key]
            end
        end
    end

    for j = 1,grid.height do
        local reflection
        local entry = Point(1,j)
        local key = "Y"..j.."+"
        if not beams[j][1] then
            local beam = measure(entry, 'E')
            beam[1] = key
            reflection = {beam}
        else
            reflection = beams[j][1].E
            paths[key] = {key, entry, entry, reflection}
        end
        trace(reflection, entry)

        local key = "Y"..j.."-"
        entry = Point(grid.width,j)
        if not beams[j][grid.width] then
            local beam = measure(entry, 'W')
            beam[1] = key
            reflection = {beam}
        else
            reflection = beams[j][grid.width].W
            paths[key] = {key, entry, entry, reflection}
        end
        trace(reflection, entry)
    end
    for i = 1,grid.width do
        local reflection
        local entry = Point(i,1)
        local key = "X"..i.."+"
        if not beams[1][i] then
            local beam = measure(entry, 'S')
            beam[1] = key
            reflection = {beam}
        else
            reflection = beams[1][i].S
            paths[key] = {key, entry, entry, reflection}
        end
        trace(reflection, entry)

        local key = "X"..i.."-"
        entry = Point(i, grid.height)
        if not beams[grid.height][i] then
            local beam = measure(entry, 'N')
            beam[1] = key
            reflection = {beam}
        else
            reflection = beams[grid.height][i].N
            paths[key] = {key, entry, entry, reflection}
        end
        trace(reflection, entry)
    end

    return paths
end

function energize(paths, key)
    local points = {}
    local active = {}
    local beams = {}
    if not paths[key] then return nil end
    beams[1] = paths[key]
    while #beams > 0 do
        local beam = remove(beams)
        if not active[beam[1]] then
            extend(beams, beam[4])
            active[beam[1]] = true

            local start,stop = beam[2],beam[3]
            if start.col > stop.col then
                start,stop = stop,start
            end
            for i = start.col,stop.col do
                points[format("%d,%d", i, start.row)] = true
            end
            if start.row > stop.row then
                start,stop = stop,start
            end
            for j = start.row,stop.row do
                points[format("%d,%d", start.col, j)] = true
            end
        end
    end

    local energized = {}
    for key,_ in pairs(points) do
        energized[#energized+1] = key
    end
    return energized
end

-- main
local grid = Grid(io.input())
local paths = analyze(grid)
print(#energize(paths, "Y1+"))

local most = 0
for j=1,grid.height do
    local m = #energize(paths, 'Y'..j..'+')
    if m > most then most = m end
    m = #energize(paths, 'Y'..j..'-')
    if m > most then most = m end
end
for i=1,grid.width do
    local m = #energize(paths, 'X'..i..'+')
    if m > most then most = m end
    m = #energize(paths, 'X'..i..'-')
    if m > most then most = m end
end
print(most)
