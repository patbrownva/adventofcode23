from adventofcode import AdventOfCode
from dataclasses import dataclass
from typing import Optional

@dataclass
class MRange:
    low: int
    high: int

    def __len__(self):
        return self.high - self.low

    def __str__(self):
        return f"[{self.low},{self.high})"


@dataclass
class BSP:
    parent: Optional['BSP']
    key: str
    val: int = 0
    below: Optional['BSP'] = None
    above: Optional['BSP'] = None

class Aplenty(AdventOfCode):

    def __init__(self, inputfile):
        super().__init__(inputfile)
        self.ruleset = {}
        self.parts = []
        self.line = self.line_workflows
        #self.ruleset['A'] = BSP(key='A')
        #self.ruleset['R'] = BSP(key='R')
    
    def read(self):
        super().read()
        self.ruleset, self.head = self.resolve_rule("in")
        return self

    def line_parts(self, line):
        part = dict((rating[0],int(rating[2:])) for rating in line.strip()[1:-1].split(','))
        self.parts.append(part)
        
    def line_workflows(self, line):
        line = line.strip()
        if not line:
            self.line = self.line_parts
            return
        name, rules = line[:-1].split('{')
        rules = [self.parse_rule(rule) for rule in rules.split(',')]
        ruleset = rules[-1]
        for rule in rules[-2::-1]:
            ruleset = self.rule_node(rule, ruleset)
        self.ruleset[name] = ruleset

    @staticmethod
    def parse_rule(rule):
        if ':' not in rule:
            return rule
        condition,next_rule = rule.split(':')
        return (condition[0], condition[1], int(condition[2:]), next_rule)

    @staticmethod
    def rule_node(rule, next_rule):
        _arg = next_rule
        key = rule[0]
        val = rule[2]
        left_rule = rule[3]
        if left_rule == next_rule:
            return next_rule
        if rule[1] == '>':
            val += 1
            left_rule, next_rule = next_rule, left_rule
        result = (key, val, left_rule, next_rule)
        #print(rule,next_rule,result)
        return result

    def resolve_rule(self, rule, parent=None, leaf=None):
        assert(parent is None or parent.key not in 'AR')
        while type(rule) is str and rule in self.ruleset:
            rule = self.ruleset[rule]
        if rule == "A" or rule == "R":
            leaf = BSP(key=rule,parent=parent,below=leaf)
            return leaf, leaf
        branch = BSP(key=rule[0], val=rule[1], parent=parent)
        branch.above, leaf = self.resolve_rule(rule[3], branch, leaf)
        branch.below, leaf = self.resolve_rule(rule[2], branch, leaf)
        return branch, leaf
        

    def part1(self):
        accepted = 0
        for part in self.parts:
            node = self.ruleset
            while node:
                if node.key == 'A':
                    accepted += sum(part.values())
                    break
                if node.key == 'R':
                    break
                node = node.below if part[node.key] < node.val else node.above
        return accepted

    def part2(self):
        accepted = 0
        node = self.head
        while node:
            if node.key == 'A':
                partrange = {'x':MRange(1,4001),
                            'm':MRange(1,4001),
                            'a':MRange(1,4001),
                            's':MRange(1,4001)}
                parent = node.parent
                side = node
                while parent:
                    if side is parent.below:
                        if partrange[parent.key].high > parent.val:
                            partrange[parent.key].high = parent.val
                    else:
                        if partrange[parent.key].low < parent.val:
                            partrange[parent.key].low = parent.val
                    side = parent
                    parent = parent.parent
                accepted += reduce(mul, (len(r) for r in partrange.values()))
            node = node.below
        return accepted

if __name__=='__main__':
    import sys
    from functools import reduce
    from operator import mul
    factory = Aplenty(sys.stdin).read()
    print(factory.part1())
    print(factory.part2())
    
