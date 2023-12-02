# Advent of Code 2023
# Day 2 task: Cube Conundrum

from adventofcode import AdventOfCode
import re

GAME = re.compile("Game (\\d+): ")
CUBE = re.compile("(\\d+)\\s+(\\w+)")

class cubeconundrum1(AdventOfCode):

    def __init__(self, inputfile, maxcubes):
        self.max_cubes = maxcubes
        super().__init__(inputfile)

    def new_game(self):
        return {'red':0, 'green':0, 'blue': 0}

    def add_set(self, game, game_set):
        def game_max(color):
            game[color] = max(game[color], game_set.get(color, 0))
        game_max('red')
        game_max('green')
        game_max('blue')

    def line(self, line):
        game_line = GAME.match(line)
        game_num = int(game_line.group(1))
        game = self.new_game()
        for game_set in line[game_line.span()[1]:].split(';'):
            self.add_set(game,
                         dict( ((color,int(num)) for num,color in CUBE.findall(game_set)) )
                         )
        return self.result(game_num, game)

    def result(self, game_num, game):
        if game['red'] > self.max_cubes['red'] \
        or game['green'] > self.max_cubes['green'] \
        or game['blue'] > self.max_cubes['blue']:
            return 0
        return game_num

class cubeconundrum2(cubeconundrum1):

    def result(self, game_num, game):
        return game['red'] * game['green'] * game['blue']

def main():
    stage = cubeconundrum1
    import sys
    if len(sys.argv) > 1:
        if sys.argv[1] == '1':
            stage = cubeconundrum1
        elif sys.argv[1] == '2':
            stage = cubeconundrum2
        else:
            return
    max_cubes = {'red':12, 'green':13, 'blue':14}
    print(stage(sys.stdin, max_cubes).reduce_lines(sum))

if __name__=='__main__':
    main()
