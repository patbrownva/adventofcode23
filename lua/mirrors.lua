
local concat = table.concat
local substr = string.sub

function read_grid(input)
    local line = input:read()
    while line == "" do
        line = input:read()
    end
    if not line then return nil end
    local grid = {}
    local width = 0
    while line do
        if line == "" then break end
        grid[#grid+1] = line
        if #line > width then
            width = #line
        end
        line = input:read()
    end
    grid.w = width
    grid.h = #grid
    return grid
end

function transpose(grid)
    local newgrid = {w=grid.h, h=grid.w}
    for i = 1,grid.w do
        local row = {}
        for j = 1,grid.h do
            row[#row+1] = substr(grid[j], i,i)
        end
        newgrid[i] = concat(row)
    end
    return newgrid
end

function reflect(grid, row)
    local top = {}
    local bottom = {}
    local n,m = row, row + 1
    while grid[n] and grid[m] do
        top[#top+1] = grid[n]
        bottom[#bottom+1] = grid[m]
        n,m = n - 1, m + 1
    end
    return concat(top), concat(bottom)
end

function mismatch(target, left, right)
    --print(left)
    --print(right)
    --[[ Not worth doing this because lines are always same width
    local count = #right - #left
    if count < 0 then
        right,left,count = left,right,-count
    end
    if count > target then
        return false
    end
    --]]
    local count = 0
    for n = 1,#left do
        if substr(left, n,n) ~= substr(right, n,n) then
            count = count + 1
            if count > target then
                return false
            end
        end
    end
    --print("="..tostring(count))
    return count
end

function mirrors(grid, n)
    local set = {}
    for row = 1,grid.h-1 do
        --print("?"..tostring(row))
        local m = mismatch(n, reflect(grid, row))
        if m == n then
            set[row] = m
        end
    end
    return set
end

function score(grid, n)
    local horizontal = mirrors(grid, n)
    local vertical = mirrors(transpose(grid), n)
    --print((next(horizontal)), (next(vertical)))
    return (next(horizontal) or 0) * 100 + (next(vertical) or 0)
end

function main()
    local score0,score1 = 0,0
    for grid in read_grid,io.input() do
        score0 = score0 + score(grid, 0)
        score1 = score1 + score(grid, 1)
    end
    print(score0)
    print(score1)
end

main()
