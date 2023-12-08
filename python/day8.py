import re

NODE = re.compile(r"(\w+) = \((\w+), (\w+)\)")

class Node:
    
    def __init__(self, here, left, right):
        self.mark = here
        self.path = { 'L': left, 'R': right }
        self.shortcut = None


class Wasteland1:

    def __init__(self, file):
        self.turns = file.readline().strip()
        self.nodes = {}
        for line in file:
            match = NODE.match(line)
            if match:
                node = Node(*match.groups())
                self.nodes[node.mark] = node

    @staticmethod
    def stop(mark):
        return mark == 'ZZZ'

    def start(self):
        return 'AAA'

    def _trace(self, steps, start, turns, backtrace):
        node = self.nodes[start]
        if not turns:
            return start
        if len(turns) >= 3 and turns[:3] in node.path:
            #debug("3")
            nextnode = node.path[turns[:3]]
            # not tracing more than three stops back, flush
            backtrace = []
            if self.stop(nextnode):
                return steps + 3
            return self._trace(steps+3, nextnode, turns[3:], backtrace)
        if len(turns) == 2 and turns[:2] in node.path:
            #debug("2")
            nextnode = node.path[turns[:2]]
            if len(backtrace) > 0:
                backnode,backpath = backtrace[0]
                backnode.path[backpath+turns[:2]] = nextnode
            backtrace.insert(0, (node,turns[:2]))
            if len(backtrace) > 2:
                backtrace.pop()
            if self.stop(nextnode):
                return steps + 2
            return self._trace(steps+2, nextnode, turns[2:], backtrace)
        # len(turns) == 1
        #debug("1")
        nextnode = node.path[turns[0]]
        back = turns[0]
        for backnode,backpath in backtrace:
            back = backpath+back
            backnode.path[back] = nextnode
        backtrace.insert(0, (node,turns[0]))
        if len(backtrace) > 2:
            backtrace.pop()
        if self.stop(nextnode):
            return steps + 1
        return self._trace(steps+1, nextnode, turns[1:], backtrace)


    def trace(self, start):
        loop = 0
        while True:
            #debug("T")
            steps = self._trace(loop, start, self.turns, [])
            if type(steps) is int:
                #debug("\n")
                return steps
            self.nodes[start].shortcut = steps
            start = steps
            loop += len(self.turns)

class Wasteland2(Wasteland1):

    @staticmethod
    def stop(mark):
        return mark.endswith('Z')

    def start(self):
        return [n for n in self.nodes if n.endswith('A')]

def part1(file):
    return Wasteland1(file).trace('AAA')

def part2(file):
    import math
    part2 = Wasteland2(file)
    return math.lcm(*(part2.trace(t) for t in part2.start()))

def main():
    import sys
    stage = part1
    if len(sys.argv) > 1:
        if sys.argv[1] == '2':
            stage = part2
        elif sys.argv[1] == '1':
            stage = part1
        else:
            return
    print(stage(sys.stdin))

if __name__=='__main__':
    main()

