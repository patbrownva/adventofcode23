local aoc = require"adventofcode"

function gearratios1(grid)
    local partnums = 0
    for y,row in ipairs(grid) do
        local col = 1
        while col <= #row do
            local num_start, num_stop = row:find("%d+", col)
            if not num_start then break end
            local num = tonumber(row:sub(num_start, num_stop))
            local surround = row:sub(num_start-1, num_stop+1)
            if y > 1 then
                surround = surround .. grid[y-1]:sub(num_start-1, num_stop+1)
            end
            if y < #grid then
                surround = surround .. grid[y+1]:sub(num_start-1, num_stop+1)
            end
            if surround:match("[^0-9.]") then
                partnums = partnums + num
            end
            col = num_stop + 1
        end
    end
    return partnums
end


local function scan_row_for_numbers(row, part_col, part_nums)
    local col = 1
    while col <= #row do
        local num_start, num_stop = row:find("%d+", col)
        if not num_start then break end
        if num_start <= part_col+1 and num_stop >= part_col-1 then
            part_nums[#part_nums+1] = tonumber(row:sub(num_start, num_stop))
        end
        col = num_stop + 1
    end
end

function gearratios2(grid, part)
    local result = 0
    for y, row in ipairs(grid) do
        local col = 1
        while col <= #row do
            local part_col = row:find(part, col, true)
            if not part_col then break end
            local part_nums = {}
            -- Same row after part, this one is easy
            if row:sub(part_col+1, part_col+1):match("%d") then
                part_nums[#part_nums+1] = tonumber(row:sub(part_col+1):match("%d+"))
            end
            -- Same row before part, also easy
            if row:sub(part_col-1, part_col-1):match("%d") then
                part_nums[#part_nums+1] = tonumber(row:sub(1, part_col-1):match("%d+$"))
            end
            if y > 1 then
                scan_row_for_numbers(grid[y-1], part_col, part_nums)
            end
            if y < #grid then
                scan_row_for_numbers(grid[y+1], part_col, part_nums)
            end
            if #part_nums == 2 then
                result = result + (part_nums[1] * part_nums[2])
            end
            col = part_col + 1
        end
    end
    return result
end

-- main
local stage = ({['1']=gearratios1, ['2']=gearratios2})[arg[1]] or gearratios1
local grid = {}
for line in io.lines() do
    grid[#grid+1] = line
end
print(stage(grid, '*'))
