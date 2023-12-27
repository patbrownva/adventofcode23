local aoc = require"adventofcode"
local insert_sorted = aoc.insert_sorted
local unpack,insert,remove = table.unpack,table.insert,table.remove
local ipairs,pairs = ipairs,pairs

local Graph = {nodes={}, edges={}}

local function cut(n1, n2)
    if n1 > n2 then
        n1,n2 = n2,n1
    end
    edge = Graph.edges[n1.."--"..n2]
    if edge then
        Graph.edges[edge][3] = true
    end
end

local function splice(n1, n2, edge)
    if n1 > n2 then
        n1,n2 = n2,n1
    end
    edge = Graph.edges[n1.."--"..n2]
    if edge then
        Graph.edges[edge][3] = false
    end
end

local function link(n1, n2)
    if n1 > n2 then
        n1,n2 = n2,n1
    end
    edge = Graph.edges[n1.."--"..n2]
    if not edge then
        edge = #Graph.edges+1
        Graph.edges[edge] = {n1,n2,false}
    else
        if Graph.edges[edge][1] ~= n1 or Graph.edges[edge][2] ~= n2 then
            error (string.format("link(%s,%s)", n1,n2))
        end
        Graph.edges[edge][3] = false
    end
    Graph.edges[n1.."--"..n2] = edge

    local node = Graph.nodes[n1] or {}
    node[#node+1] = edge
    Graph.nodes[n1] = node
    node = Graph.nodes[n2] or {}
    node[#node+1] = edge
    Graph.nodes[n2] = node
end

local function read(lines)
    for line in lines() do
        local lname, right = unpack(aoc.split(line, ":"))
        if lname and right then
            for _,rname in ipairs(aoc.findall(right, "%a+")) do
                link(lname,rname)
            end
        end
    end
end

local function otherend(node, edgenum)
    if edgenum <= 0 or edgenum > #Graph.edges then
        return nil
    end
    local edge = Graph.edges[edgenum]
    if edge[3] then -- was cut
        return nil
    end
    if edge[1] == node then
        return edge[2]
    elseif edge[2] == node then
        return edge[1]
    else
        error (string.format("othernode(%s,%d) = {%s,%s}",node,edgenum,edge[1],edge[2]))
        return nil
    end
end

local path_mt = {
    __lt = function (a, b)
        if a[2] == b[2] then return a[1] < b[1] end
        return a[2] > b[2]
    end;
    __eq = function (a, b)
        return a[1] == b[1] and a[2] == b[2]
    end;
    __tostring = function (a)
        return string.format("{%s=%d}", a[1], a[2])
    end;
}
local function box(node, step, ...)
    return setmetatable({node,step, ...}, path_mt)
end

local function shortestpath(start, goal)
    local queue = {}
    local notvisited = {}
    local visited = {}
    local curstep,curnode

    local function add_queue(node, step)
        local item = box(node, step)
        insert_sorted(queue, item)
        notvisited[node] = item
    end
    
    local function remove_queue(node)
        if notvisited[node] then
            remove_item(queue, item)
            notvisited[node] = nil
        end
    end
    
    local function queue_pop()
        local item = queue[#queue]
        queue[#queue] = nil
        notvisited[item[1]] = nil
        return unpack(item)
    end

    local function queue_cost(node, step)
        if notvisited[node] then
            return notvisited[node][2] > step
        end
        return false
    end
    
    local function in_queue(node)
        return visited[node] or notvisited[node]
    end

    curstep = 0
    curnode = start
    while curnode ~= goal do
        visited[curnode] = curstep
        -- do step
        local step = curstep + 1
        for _,edgenum in ipairs(Graph.nodes[curnode]) do
            local nextnode = otherend(curnode, edgenum)
            if nextnode then
                if queue_cost(step) then
                    remove_queue(nextnode)
                end
                if not in_queue(nextnode) then
                    add_queue(nextnode, step)
                end
            end
        end
        -- next step
        curnode,curstep = queue_pop()
    end
    
    return curstep
end

local function countnodes(start)
    local count = 0
    local visited = {}
    local notvisited = {start}

    while #notvisited > 0 do
        local node = remove(notvisited)
        if not visited[node] then
            visited[node] = true
            count = count + 1
            for _,edgenum in ipairs(Graph.nodes[node]) do
                local nextnode = otherend(node, edgenum)
                if nextnode then
                    if not visited[nextnode] then
                        insert(notvisited, nextnode)
                    end
                end
            end
        end
    end
    return count
end

-- main
read(io.lines)

-- print("graph snowverload {")
-- print("shape=circle;")
-- for _,edge in ipairs(Graph.edges) do
--     print(edge[1].." -- "..edge[2]..";")
-- end
-- print("}")

local criticallinks = {}
local criticaldepth = 0
for edgenum,edge in ipairs(Graph.edges) do
    local n1, n2 = unpack(edge)
    cut(n1, n2)
    local step = shortestpath(n1, n2)
    splice(n1, n2)
    insert_sorted(criticallinks, box(edgenum, step, edge))
end
local leftnode,rightnode
for ix = 1,3 do
    local edgenum, step, edge = unpack(criticallinks[ix])
    leftnode,rightnode = unpack(edge)
    print(leftnode.."--"..rightnode)
    cut(leftnode, rightnode)
end
local leftnum,rightnum = countnodes(leftnode), countnodes(rightnode)
print(leftnum,rightnum,leftnum*rightnum)
