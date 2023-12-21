local aoc = require"adventofcode"
local insert,remove,unpack = table.insert,table.remove,table.unpack
local ipairs,pairs = ipairs,pairs

local function flipflop(module)
    local state = false
    return function(pulse)
        if pulse == 'L' then
            state = not state
            return state and 'H' or 'L'
        end
    end
end

local function conjunction(module)
    local inputs = {}
    return function(pulse, sender)
        inputs[sender] = pulse
        for _,k in pairs(module.inputs) do
            if inputs[k] ~= 'H' then
                return 'H'
            end
        end
        return 'L'
    end
end

local function broadcaster()
    return function(pulse)
        return pulse
    end
end

local function rx(module)
    return function(pulse)
        if pulse == 'L' then
            module.on = true
        end
    end
end

local Processors = {
    ['%'] = flipflop;
    ['&'] = conjunction;
    ['!'] = rx;
}

local Messages = {}
local Modules = {}
local Counter = {H=0, L=0}
local num_modules = 0
local Bitmask = {}
local Tick = 0

local function post(pulse, receiver, sender)
    insert(Messages, {pulse, receiver, sender})
end

local function send(pulse, receiver, sender)
    local module = Modules[receiver]
    if module then
        pulse = module.receive(pulse, sender)
        if pulse then
            Bitmask[module.n] = pulse
            for _,output in ipairs(module.outputs) do
                post(pulse, output, receiver)
            end
        end
    end
end

local function create(code, name, outputs)
    num_modules = num_modules + 1
    local process = Processors[code] or broadcaster
    local module = {inputs={},outputs=outputs, code=code,n=num_modules}
    module.receive = process(module)
    Modules[name] = module
end

local function makebits(n)
    local bits = {}
    for i = 1,n do
        bits[i] = '-'
    end
    return bits
end

local function connect()
    for name, module in pairs(Modules) do
        for i = #module.outputs,1,-1 do
            local receiver = Modules[module.outputs[i]]
            if receiver then
                insert(receiver.inputs, name)
            else
                --remove(module.outputs, i)
            end
        end
    end
end

local function pump()
    local message = remove(Messages, 1)
    if not message then
        return false
    end
    local pulse,receiver,sender = unpack(message)
    --print(sender .. " " .. pulse .. "-> " .. receiver)
    Counter[pulse] = Counter[pulse] + 1
    send(unpack(message))
    return true
end

local function read(input)
    for line in input() do
        local code, name, outputs = line:match("([%%&]?)(%a+) %-> ([%w, ]*)")
        if name and outputs then
            if code == '' then code = 'I' end
            create(code, name, aoc.findall(outputs, "%w+"))
        end
    end
    create('!', "rx", {})
    connect()
    Bitmask = makebits(num_modules)
end

local function run()
    Tick = 0
    post('L', "broadcaster", "button")
    while pump() do
        Tick = Tick + 1
    end
    return Tick
end

function pulsepropagation1(input)
    read(input)
    for I = 1,1000 do
        run()
    end
    print("L", "H", "LxH")
    print(Counter.L, Counter.H, Counter.H * Counter.L)
end

local function tracelines()
    local trace = {"rx"}
    while #trace > 0 do
        local name = remove(trace, 1)
        if not trace[name] then
            local mod = Modules[name]
            local bits = makebits(num_modules)
            bits[mod.n]='O'
            trace[name] = true
            for _,inp in ipairs(mod.inputs) do
                bits[Modules[inp].n] = mod.code or 'I'
                if not trace[inp] then insert(trace, inp) end
            end
            if name == 'broadcaster' then
                print('  I'..table.concat(bits))
            else
                print(name..'-'..table.concat(bits))
            end
        end
    end
end

local function setmonitor(module, monitor, trigger)
    monitor = monitor or {gate={}}
    trigger = trigger or 'H'
    local gates = {}
    for _,mod in ipairs(Modules[module].inputs) do
        if mod.code == '%' then
            setmonitor(mod, monitor, trigger=='H' and 'L' or 'H')
        else
            for _,inp in ipairs(Modules[mod].inputs) do
                local mod = Modules[inp]
                local mreceive = mod.receive
                mod.receive = function(...)
                    --monitor.tick = monitor.tick + 1
                    monitor.gate[inp].tick = monitor.gate[inp].tick + 1
                    local pulse = mreceive(...)
                    if pulse == trigger then
                        monitor.gate[inp].set = Tick
                    elseif pulse and
                           monitor.gate[inp].set and
                           not monitor.gate[inp].reset then
                        monitor.gate[inp].reset = Tick
                    end
                    return pulse
                end
                monitor.gate[inp] = {tick=0,set=nil,reset=nil}
            end
        end
    end
    return monitor
end

function pulsepropagation2(input)
    read(input)

--[=[
    tracelines()
    print()
--]=]

    local monitor = setmonitor("rx")
    local cycle = {}
    local count = 0
    for _,_ in pairs(monitor.gate) do
        count = count + 2
    end
    print("line", "cycle", "set", "reset", "ticks")
    for I = 1,100000000 do
        run()
        --print('L'..table.concat(Bitmask))
        local all = true
        for line,gate in pairs(monitor.gate) do
            if gate.set then
                print(line, I, gate.set, gate.reset, gate.tick)
                insert(cycle, {line, I, gate.set, gate.reset, gate.tick})
                gate.set = nil
                gate.reset = nil
                gate.tick = 0
                count = count - 1
            else
                all = false
            end
        end
        --if all then break end
        if count <= 0 then break end
    end

    local sync = 1
    for i = 1,#cycle/2 do
        sync = aoc.lcm(sync, cycle[i][2])
    end
    print(string.format("%17d",sync))
end

aoc.run({pulsepropagation1, pulsepropagation2}, io.lines)
