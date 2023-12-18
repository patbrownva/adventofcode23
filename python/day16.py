from adventofcode import AdventOfCode, Point, main
from collections import defaultdict


def CCW(vec):
    return vec @ [[0,-1],[-1,0]]

def CW(vec):
    return vec @ [[0, 1],[ 1,0]]

Reflection = {
    '/':  lambda vec: (CCW(vec),),
    '\\': lambda vec: (CW(vec),),
    '|':  lambda vec: (vec,) if vec.x == 0 else (CCW(vec), CW(vec)),
    '-':  lambda vec: (vec,) if vec.y == 0 else (CCW(vec), CW(vec)),
    '.':  lambda vec: (vec,)
    }


class Beams1(AdventOfCode):

    def __init__(self, inputfile):
        super().__init__(inputfile)
        self.rows = []
        self.width = 0
    
    @property
    def height(self):
        return len(self.rows)
    
    def line(self, line):
        line = line.strip()
        self.width = len(line)
        rows = ((col,prism) for col,prism in enumerate(line) if prism != '.')
        self.rows.append(defaultdict(lambda: '.', rows))

    def energize(self, start_at, start_dir):
        energized = set() # tuple(cel, vec)
        active = set()
        
        def passthru(_beam, _dir):
            if 0 <= _beam.row < self.height and 0 <= _beam.col < self.width:
                trace = (_beam, _dir)
                if trace not in energized:
                    energized.add(trace)
                    active.add(trace)
        
        passthru(start_at, start_dir)
        while active:
            beam,direction = active.pop()
            reflections = Reflection[self.rows[beam.row][beam.col]](direction)
            for bounce in reflections:
                passthru(beam+bounce, bounce)
            
        return len(set(tile for tile,vector in energized))

    def activate(self):
        return self.energize(Point(0,0), Point(1,0))


class Beams2(Beams1):

    def activate(self):
        most_energized = 0
        for j in range(self.height):
            energy = max(self.energize(Point(0,j), Point(1,0)),
                         self.energize(Point(self.width-1,j), Point(-1,0)))
            most_energized = max(most_energized, energy)
        for i in range(self.width):
            energy = max(self.energize(Point(i,0), Point(0,1)),
                         self.energize(Point(i,self.height-1), Point(0,-1)))
            most_energized = max(most_energized, energy)
        return most_energized


if __name__=='__main__':
    print(main([Beams1, Beams3]).read().activate())
    # for pt in [Point(1,0),Point(-1,0),Point(0,-1),Point(0,1)]:
    #     print(pt, CCW(pt), CW(pt))
    #     print(Reflection['/'](pt), Reflection['\\'](pt))
    #     for m in [ [[0,-1],[-1,0]], [[0,1],[1,0]] ]:
    #         print(str(m), pt@m)
    
