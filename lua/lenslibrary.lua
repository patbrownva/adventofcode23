local byte = string.byte
local tremove = table.remove

local function index(slots, label)
    return slots[label] or (#slots + 1)
end

local function remove(slots, label)
    local ix = index(slots, label)
    local old = tremove(slots, ix)
    if old then
        slots[old.label] = nil
    end
    for i = ix,#slots do
        slots[slots[i].label] = i
    end
end

local function insert(slots, label, focus)
    local ix = index(slots, label)
    slots[ix] = {label=label, focus=focus}
    slots[label] = ix
end

local HASHMAP = {}
function HASH(str, digest)
    if HASHMAP[str] then return HASHMAP[str] end
    local function _hash(digest, ch, ...)
        if not ch then
            HASHMAP[str] = digest
            return digest
        end
        return _hash((digest + ch) * 17 % 256, ...)
    end
    return _hash(digest or 0, byte(str, 1, -1))
end

OP = {
    ["-"] = function (label)
        local hash = HASH(label)
        local box = BOX[hash] or {}
        remove(box, label)
        BOX[hash] = box
    end;

    ["="] = function (label, focus)
        local hash = HASH(label)
        local box = BOX[hash] or {}
        insert(box, label, focus)
        BOX[hash] = box
    end;
}

BOX = {}
SUM = 0

-- main
local input = io.read"a"

for instr, label, op, focus in input:gmatch("((%w+)([=-])(%d*))") do
    SUM = SUM + HASH(instr)
    OP[op](label, focus)
end
print(SUM)

SUM = 0
for hash, box in pairs(BOX) do
    hash = hash + 1
    for ix, lens in ipairs(box) do
        SUM = SUM + (hash * ix * lens.focus)
    end
end
print(SUM)
