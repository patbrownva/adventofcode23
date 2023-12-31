# Advent of Code general class 

from dataclasses import dataclass
from functools import reduce
from itertools import zip_longest

def main(stages, *args, **kwargs):
    import sys
    stage = stages[0]
    if len(sys.argv) > 1:
        if sys.argv[1] == '1':
            stage = stages[0]
        elif sys.argv[1] == '2':
            stage = stages[1]
        else:
            sys.exit()
    return stage(sys.stdin, *args, **kwargs)


class AdventOfCode:
    """Framework for AoC-type problems.
    """

    def __init__(self, inputfile):
        """It says 'file' but really accepts any iterable."""
        self.input = inputfile

    def line(self, line):
        pass
    
    def finish(self):
        pass

    def read(self):
        for line in self.input:
            self.line(line)
        self.finish()
        self.input = None
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
        return self.y

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

    def __mul__(self, scale):
        return Point(self.x*scale, self.y*scale)

    def __matmul__(self, matrix):
        return Point(self.x*matrix[0][0] + self.y*matrix[0][1],
                     self.x*matrix[1][0] + self.y*matrix[1][1])

    def distance(self, other):
        return abs(self.x-other.x) + abs(self.y-other.y)


class Grid:
    """General 2d grid of characters.
    """

    def __init__(self, inputfile):
        self.grid = []
        for line in inputfile:
            line = line.rstrip('\n')
            if not line:
                break
            self.grid.append(line)
        self.columns = [None for _ in range(self.width)]

    @property
    def height(self):
        return len(self.grid)

    @property
    def width(self):
        return max(len(row) for row in self.grid) if self.grid else 0

    def __getitem__(self, *args):
        if len(args) == 1:
            x,y = args[0]
        elif len(args) == 2:
            x,y = args
        else:
            raise IndexError("bad Grid index")
        if x >= self.width:
            raise IndexError("Grid index out of range")
        return self.grid[y][x] if x < len(self.grid[y]) else None

    def __setitem__(self, *args):
        if len(args) == 2:
            x,y = args[0]
            v = args[1]
        elif len(args) == 3:
            x,y,v = args
        else:
            raise IndexError("bad Grid index")
        row = self.grid[y]
        self.grid[y] = row[:x] + v + row[x+1:]
        self.columns[x] = None

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

    def row(self, y):
        return self.grid[y] if (0 <= y < self.height) else None

    def column(self, x):
        if 0 <= x < self.width:
            if self.columns[x] is None:
                self.columns[x] = ''.join(*zip_longest(
                                    *(row[x:x+1] for row in self.grid), fillvalue=' '))
            return self.columns[x]
        return None

    def transpose(self):
        #self.grid = [self.column(x) for x in range(self.width)]
        self.grid = [''.join(col) for col in zip_longest(*self.grid, fillvalue=' ')]
        self.columns = [None for _ in range(self.width)]
