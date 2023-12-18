local aoc = require"adventofcode"
local insert_sorted,remove_item,find_first,find_last =
      aoc.insert_sorted,aoc.remove_item,aoc.find_first,aoc.find_last
local insert,remove,unpack = table.insert,table.remove,table.unpack
local setmetatable = setmetatable
local substr = string.sub


function Grid(input)
    local grid = {}
    local width = 0
    for line in input:lines() do
        if line == "" then break end
        grid[#grid+1] = aoc.map(aoc.findall(line, "%d"), tonumber)
        if #line > width then
            width = #line
        end
    end
    grid.height = #grid
    grid.width = width
    return grid
end

local cost_mt = {
    __lt = function(a, b)
        if a[5]==b[5] then
            if a[1]==b[1] then
                if a[2]==b[2] then return a[3]<b[3] end
                return a[2]<b[2]
            end
            return a[1]<b[1]
        end
        return a[5]>b[5]
    end;
    __eq = function(a, b)
        return a[1]==b[1] and a[2]==b[2] and a[3]==b[3] and a[5]==b[5]
    end;
    __tostring = function(a)
        return string.format("{%d;%d%s%d=%d}", a[1],a[2],a[3],a[4],a[5])
    end
}
local function box(...)
    assert(select(5,...))
    return setmetatable({...}, cost_mt)
end
local unbox = table.unpack

local grid = Grid(io.input())

local function pathfind(do_step)
    local queue = {}
    local notvisited = {}
    local visited = {}
    local reversepath = {}
    for j = 1,grid.height do
        notvisited[j] = {}
        visited[j] = {}
        reversepath[j] = {}
        for i = 1,grid.width do
            notvisited[j][i] = {}
            visited[j][i] = {}
            reversepath[j][i] = {}
        end
    end
    local cur_step = 0
    local cur_row, cur_col, cur_dir, cur_cost

    local function remove_items(row, col, dir, cost)
        local item = box(row, col, dir, nil, cost)
        local i = find_last(queue, item)
        while i > 0 and queue[i] == item do
            remove(queue, i)
            i = i - 1
        end
        return i
    end
    
    local function add_queue(row, col, dir, cost, step)
        local i = insert_sorted(queue, box(row, col, dir, step, cost))
        notvisited[row][col][dir] = {cost,true}
    end

    local function remove_queue(row, col, dir)
        local cost = notvisited[row][col][dir][1]
        remove_item(queue, box(row, col, dir, nil, cost))
        notvisited[row][col][dir][2] = false
    end
    
    local function queue_pop()
        if #queue == 0 then
            return nil,nil
        end
        local row, col, dir, step, cost = unbox(queue[#queue])
        queue[#queue] = nil
        notvisited[row][col][dir][3] = false
        return row, col, dir, step, cost
    end
    
    local function queue_cost(row, col, dir, cost)
        if notvisited[row][col][dir] then
            return notvisited[row][col][dir][1] > cost
        end
        return false
    end
    
    local function in_queue(row, col, dir)
        return visited[row][col][dir] or
              (notvisited[row][col][dir] and notvisited[row][col][dir][2])
    end
    
    local function seen(row, col, dir, cost)
        visited[row][col][dir] = cost
    end
    
    local function notseen(row, col, dir)
        visited[row][col][dir] = nil
    end

    local function neighbor(row, col, dir, step, cost)
        if queue_cost(row, col, dir, cost) then
            remove_queue(row, col, dir)
        end
        if not in_queue(row, col, dir) then
            add_queue(row, col, dir, cost, step)
            reversepath[row][col][dir] = {cur_row,cur_col,cur_dir,cur_step}
        end
    end

    local function next_step()
        local row, col, dir, step, cost = queue_pop()
        if not row then error "empty queue" end
        cur_dir,cur_step = dir,step
        cur_row,cur_col,cur_cost = row,col,cost
    end

    cur_row,cur_col,cur_dir = 1,1,''
    cur_cost = 0
    while cur_row ~= grid.height or cur_col ~= grid.width do
        seen(cur_row, cur_col, cur_dir, cur_cost)
        do_step(neighbor, cur_row, cur_col, cur_dir, cur_step, cur_cost)
        next_step()
    end

    local path = {}
    for j = 1,grid.height do path[j]={} for i = 1,grid.width do
      path[j][i] = '.'
    end end
    --print(cur_row..';'..cur_col..cur_dir..cur_step)
    while cur_row ~= 1 or cur_col ~= 1 do
        --path[cur_row][cur_col] = '#'
        if cur_dir == 'N' then
            for row = cur_row,cur_row+cur_step do path[row][cur_col] = '^' end
        elseif cur_dir == 'S' then
            for row = cur_row,cur_row-cur_step,-1 do path[row][cur_col] = 'v' end
        elseif cur_dir == 'W' then
            for col = cur_col,cur_col+cur_step do path[cur_row][col] = '<' end
        elseif cur_dir == 'E' then
            for col = cur_col,cur_col-cur_step,-1 do path[cur_row][col] = '>' end
        end
        cur_row,cur_col,cur_dir,cur_step = unpack(reversepath[cur_row][cur_col][cur_dir])
        --print(cur_row..';'..cur_col..cur_dir..cur_step)
    end
    for j = 1,grid.height do print(table.concat(path[j])) end

    return cur_cost
end

local function part1(neighbor, cur_row, cur_col, cur_dir, cur_step, cur_cost)
    if cur_dir ~= 'N' then
        -- move down
        local step, stop, cost = 0,3,cur_cost
        if cur_dir == 'S' then
            step,stop = cur_step, 3 - cur_step
        end
        if cur_row+stop > grid.height then
            stop = grid.height - cur_row
        end
        for n = 1,stop do
            cost = cost + grid[cur_row+n][cur_col]
            neighbor(cur_row+n, cur_col, 'S', step+n, cost)
        end
    end
    if cur_dir ~= 'S' then
        -- move up
        local step, stop, cost = 0,3,cur_cost
        if cur_dir == 'N' then
            step,stop = cur_step, 3 - cur_step
        end
        if cur_row-stop < 1 then
            stop = cur_row - 1
        end
        for n = 1,stop do
            cost = cost + grid[cur_row-n][cur_col]
            neighbor(cur_row-n, cur_col, 'N', step+n, cost)
        end
    end
    if cur_dir ~= 'W' then
        -- move right
        local step, stop, cost = 0,3,cur_cost
        if cur_dir == 'E' then
            step,stop = cur_step, 3 - cur_step
        end
        if cur_col+stop > grid.width then
            stop = grid.width - cur_col
        end
        for n = 1,stop do
            cost = cost + grid[cur_row][cur_col+n]
            neighbor(cur_row, cur_col+n, 'E', step+n, cost)
        end
    end
    if cur_dir ~= 'E' and cur_col > 1 then
        -- move left
        local step, stop, cost = 0,3,cur_cost
        if cur_dir == 'W' then
            step,stop = cur_step, 3 - cur_step
        end
        if cur_col-stop < 1 then
            stop = cur_col - 1
        end
        for n = 1,stop do
            cost = cost + grid[cur_row][cur_col-n]
            neighbor(cur_row, cur_col-n, 'W', step+n, cost)
        end
    end
end

local function part2(neighbor, cur_row, cur_col, cur_dir, cur_step, cur_cost)
    if cur_dir ~= 'N' then
        -- move down
        local step, stop = 0,10
        if cur_dir == 'S' then
            step,stop = cur_step, 10 - cur_step
        end
        if cur_row+stop > grid.height then
            stop = grid.height - cur_row
        end
        local cost = cur_cost
        for n = 1,3 do
            if not grid[cur_row+n] then break end
            cost = cost + grid[cur_row+n][cur_col]
        end
        for n = 4,stop do
            cost = cost + grid[cur_row+n][cur_col]
            neighbor(cur_row+n, cur_col, 'S', step+n, cost)
        end
    end
    if cur_dir ~= 'S' then
        -- move up
        local step, stop = 0,10
        if cur_dir == 'N' then
            step,stop = cur_step, 10 - cur_step
        end
        if cur_row-stop < 1 then
            stop = cur_row - 1
        end
        local cost = cur_cost
        for n = 1,3 do
            if not grid[cur_row-n] then break end
            cost = cost + grid[cur_row-n][cur_col]
        end
        for n = 4,stop do
            cost = cost + grid[cur_row-n][cur_col]
            neighbor(cur_row-n, cur_col, 'N', step+n, cost)
        end
    end
    if cur_dir ~= 'W' then
        -- move right
        local step, stop = 0,10
        if cur_dir == 'E' then
            step,stop = cur_step, 10 - cur_step
        end
        if cur_col+stop > grid.width then
            stop = grid.width - cur_col
        end
        local cost = cur_cost
        for n = 1,3 do
            if not grid[cur_row][cur_col+n] then break end
            cost = cost + grid[cur_row][cur_col+n]
        end
        for n = 4,stop do
            cost = cost + grid[cur_row][cur_col+n]
            neighbor(cur_row, cur_col+n, 'E', step+n, cost)
        end
    end
    if cur_dir ~= 'E' and cur_col > 1 then
        -- move left
        local step, stop = 0,10
        if cur_dir == 'W' then
            step,stop = cur_step, 10 - cur_step
        end
        if cur_col-stop < 1 then
            stop = cur_col - 1
        end
        local cost = cur_cost
        for n = 1,3 do
            if not grid[cur_row][cur_col-n] then break end
            cost = cost + grid[cur_row][cur_col-n]
        end
        for n = 4,stop do
            cost = cost + grid[cur_row][cur_col-n]
            neighbor(cur_row, cur_col-n, 'W', step+n, cost)
        end
    end
end

-- main
print(pathfind(part1))
print(pathfind(part2))
