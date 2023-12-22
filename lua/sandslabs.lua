local min,max = math.min,math.max
local insert,remove,sort = table.insert,table.remove,table.sort
local ipairs,pairs,tonumber = ipairs,pairs,tonumber

Columns = {}
Blocks = {}
Height = 0
xDim, yDim = 0, 0

local debug = false

function printblock(block, pre)
    if not debug then return end
    pre = pre or ''
    local above,below = {},{}
    for ix,_ in pairs(block.above) do above[#above+1] = ix end
    for ix,_ in pairs(block.below) do below[#below+1] = ix end
    print(string.format("%s%d,%d,%d~%d,%d,%d %s %s", pre,
        block[1].x,block[1].y,block[1].z,
        block[2].x,block[2].y,block[2].z,
        '^'..table.concat(above,'^'),
        'v'..table.concat(below,'v'))
        )
end

local function addblock(end1, end2)
    if end1.z > end2.z then
        end1,end2 = end2,end1
    end
    insert(Blocks, {
        end1, end2,
        above={}, below={}
    })
    Height = max(Height, end2.z)
    xDim = max(xDim, end1.x, end2.x)
    yDim = max(yDim, end1.y, end2.y)
end

local function xyz(line)
    local x,y,z = line:match("(%d+),(%d+),(%d+)")
    return {x=tonumber(x), y=tonumber(y), z=tonumber(z)}
end

function readblocks(input)
    for line in input() do
        local end1, end2 = line:match("(.+)~(.+)")
        if end1 then
            addblock(xyz(end1), xyz(end2))
        end
    end
end

local function blocksort(i, j)
    if i[1].z == j[1].z then
        return i[2].z < j[2].z
    end
    return i[1].z < j[1].z
end

-- This sorts in reverse order
local function indexsort(i, j)
    return blocksort(Blocks[j], Blocks[i])
end

function compactblocks()
    sort(Blocks, blocksort)
    for x = 0,xDim do
        Columns[x] = {}
        for y = 0,yDim do
            Columns[x][y] = {floor=0}
        end
    end
    for ix, block in ipairs(Blocks) do
        local altitude = 0
        for x = min(block[1].x,block[2].x), max(block[1].x,block[2].x) do
        for y = min(block[1].y,block[2].y), max(block[1].y,block[2].y) do
            altitude = max(altitude, Columns[x][y].floor)
        end end
        altitude = altitude + 1
        block[2].z = altitude + (block[2].z - block[1].z)
        block[1].z = altitude
        for x = min(block[1].x,block[2].x), max(block[1].x,block[2].x) do
        for y = min(block[1].y,block[2].y), max(block[1].y,block[2].y) do
            insert(Columns[x][y], ix)
            Columns[x][y].floor = block[2].z
        end end
    end

    for x = 0,xDim do for y = 0,yDim do
        for ci = #Columns[x][y],2,-1 do
            local ix = Columns[x][y][ci]
            local block = Blocks[ix]
            local altitude = block[1].z - 1
            local pt = {x,y}
            for cz = ci-1,1,-1 do
                local zx = Columns[x][y][cz]
                local under = Blocks[zx]
                if under[2].z == altitude then
                    block.below[zx] = pt
                    under.above[ix] = pt
                elseif under[2].z < altitude then
                    break
                end
            end
        end
    end end
end

local function supported(bx, removed)
    local block = Blocks[bx]
    for cx,_ in pairs(block.below) do
        if not removed[cx] then
            return true
        end
    end
    return false
end

function willnotfall()
    local breakable = 0
    for ix, block in ipairs(Blocks) do
        local canfall = true
        for zx,_ in pairs(block.above) do
            if not supported(zx, {[ix]=true}) then
                canfall = false
                break
            end
        end
        if canfall then
            breakable = breakable + 1
        end
    end
    
    print("will not fall", breakable)
end

function removeblock(bx)
    local removed = {}
    local sweep = {bx}
    count = 0
    while #sweep > 0 do
        local ix = remove(sweep)
        if (not removed[ix] and not supported(ix, removed)) or ix == bx then
            removed[ix] = true
            count = count + 1
            for zx,_ in pairs(Blocks[ix].above) do
                if not removed[zx] then
                    insert(sweep, zx)
                end
            end
            sort(sweep, indexsort)
        end
    end

    return count
end

function willfall()
    local dpkg_deb = 0
    for ix,block in ipairs(Blocks) do
        dpkg_deb = dpkg_deb + removeblock(ix) - 1
    end
    print("will fall", dpkg_deb)
end

readblocks(io.lines)
compactblocks()
willnotfall()
willfall()
