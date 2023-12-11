local aoc = require"adventofcode"

all_galaxies = {}
all_space = {}
universe_size = {w=0, h=0}
big_bang = nil

function Galaxy(r,c)
    local p = {'#', row=r, col=c, h=1, w=1}
    all_galaxies[#all_galaxies+1] = p
    return p
end

function Space(r,c)
    local p = {'.', row=r, col=c, h=1, w=1}
    all_space[#all_space+1] = p
    return p
end

function link_right(left, right)
    if left then
        if left.r then -- for inserts
            link_right(right, left.r)
        end
        left.r = right
        right.l = left
    end
end

function link_down(up, down)
    if up then
        if up.d then -- for inserts
            link_down(down, up.d)
        end
        up.d = down
        down.u = up
    end
end

function read_chart(input)
    local origin
    local row = 1
    for line in input:lines() do
        local prev = nil
        local above = origin
        for col = 1,#line do
            local cel
            if line:sub(col,col) == '#' then
                cel = Galaxy(row,col)
            else
                cel = Space(row,col)
            end
            if above then
                link_down(above, cel)
                above = above.r
            end
            link_right(prev, cel)
            prev = cel
            if not big_bang then
                big_bang = cel
            end
        end
        origin = origin and origin.d or big_bang
        universe_size.w = #line
        universe_size.h = row
        row = row + 1
    end
end

function expand(age)
    local row = big_bang
    -- rows
    while row do
        local empty = true
        local col = row
        while col and empty do
            if col[1] == '#' then
                empty = false
            end
            col = col.r
        end
        if empty then
            col = row
            while col do
                col.h = col.h + age
                col = col.r
            end
        end
        row = row.d
    end
    local col = big_bang
    -- columns
    while col do
        local empty = true
        local row = col
        while row and empty do
            if row[1] == '#' then
                empty = false
            end
            row = row.d
        end
        if empty then
            row = col
            while row do
                row.w = row.w + age
                row = row.d
            end
        end
        col = col.r
    end
end

function pathfind()
    local paths = {}
    for i = 1, #all_galaxies do
        for j = i+1, #all_galaxies do
            local f, g = all_galaxies[i], all_galaxies[j]
            local cel, dir, dv, dh
            local distance = 0
            -- vertical
            dv = g.row - f.row
            dir = 'd'
            if dv < 0 then
                dv, dir = -dv, 'u'
            else
                distance = distance + f.h - 1
            end
            cel = f[dir]
            for col = 1,dv do
                distance = distance + cel.h
                cel = cel[dir]
            end
            -- horizontal
            dh = g.col - f.col
            dir = 'r'
            if dh < 0 then
                dh, dir = -dh, 'l'
            else
                distance = distance + f.w - 1
            end
            cel = f[dir]
            for row = 1,dh do
                distance = distance + cel.w
                cel = cel[dir]
            end
            -- make line
            paths[#paths+1] = distance
        end
    end
    return aoc.reduce(paths, aoc.sum)
end

function part1(input)
    read_chart(io.stdin)
    expand(1)
    return pathfind()
end

function part2(input)
    read_chart(io.stdin)
    expand(999999)
    return pathfind()
end

-- main
aoc.run({part1, part2}, io.stdin)

