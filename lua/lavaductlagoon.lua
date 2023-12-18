local aoc = require"adventofcode"
local ipairs,unpack,sort = ipairs,table.unpack,table.sort
local abs,min,max,substr = math.abs,math.min,math.max,string.sub

local Endpoint = {
    R = function(i,j,n) return i+n,j end;
    L = function(i,j,n) return i-n,j end;
    U = function(i,j,n) return i,j-n end;
    D = function(i,j,n) return i,j+n end;
}
local Hexcode = { ['0']='R', ['1']='D', ['2']='L', ['3']='U' }

local Plan = {}
local Plot = {}

local function read_plan1(input)
    for line in input:lines() do
        local dir,len = line:match("([UDLR]) (%d+)")
        if dir then
            Plan[#Plan+1] = {dir, tonumber(len)}
        end
    end
end

local function read_plan2(input)
    for line in input:lines() do
        local color = line:match("%(#([0-9a-f]+)%)")
        if color then
            Plan[#Plan+1] = {Hexcode[substr(color, -1)],
                             tonumber(substr(color, 1,-2), 16)}
        end
    end
end

local function dig_plot()
    local col,row = 1,1
    local mini,maxi,minj,maxj = 1,1,1,1

    Plot[#Plot+1] = {1,1}
    for _,line in ipairs(Plan) do
        local dir,len = unpack(line)
        first_dir = first_dir or dir
        local i,j = Endpoint[dir](col, row, len)
        Plot[#Plot+1] = {i, j}
        mini = min(mini, i)
        minj = min(minj, j)
        maxi = max(maxi, i)
        maxj = max(maxj, j)
        col,row = i,j
    end

    if Plot[#Plot][1] ~= 1 or Plot[#Plot][2] ~= 1 then
        Plot[#Plot+1] = {1,1}
    end

    --[[
    local addi, addj = 1-mini, 1-minj
    if addi ~= 0 or addj ~= 0 then
        for _, point in ipairs(Plot) do
            point[1] = point[1] + addi
            point[2] = point[2] + addj
        end
    end
    --]]
    Plot.width = maxi - mini + 1
    Plot.height = maxj - minj + 1
end

local function cross_product()
    local area = 0
    local perim = 0
    for n = 1,#Plot-1 do
        local i1,j1 = unpack(Plot[n])
        local i2,j2 = unpack(Plot[n+1])
        area = area + (i1*j2 - i2*j1)
        perim = perim + abs(i2-i1) + abs(j2-j1)
    end
    return math.tointeger((abs(area) + perim) // 2 + 1)
end

function lagoon1(input)
    read_plan1(input)
    dig_plot()
    return cross_product()
end

function lagoon2(input)
    read_plan2(input)
    dig_plot()
    return cross_product()
end

-- main 
aoc.run({lagoon1, lagoon2}, io.input())
