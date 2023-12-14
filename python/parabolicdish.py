# Advent of Code 2023
# Day 14: Parabolic Reflector Dish

from adventofcode import AdventOfCode, Grid, main
from collections import deque

class Parabolic1(Grid):

    def __init__(self, inputfile):
        super().__init__(inputfile)
        # Turn to column oriented with North facing down
        self.grid.reverse()
        self.transpose()

    def read(self):
        return self

    def tilt_north(self):
        tilted_rows = []
        for col in self.grid:
            blocks = [i+1 for i in range(len(col)) if col[i] == '#']
            slide = []
            if blocks:
                slide.append(col[:blocks[0]])
                slide.extend(col[m:n] for m,n in zip(blocks[:-1],blocks[1:]))
                slide.append(col[blocks[-1]:])
            else:
                slide.append(col)
            col = ''.join('.'*slip.count('.') + 'O'*slip.count('O') + '#'
                          for slip in slide)
            tilted_rows.append(col)
        self.grid = tilted_rows

    def weigh_north(self):
        return sum(
            sum(i+1 for i in range(len(col)) if col[i] == 'O')
            for col in self.grid)

    def tilt_and_weigh(self, *ignore):
        self.tilt_north()
        return self.weigh_north()


class Rock:

    def __init__(self, row, col):
        self.row = row
        self.col = col

    def north(self, n):
        self.col -= n
    def south(self, n):
        self.col += n
    def west(self, n):
        self.row -= n
    def east(self, n):
        self.row += n


class Parabolic2(AdventOfCode):

    def __init__(self, inputfile):
        super().__init__(inputfile)
        self.boulders = []
        self.blocks = []
        self.width = 0
        self.height = 0

    def line(self, line):
        line = line.strip()
        for x,ch in enumerate(line):
            if ch == 'O':
                self.boulders.append(Rock(self.height, x))
            elif ch == '#':
                self.blocks.append(Rock(self.height, x))
        self.height += 1
        self.width = max(len(line), self.width)

    def tilt_north(self):
        for col in range(self.width):
            blocks = sorted((r.row for r in self.blocks if r.col == col), reverse=True)
            boulders = sorted((r for r in self.boulders if r.col == col),
                              key=lambda r: r.row)
            blocks.insert(0, self.height)
            stop = -1
            for bould in boulders:
                while blocks[-1] < bould.row:
                    stop = blocks.pop()
                stop += 1
                bould.row = stop

    def tilt_south(self):
        for col in range(self.width):
            blocks = sorted((r.row for r in self.blocks if r.col == col))
            boulders = sorted((r for r in self.boulders if r.col == col),
                              key=lambda r: r.row, reverse=True)
            blocks.insert(0, -1)
            stop = self.height
            for bould in boulders:
                while blocks[-1] > bould.row:
                    stop = blocks.pop()
                stop -= 1
                bould.row = stop

    def tilt_west(self):
        for row in range(self.height):
            blocks = sorted((r.col for r in self.blocks if r.row == row), reverse=True)
            boulders = sorted((r for r in self.boulders if r.row == row),
                              key=lambda r: r.col)
            blocks.insert(0, self.width)
            stop = -1
            for bould in boulders:
                while blocks[-1] < bould.col:
                    stop = blocks.pop()
                stop += 1
                bould.col = stop

    def tilt_east(self):
        for row in range(self.height):
            blocks = sorted((r.col for r in self.blocks if r.row == row))
            boulders = sorted((r for r in self.boulders if r.row == row),
                              key=lambda r: r.col, reverse=True)
            blocks.insert(0, -1)
            stop = self.width
            for bould in boulders:
                while blocks[-1] > bould.col:
                    stop = blocks.pop()
                stop -= 1
                bould.col = stop

    def weigh_north(self):
        return sum(self.height-r.row for r in self.boulders)

    def tilt_and_weigh(self, cycles=0):
        if cycles == 0:
            self.tilt_east()
        else:
            history = deque(maxlen=2**15)
            weight = 0
            for i in range(cycles):
                self.cycle()
                weight = self.weigh_north()
                history.appendleft(weight)
                if len(history) > 2**4:
                    future = extrapolate(tuple(history), cycles-i-1)
                    if future is not None:
                        return future
        return weight
 
    def cycle(self):
        self.tilt_north()
        self.tilt_west()
        self.tilt_south()
        self.tilt_east()

    def dump(self):
        rows = [['.' for j in range(self.width)] for i in range(self.height)]
        for r in self.blocks:
            rows[r.row][r.col] = '#'
        for r in self.boulders:
            rows[r.row][r.col] = 'O'
        print('\n'.join(''.join(r) for r in rows))


def extrapolate(seq, n):
    def find_rep(start):
        repeat = 1
        try:
            search = seq.index(seq[0], start)
            scan = search + 1
            while repeat < search and scan < len(seq):
                if seq[repeat] != seq[scan]:
                    break
                repeat += 1
                scan += 1
            if repeat == search:
                return repeat
            return find_rep(search+1)
        except ValueError:
            return None

    rep_len = find_rep(2**3-1)
    if rep_len:
        n %= rep_len
        return seq[rep_len - n]
    
    return None


if __name__=='__main__':
    print(main([Parabolic1, Parabolic2]).read().tilt_and_weigh(1000000000))

