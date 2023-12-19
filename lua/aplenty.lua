
local function make_grammer(aoc)
     local l = require"lpeg"
     
     local function MakeRange(comp, num)
          if comp == '<' then
               num = tonumber(num) - 1
               return "0,"..num
          else
               return num..",4000"
          end
     end

     local Name = l.R"az"^1
     local Number = l.R"09"^1
     local Compare = l.S"<>"
     local Xmas = l.S"xmas"
     local AcceptReject = l.S"AR" 

     local Destination = AcceptReject + Name
     local NumberRange = (l.C(Compare) * l.C(Number)) / MakeRange
     local CompareRule = l.C(Xmas) * NumberRange
     local Rule = (CompareRule * ":" * l.C(Destination) * ",") / [[{"%1",%2,"%3"};]]
     local Rules = Rule^0 * (Destination / [[{nil,0,4000,"%0"}]])
     local Workflow = (Name/[[W["%0"]=]]) * "{" * l.Cs(Rules) * "}" * "\n"

     local Part = l.Cc[[work(W,]] * l.P"{" * (1-l.P"}")^0 * l.P"}" * l.Cc[[)]] * "\n"
     local Parts = l.Cs(Part^0)

     if aoc == 1 then
          return l.Cs(l.Cc[[W={}
]] * Workflow^0 * "\n" * Parts)
     else
          return l.Cs(l.Cc[[W={}
]] * Workflow^0 * "\n" * l.Cc[[return W
]])
     end
end

local input = io.read"a"

local function part1()
     local script = make_grammer(1):match(input)
     local ipairs = ipairs
     local sum = 0
     local env = {
          work = function(W, part)
               local flow = W["in"]
               local dest = 'R'
               while flow do
                    for _,rule in ipairs(flow) do
                         if rule[1] then
                              local val = part[rule[1]]
                              if val > rule[2] and val <= rule[3] then
                                   dest = rule[4]
                                   break
                              end
                         else
                              dest = rule[4]
                              break
                         end
                    end
                    if dest == 'A' or dest == 'R' then
                         break
                    end
                    flow = W[dest]
               end
               if dest == 'A' then
                    sum = sum + (part.x or 0)
                              + (part.m or 0)
                              + (part.a or 0)
                              + (part.s or 0)
               end
          end;
     }
     --print(script)
     assert(load(script, "Day19", 't', env))()
     return sum
end

local function make_work(dest, range, rule)
     src = range[1]
     dest = dest or src
     rule = rule or range[3]
     return {dest,src,rule,
          x = {range.x[1],range.x[2]};
          m = {range.m[1],range.m[2]};
          a = {range.a[1],range.a[2]};
          s = {range.s[1],range.s[2]};
     }
end

local function part2()
     local insert,remove,unpack = table.insert,table.remove,table.unpack
     local script = make_grammer(2):match(input)
     local W = load(script, "Day19")()
     local V = {make_work("in",{
                           x = {1,4000};
                           m = {1,4000};
                           a = {1,4000};
                           s = {1,4000};
     })}
     local accepted = 0

     while #V > 0 do
          local work = remove(V)
          while work do
               if work[1] == 'A' then
                    accepted = accepted +
                              (work.x[2]-work.x[1]+1) *
                              (work.m[2]-work.m[1]+1) *
                              (work.a[2]-work.a[1]+1) *
                              (work.s[2]-work.s[1]+1)
                    work = remove(V)
               elseif work[1] == 'R' then
                    work = remove(V)
               else
                    break
               end
          end
          if not work then break end
          local flow = W[work[1]]
          local key,low,high,dest
          for i,rule in ipairs(flow) do
               key,low,high,dest = unpack(rule)
               if not key then
                    insert(V, make_work(dest, work, i))
                    break
               elseif work[key][2] > low and work[key][1] <= high then
                    local rdest = make_work(dest, work,i)
                    local rlow,rhigh = work[key][1],work[key][2]
                    if rlow <= low then rlow = low+1 end
                    if rhigh > high then rhigh = high end
                    rdest[key][1],rdest[key][2] = rlow,rhigh
                    insert(V, rdest)
                    if rlow ~= work[key][1] then
                         rdest = make_work(nil, work)
                         rdest[key][2] = low
                         insert(V, rdest)
                    end
                    if rhigh ~= work[key][2] then
                         rdest = make_work(nil, work)
                         rdest[key][1] = high + 1
                         insert(V, rdest)
                    end
                    break
               end
          end
     end

     return accepted
end

print(part1())
print(part2())
