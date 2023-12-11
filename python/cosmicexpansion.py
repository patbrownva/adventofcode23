# Advent of Code 2023
# Day 11: Cosmic Expansion

from dataclasses import dataclass
from adventofcode import AdventOfCode

pairs = lambda L: sum(([(L[i],L[j]) for j in range(i+1, len(L))] for i in range(len(L))), start=[])

@dataclass
class Galaxy:
    row: int
    col: int


class CosmicExpansion(AdventOfCode):

    def __init__(self, file):
        super().__init__(file)
        self.galaxies = []
        self.horizontal = []
        self.vertical = []

    def line(self, line):
        line = line.strip()
        row = len(self.vertical)
        col = 0
        for space in (len(s) for s in line.split('#')[:-1]):
            self.galaxies.append(Galaxy(row,col+space))
            col += space + 1
        if len(line) > len(self.horizontal):
            self.horizontal = [1 for n in line]
        self.vertical.append(1)

    def expand(self, age):
        for row in range(len(self.vertical)):
            if not any(galaxy.row == row for galaxy in self.galaxies):
                self.vertical[row] += age
        for col in range(len(self.horizontal)):
            if not any(galaxy.col == col for galaxy in self.galaxies):
                self.horizontal[col] += age

    def distance(self, g1, g2):
        distance = 0
        start = g1.col
        stop = g2.col
        if start > stop:
            start,stop = stop,start
        distance += sum(self.horizontal[start:stop])
        start = g1.row
        stop = g2.row
        if start > stop:
            start,stop = stop,start
        distance += sum(self.vertical[start:stop])
        return distance
            
    def distanceiter(self):
        for f, g in pairs(self.galaxies):
            yield self.distance(f, g)

    def expand_and_sum(self, expansion):
        self.expand(expansion-1)
        return sum(self.distanceiter())

def main():
    import sys
    expand = 2
    if len(sys.argv) > 1:
        if sys.argv[1] == '1':
            expand = 2
        elif sys.argv[1] == '2':
            expand = 1000000
        else:
            return
    print(CosmicExpansion(sys.stdin).read().expand_and_sum(expand))

if __name__=='__main__':
    main()
