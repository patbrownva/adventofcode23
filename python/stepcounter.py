from adventofcode import Grid,Point,main
from dataclasses import dataclass
from collections import deque
from heapq import *
from functools import cache
import sys
import math

class InfiniteGrid(Grid):
    def __getitem__(self, *args):
        if len(args) == 1:
            x,y = args[0]
        elif len(args) == 2:
            x,y = args
        else:
            raise IndexError("bad Grid index")
        x = x % self.width
        y = y % self.height
        return self.grid[y][x]


grid = InfiniteGrid(sys.stdin)
start = grid.find('S')
stepcount = {start:0}

def resetcount(start):
    global stepcount
    stepcount = {start:0}

def parity(point):
    return (point.i + point.j) % 2

@cache
def boundedneighbors(at):
    spaces = []
    if at.y > 0 and grid[(at.x,at.y-1)] != '#':
        spaces.append(Point(at.x, at.y-1))
    if at.y+1 < grid.height and grid[(at.x,at.y+1)] != '#':
        spaces.append(Point(at.x, at.y+1))
    if at.x > 0 and grid[(at.x-1,at.y)] != '#':
        spaces.append(Point(at.x-1, at.y))
    if at.x+1 < grid.width and grid[(at.x+1,at.y)] != '#':
        spaces.append(Point(at.x+1, at.y))
    return tuple(spaces)

@cache
def infiniteneighbors(at):
    spaces = []
    if grid[(at.x,at.y-1)] != '#':
        spaces.append(Point(at.x, at.y-1))
    if grid[(at.x,at.y+1)] != '#':
        spaces.append(Point(at.x, at.y+1))
    if grid[(at.x-1,at.y)] != '#':
        spaces.append(Point(at.x-1, at.y))
    if grid[(at.x+1,at.y)] != '#':
        spaces.append(Point(at.x+1, at.y))
    return tuple(spaces)

@dataclass(frozen=True, order=True)
class PPoint:
    cost: int
    step: int
    point: Point
    def __iter__(self):
        return iter((self.step,self.point))

def shortestpath(neighbors, start, goal, max_steps = 2**63):
    if goal in stepcount:
        steps = stepcount[goal]
        return steps if steps <= max_steps else None
    queue = []
    #shortcuts = []
    notvisited = {}
    visited = {}
    path = {}
    cur_step = 0
    cur_pt = goal
    shortcut = False
    while cur_pt != start:
        visited[cur_pt] = True
        #if cur_pt in stepcount:
        #    shortcut = True
        #    break
        step = cur_step + 1
        if step <= max_steps:
            for next_pt in neighbors(cur_pt):
                if next_pt in notvisited and notvisited[next_pt].step > step:
                    queue.remove(notvisited[next_pt])
                    del notvisited[next_pt]
                if not (next_pt in visited or next_pt in notvisited):
                    distance = (stepcount[next_pt] if next_pt in stepcount else
                                start.distance(next_pt))
                    qpoint = PPoint(step+distance, step, next_pt)
                    heappush(queue, qpoint)
                    notvisited[next_pt] = qpoint
                    path[next_pt] = cur_pt
        if not queue:
            break
        cur_step, cur_pt = heappop(queue)
        del notvisited[cur_pt]
    if cur_pt != start and not shortcut:
        return None
    backpath = path[cur_pt]
    realstep = 1 if not shortcut else stepcount[cur_pt] + 1
    while backpath != goal:
        stepcount[backpath] = realstep
        realstep += 1
        backpath = path[backpath]
    #assert realstep == cur_step, f"{realstep} != {cur_step}"
    stepcount[goal] = realstep
    return realstep if realstep <= max_steps else None

@cache
def followpath(start, steps):
    spaces = boundedneighbors(start)
    steps -= 1
    if steps == 0:
        return set(spaces)
    followed = set()
    for space in spaces:
        followed |= followpath(space, steps)
    return followed

def part1(step):
    f = followpath(start, step)
    print(len(f))

def countpaths(base, step):
    onstep = parity(base) ^ step&1
    if base != start:
        resetcount(base)
    reachable = set()
    for point in (Point(x,y)
                  for y in range(max(base.y-step, 0), min(base.y+step+1, grid.height))
                  for x in range(max(base.x-step, 0),min(base.x+step+1, grid.width))):
        if grid[point] == '#' or parity(point) != onstep or base.distance(point) > step:
            continue
        reached = shortestpath(boundedneighbors, base, point, step)
        if reached is not None:
            reachable.add(point)
    return len(reachable)

def countallpaths(base):
    if base != start:
        resetcount(base)
    reachable = [set(), set()]
    for point in (Point(x,y)
                  for y in range(0, grid.height)
                  for x in range(0, grid.width)):
        if grid[point] == '#':
            continue
        reached = shortestpath(boundedneighbors, base, point)
        if reached is not None:
            reachable[reached&1].add(point)
    return (len(reachable[0]), len(reachable[1]))

def countpathswrap(base, step):
    onstep = parity(base) ^ step&1
    if base != start:
        resetcount(base)
    reachable = set()
    for point in (Point(x,y)
                  for y in range(base.y-step, base.y+step+1)
                  for x in range(base.x-step, base.x+step+1)):
        if grid[point] == '#' or parity(point) != onstep or base.distance(point) > step:
            continue
        reached = shortestpath(infiniteneighbors, base, point, step)
        if reached is not None:
            reachable.add(point)
    return len(reachable)

def no_really_part1():
    print(countpaths(start, 64))

def reach(point):
    if grid[point] == '#':
        return
    return shortestpath(infiniteneighbors, start, point)

def just_part2_already(max_step):
    evenstep, oddstep = countallpaths(start)
    count = evenstep if max_step&1 else oddstep
    print(count)
    print(oddstep,evenstep)
    remain = (max_step-start.x-1) % grid.width
    edgeremain = remain - start.y+1 + grid.width
    span = (max_step-start.x-1) // grid.width
    rowcap = oddstep if (remain-1)&1 else evenstep
    rowstep = lambda r: r//2*(evenstep+oddstep)+r%2*rowcap
    right = countpaths(Point(0, start.y), remain)
    print("right", remain, right)
    count += rowstep(span) + right
    corner = countpaths(Point(0, 0), edgeremain)
    print("[J]", edgeremain, corner)
    for row in range(span-1, -1, -1):
        count += rowstep(row) + corner
    left = countpaths(Point(grid.width-1, start.y), remain)
    print("left", remain, left)
    count += rowstep(span) + left
    corner = countpaths(Point(grid.width-1, grid.height-1), edgeremain)
    print("[F]", edgeremain, corner)
    for row in range(span-1, -1, -1):
        count += rowstep(row) + corner

    remain = (max_step-start.y-1) % grid.height
    edgeremain = remain - start.x+1 + grid.height
    span = (max_step-start.y-1) // grid.height
    rowcap = oddstep if (remain-1)&1 else evenstep
    rowstep = lambda r: r//2*(evenstep+oddstep)+r%2*rowcap
    down = countpaths(Point(start.x, 0), remain)
    print("down", remain, down)
    count += rowstep(span) + down
    corner = countpaths(Point(grid.width-1, 0), edgeremain)
    print("[L]", edgeremain, corner)
    for row in range(span-1, -1, -1):
        count += rowstep(row) + corner
    up = countpaths(Point(start.x, grid.height-1), remain)
    print("up", remain, up)
    count += rowstep(span) + up
    corner = countpaths(Point(0, grid.height-1), edgeremain)
    print("[7]", edgeremain, corner)
    for row in range(span-1, -1, -1):
        count += rowstep(row) + corner
    
    print(count)

if __name__=='__main__':
    #part1(6)
    #print(countpathswrap(start, 10))
    #resetcount(start)
    #no_really_part1()
    #part2(10)
    #part2(26501365)
    just_part2_already(26501365)
