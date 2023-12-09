from adventofcode import AdventOfCode

ext = lambda q,s: recurse(q,s) if any(q) else sum(s)
row = lambda p: tuple(p[n]-p[n-1] for n in range(1,len(p)))
recurse = lambda r,s: ext(row(r), r[-1:]+s)

class mirage1(AdventOfCode):
    @staticmethod
    def line(line):
        return recurse(tuple(int(n) for n in line.strip().split()), tuple())

class mirage2(AdventOfCode):
    @staticmethod
    def line(line):
        return recurse(tuple(reversed(
            [int(n) for n in line.strip().split()])), tuple())

print(AdventOfCode.reduce_and_sum([mirage1,mirage2]))
