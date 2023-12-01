local M = {}

M.sum = function (a, b)
    return (a or 0) + (b or 0)
end

M.reduce = function (F, T)
    local R
    for _,v in pairs(T) do
        R = F(R, v)
    end
    return R
end

M.map = function (F, T)
    local R = {}
    for k,v in pairs(T) do
        R[k] = F[v]
    end
end

return M
