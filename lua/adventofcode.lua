local ipairs,pairs,getmetatable,setmetatable = ipairs,pairs,getmetatable,setmetatable
local substr,insert,remove = string.sub,table.insert,table.remove

local M = {}

local function gcd(m, n)
    if n == 0 then
        return m
    end
    return gcd(n, m % n)
end
M.gcd = gcd

M.lcm = function (m, n)
    return (m~=0 and n~=0) and m*n/gcd(m,n) or 0
end

M.sum = function (a, b)
    return (a or 0) + (b or 0)
end

M.reduce = function (T, F, R)
    for _,v in pairs(T) do
        R = F(R, v)
    end
    return R
end

M.freduce = function (F, ...)
    local function func (a, b, ...)
        if b then return func(F(a,b), ...)
        else return a end
    end
    return func(...)
end

M.map = function (T, F)
    local R = {}
    for k,v in pairs(T) do
        R[k] = F(v)
    end
    return R
end

M.index = function (T, V)
    for k,v in pairs(T) do
        if v == V then return k end
    end
    return nil
end

M.extend = function (T, E)
    local i = #T + 1
    for _,v in ipairs(E) do
        T[i] = v
        i = i + 1
    end
end

M.findall = function (S, pat)
    local R = {}
    for M in string.gmatch(S, pat) do
        R[#R+1] = M
    end
    return R
end

M.intersect = function (A, B)
    local S = {}
    for _, I in ipairs(A) do
        S[I] = true
    end
    local R = {}
    for _, I in ipairs(B) do
        R[#R+1] = S[I] and I
    end
    return R
end

M.union = function (A, B)
    if #B > #A then
        A,B = B,A
    end
    local S = {}
    local R = {}
    for _,I in ipairs(A) do
        S[I] = true
        R[#R+1] = I
    end
    for _,I in ipairs(B) do
        if not S[I] then
            R[#R+1] = I
        end
    end
    return R
end

M.difference = function (A, B)
    local S = {}
    local R = {}
    for _,I in ipairs(B) do
        S[I] = true
    end
    for _,I in ipairs(A) do
        if not S[I] then
            R[#R+1] = I
        end
    end
    return R
end

local function find_first(T, search)
    local before, after, part, dir = 1, #T, 0, 0
    while before <= after do
        part = (after + before) // 2
        if T[part] == search then
            while part > before and T[part-1] == search do
                part = part - 1
            end
            return part
        elseif T[part] < search then
            before,dir = part + 1, 0
        else
            after,dir = part - 1, -1
        end
    end
    return part + dir
end

local function find_last(T, search)
    local before, after, part, dir = 1, #T, 0, 0
    while before <= after do
        part = (after + before) // 2
        if T[part] == search then
            while part < after and T[part+1] == search do
                part = part + 1
            end
            return part
        elseif T[part] < search then
            before,dir = part + 1, 0
        else
            after,dir = part - 1, -1
        end
    end
    return part + dir
end

M.find_first = find_first
M.find_last = find_last

M.insert_sorted = function (T, e)
    local pos = find_last(T, e) + 1
    insert(T, pos, e)
    return pos
end

M.remove_item = function (T, e)
    local pos = find_first(T, e)
    if pos > 0 and T[pos] == e then
        remove(T, pos)
    end
end

M.run_reduce_sum = function (stages, ...)
    local stage = stages[tonumber(arg[1]) or 1]
    local lines = {}
    for line in io.lines() do
        lines[#lines+1] = stage(line, ...)
    end
    print(M.reduce(lines, M.sum, 0))
end

M.run = function (stages, ...)
    local stage = stages[tonumber(arg[1]) or 1]
    print(stage(...))
end

-- Point and Grid

local point_mt
local Point = function (x, y)
    if y == nil then
        x, y = x[1] or x.x, x[2] or x.y
    end
    return setmetatable({x=(x or 0), y=(y or 0)}, point_mt)
end

local point_field = { "x", "y", x="x", y="y", row="y", col="x", i="x", j="y", width="x", height="y" }
point_mt = {
    __index = function (this, name)
        return rawget(this, point_field[name])
    end;
    __eq = function (this, val)
        return this.x==val.x and this.y==val.y
    end;
    __lt = function (this, val)
        return this.x<val.x or (this.x==val.x and this.y<val.y)
    end;
    __le = function (this, val)
        return this.x<val.x or (this.x==val.x and this.y<=val.y)
    end;
    __add = function (this, val)
        return Point(this.x+val.x, this.y+val.y)
    end;
    __sub = function (this, val)
        return Point(this.x-val.x, this.y-val.y)
    end;
    __bnot = function (this)
        return this.x==0 and this.y==0
    end;
    __tostring = function (this)
        return string.format("Point(%q, %q)", this.x, this.y)
    end;
}

M.Point = Point

local grid_mt = {}

local function grid_ix (this, pt)
    local x,y = pt[1] or pt.x, pt[2] or pt.y
    if x < 1 or x > this.width or y < 1 or y > this.height then
        return nil
    end
    return x + this.width*(y-1)
end

local function grid_pt (this, ix)
    local y = (ix-1) // this.width
    local x = ix - y*this.width
    return x, y+1
end

grid_mt.__index = function (this, pt)
    if grid_mt[pt] then
        return grid_mt[pt]
    end
    local ix = grid_ix(this, pt)
    return ix and substr(this.grid, ix,ix)
    --local row = this.grid[y]
    --return row and row[x]
end

grid_mt.next = function (this, pos)
    if pos then
        local y, x = pos.y, pos.x + 1
        if x > this.width then
            x, y = 1, y + 1
        end
        pos = Point(x, y)
    else
        pos = Point(1, 1)
    end
    --if pos.y < 1 or pos.y > this.height or pos.x < 1 or pos.x > this.width then
    local ix = grid_ix(this, pos)
    if not ix then return nil end
    return pos, substr(this.grid, ix,ix)
    --return pos, this.grid[pos.y][pos.x]
end

grid_mt.each = function (this)
    return grid_mt.next, this
end

grid_mt.find = function (this, pat, start, plain)
    local ix = start and grid_ix(this, start) or 1
    if not ix then return nil end
    local x, y
    local start_ix, stop_ix = string.find(this.grid, pat, ix, plain)
    while start_ix do
        x, y = grid_pt(this, start_ix)
        if stop_ix - start_ix + x <= this.width then
            break
        end
        start_ix, stop_ix = string.find(this.grid, pat, start_ix+1, plain)
    end
    if not start_ix then return nil end
    return Point(x, y), Point(grid_pt(this, stop_ix))
end

M.Grid = function (input)
    local rows = {}
    local width = 0
    for line in input:lines() do
        if line == "" then break end
        rows[#rows+1] = line
        if #line > width then
            width = #line
        end
    end
    return setmetatable({grid=table.concat(rows), height=#rows, width=width}, grid_mt)
end

return M
