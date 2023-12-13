# Advent of Code general class 

from functools import reduce
from dataclasses import dataclass

def main(stages, *args, **kwargs):
    import sys
    stage = stages[0]
    if len(sys.argv) > 1:
        if sys.argv[1] == '1':
            stage = stages[0]
        elif sys.argv[1] == '2':
            stage = stages[1]
        else:
            return
    return stage(sys.stdin, *args, **kwargs)


class AdventOfCode:
    """Framework for AoC-type problems.
    """

    def __init__(self, inputfile):
        """It says 'file' but really accepts any iterable."""
        self.input = inputfile

    def line(self, line):
        pass

    def read(self):
        for line in self.input:
            self.line(line)
        return self

    def reduce_lines(self, collector, initial=None):
        lines = map(self.line, self.input)
        if collector is sum and (initial is None or initial == 0):
            return sum(lines)
        return reduce(collector, lines, initial)

    @staticmethod
    def reduce_and_sum(stages, *args):
        stage = stages[0]
        import sys
        if len(sys.argv) > 1:
            try:
                stage = stages[int(sys.argv[1])-1]
            except:
                return
        return stage(sys.stdin, *args).reduce_lines(sum)


@dataclass(frozen=True, order=True)
class Point:
    x: int = 0
    y: int = 0

    @property
    def i(self):
        return self.x

    @property
    def j(self):
        return self.h

    @property
    def col(self):
        return self.x

    @property
    def row(self):
        return self.y

    def __iter__(self):
        return iter((self.x,self.y))

    def left(self):
        return Point(self.x-1, self.y)

    def right(self):
        return Point(self.x+1, self.y)

    def up(self):
        return Point(self.x, self.y-1)

    def down(self):
        return Point(self.x, self.y+1)

    def __add__(self, other):
        return Point(self.x+other.x, self.y+other.y)

    def __sub__(self, other):
        return Point(self.x-other.x, self.y-other.y)


class Grid:
    """General 2d grid of characters.
    """

    def __init__(self, inputfile):
        self.grid = []
        for line in inputfile:
            self.grid.append(line.rstrip('\n'))

    @property
    def height(self):
        return len(self.grid)

    @property
    def width(self):
        return max(len(row) for row in self.grid) if self.grid else 0

    def __getitem__(self, *args):
        if len(args) == 1:
            x,y = args[1]
        elif len(args) == 2:
            x,y = args[:2]
        else:
            raise IndexError("bad Grid index")
        return self.grid[y][x]

    def each(self):
        for y in range(self.height):
            row = self.grid[y]
            for x in range(self.width):
                if x < len(row):
                    yield Point(x,y),row[x]
                else:
                    yield Point(x,y),''

    def find(self, ch, start=Point()):
        startX,startY = start
        for y in range(startY, self.height):
            row = self.grid[y]
            foundX = row.find(ch, startX)
            if foundX >= 0:
                return Point(foundX, y)
            startX = 0
        return None
