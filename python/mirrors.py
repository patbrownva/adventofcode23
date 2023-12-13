# Advent of Code 2023
# Day 13: Point of Incidence

from adventofcode import Grid

def compare(left, right):
    return [(l,r) for l,r in zip(left,right) if l != r]

def reflections(grid):
    ref = set()
    for row in range(1,grid.height):
        if all(grid.row(row+y) == grid.row(row-y-1)
               for y in range(min(row, grid.height-row))):
            ref.add((row, 0))
    for col in range(1, grid.width):
        if all(grid.column(col+x) == grid.column(col-x-1)
               for x in range(min(col, grid.width-col))):
            ref.add((0, col))
    return ref

def altered_reflections(grid):
    def mutate(left, right):
        nonlocal altered
        if left != right:
            if altered or len(compare(left, right)) != 1:
                return False
            altered = True
        return True

    ref = set()
    for row in range(1,grid.height):
        altered = False
        if all(mutate(grid.row(row+y), grid.row(row-y-1)) 
               for y in range(min(row, grid.height-row))):
            ref.add((row, 0))
    for col in range(1, grid.width):
        altered = False
        if all(mutate(grid.column(col+x), grid.column(col-x-1)) 
               for x in range(min(col, grid.width-col))):
            ref.add((0, col))
    return ref

def mirrors1(input):
    while True:
        grid = Grid(input)
        if grid.height == 0:
            return
        y,x = reflections(grid).pop()
        yield 100*y + x

def mirrors2(input):
    while True:
        grid = Grid(input)
        if grid.height == 0:
            return
        y,x = (altered_reflections(grid) - reflections(grid)).pop()
        yield 100*y + x

def main():
    import sys
    stage = mirrors1
    if len(sys.argv) > 1:
        if sys.argv[1] == '1':
            stage = mirrors1
        elif sys.argv[1] == '2':
            stage = mirrors2
        else:
            return
    
    return print(sum(stage(sys.stdin)))

if __name__=='__main__':
    main()
