from dataclasses import dataclass

@dataclass(frozen=True)
class Point:
    x: int
    y: int

    def __add__(self, pt):
        return Point(self.x+pt.x, self.y+pt.y)

Point.Direction = {'N':Point(0,-1), 'S':Point(0,1), 'W':Point(-1,0), 'E':Point(1,0)}


class Maze:

    def __init__(self, input):
        self.maze = []
        self._start = None
        self.pipes = set()
        for y,line in enumerate(input.readlines()):
            row = [*line.strip()]
            if 'S' in row:
                self._start = Point(row.index('S'), y)
                self.pipes.add(self._start)
            self.maze.append(row)

    def get(self, pt):
        if pt.y < len(self.maze) and pt.x < len(self.maze[pt.y]):
            return self.maze[pt.y][pt.x]
        raise IndexError(f"{pt} not in maze")

    def trace(self):
        count = 1
        dir = self.start()
        at = self._start + Point.Direction[dir]
        while at != self._start:
            self.pipes.add(at)
            match self.get(at):
                case '|' | '-':
                    pass
                case 'L' | '7':
                    dir = {'N':'W', 'S':'E', 'E':'S', 'W':'N'}[dir]
                case 'J' | 'F':
                    dir = {'N':'E', 'S':'W', 'E':'N', 'W':'S'}[dir]
            at = at + Point.Direction[dir]
            count += 1
        return count

    def start(self):
        what = [d for d in Point.Direction
                  if (d,self.get(self._start+Point.Direction[d])) in [
                      ('N','|'),('S','|'),('W','-'),('E','-'),
                      ('N','7'),('E','7'),('W','L'),('S','L'),
                      ('N','F'),('W','F'),('E','J'),('S','J')]]
        match what:
            case ['N','S'] | ['S','N']:
                self.maze[self._start.y][self._start.x] = '|'
            case ['E','W'] | ['W','E']:
                self.maze[self._start.y][self._start.x] = '-'
            case ['E','N'] | ['N','E']:
                self.maze[self._start.y][self._start.x] = 'L'
            case ['E','S'] | ['S','E']:
                self.maze[self._start.y][self._start.x] = 'F'
            case ['N','W'] | ['W','N']:
                self.maze[self._start.y][self._start.x] = 'J'
            case ['S','W'] | ['W','S']:
                self.maze[self._start.y][self._start.x] = '7'
        return what[-1]

    def each(self):
        for y in range(len(self.maze)):
            for x in range(len(self.maze[y])):
                yield Point(x,y)

    def inside(self, start):
        count = 0
        row = self.maze[start.y]
        pipe = None
        x = start.x
        cols = range(x+1, len(row)) if len(row)-x < x else range(x)
        span =''.join(self.get(Point(i,start.y)) for i in cols if Point(i, start.y) in self.pipes)
        span = span.replace('-','').replace('L7','|').replace('FJ','|')
        return span.count('|')%2 == 1


def pipemaze1(maze):
    return maze.trace() // 2

def pipemaze2(maze):
    return sum(maze.inside(pt) for pt in maze.each() if pt not in maze.pipes)
    count = 0
    row = []
    for c in (maze.get(pt) if pt in maze.pipes else ('+' if maze.inside(pt) else ' ') for pt in maze.each()):
        row.append(c)
        if len(row) >= len(maze.maze[0]):
            count += row.count('+')
            print(''.join(row))
            row = []
    return count

def main():
    import sys
    maze = Maze(sys.stdin)
    print(pipemaze1(maze))
    print(pipemaze2(maze))

if __name__=='__main__':
    main()
