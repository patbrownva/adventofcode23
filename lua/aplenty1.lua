local l = require"lpeg"

local Name = l.R"az"^1
local Number = l.R"09"^1
local Compare = l.S"<>"
local Xmas = l.S"xmas"
local AcceptReject = l.S"AR" 

local Destination = (AcceptReject / [[return "%0"]])
                  + (Name / [[return W["%0"](part)]])
local CompareRule = l.C(Xmas) * l.C(Compare) * l.C(Number) * l.P":"
local Rule = CompareRule/[[if part.%1%2%3 then ]] * Destination * (l.P","/[[ end ]])
local Rules = Rule^0 * Destination
local Workflow = l.Cs((l.C(Name) * "{")/[[W["%1"]=function(part) ]]
                * l.Cs(Rules) * (l.P"}"/[[ end]]))

local Part = l.Cc[[work(W,]] * l.P"{" * (1-l.P"}")^0 * l.P"}" * l.Cc[[)]] * "\n"
local Parts = l.Cs(Part^0)

local Grammer = l.Cs(l.Cc[[W={}
]] * (Workflow * "\n")^0 * "\n" * Parts)

local script = Grammer:match(io.read("a"))
local sum = 0
local env = {
     work = function(W, part)
          if W["in"](part) == 'A' then
               sum = sum + (part.x or 0) + (part.m or 0) + (part.a or 0) + (part.s or 0)
          end
     end;
}
load(script, "Day19", 't', env)()
print(sum)
