local aoc = require"adventofcode"
local concat,insert,remove = table.concat,table.insert,table.remove

function count_diagram(diagram)
    local counts = aoc.map(aoc.findall(diagram, "#+"), string.len)
    return concat(counts, ',')
end

function fill_blanks(diagram, match)
    local filled = 0
    local function _fill(row)
        local blank = row:find('?')
        if not blank then
            if count_diagram(row) == match then
                filled = filled + 1
            end
        else
            _fill(row:sub(1,blank-1)..'#'..row:sub(blank+1))
            _fill(row:sub(1,blank-1)..'.'..row:sub(blank+1))
        end
    end
    _fill(diagram)
    return filled
end

function hotsprings1(line)
    local diagram, pattern = line:match("([?.#]+) ([%d,]+)")
    return fill_blanks(diagram, pattern)
end

-- Brute force won't help you here, Luke

function split_diagram(nodes, pattern, history)
    local count = 0
    local i,j = 1,1

    local trace = concat(nodes, '.') .. ' ' .. concat(pattern, ',')
    if history[trace] then
        -- Praise be the Holy Memoization
        return history[trace]
    end

    while i <= #nodes do
        local blank = nodes[i]:find"?"
        if not blank then
            if #nodes[i] ~= (pattern[j] or 0) then
                history[trace] = 0
                return 0
            end
            i,j = i+1, j+1
        else -- has blanks
            if blank-1 > (pattern[j] or 0) then
                -- Too many marks 
                history[trace] = 0
                return 0
            else
                local npattern = {}
                for n = j, #pattern do
                    npattern[#npattern+1] = pattern[n]
                end
                local nnodes = {
                    nodes[i]:sub(1,blank-1)..'#'..nodes[i]:sub(blank+1)
                }
                for n = i+1, #nodes do
                    nnodes[#nnodes+1] = nodes[n]
                end
                count = count + split_diagram(nnodes, npattern, history)
                
                remove(nnodes, 1)
                if blank < #nodes[i] then
                    insert(nnodes, 1, nodes[i]:sub(blank+1))
                end
                if blank > 1 then
                    insert(nnodes, 1, nodes[i]:sub(1,blank-1))
                end
                count = count + split_diagram(nnodes, npattern, history)
                
                break
            end
        end
    end

    
    if i > #nodes and j > #pattern then
        count = count + 1
    end

    history[trace] = count
    return count
end

function hotsprings2(line)
    local diagram, pattern = line:match("([?.#]+) ([%d,]+)")
    diagram = diagram:rep(5, '?')
    pattern = pattern:rep(5, ',')
    pattern = aoc.map(aoc.findall(pattern, "%d+"), tonumber)
    local nodes = aoc.findall(diagram, "[?#]+")
    return split_diagram(nodes, pattern, {})
end

aoc.run_reduce_sum{hotsprings1, hotsprings2}
