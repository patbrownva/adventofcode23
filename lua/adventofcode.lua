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

return M
