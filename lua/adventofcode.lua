local M = {}

M.sum = function (a, b)
    return (a or 0) + (b or 0)
end

M.reduce = function (T, F)
    local R
    for _,v in pairs(T) do
        R = F(R, v)
    end
    return R
end

M.map = function (T, F)
    local R = {}
    for k,v in pairs(T) do
        R[k] = F[v]
    end
    return R
end

M.index = function (T, V)
    for k,v in pairs(T) do
        if v == V then return k end
    end
    return nil
end

M.run_reduce_sum = function (stages, ...)
    local stage = stages[tonumber(arg[1]) or 1]
    local lines = {}
    for line in io.lines() do
        lines[#lines+1] = stage(line, ...)
    end
    print(M.reduce(lines, M.sum))
end

return M
