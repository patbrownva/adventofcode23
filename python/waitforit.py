from numpy.polynomial.polynomial import Polynomial
import math
from collections import namedtuple
from functools import reduce

class Race1:

    Race = namedtuple('Race', ['time','distance'])

    def __init__(self, file):
        times = [int(num) for num in file.readline().split(':')[1].strip().split()]
        distances = [int(num) for num in file.readline().split(':')[1].strip().split()]
        self.races = [self.Race(t,d) for t,d in zip(times,distances)]

    def count_trials(self, index=slice(None)):
        if type(index) is int:
            return self.trial(self.races[index])
        return [self.trial(r) for r in self.races[index]]

    @staticmethod
    def trial(race):
        p,q = Polynomial((-race.distance, race.time, -1)).roots()
        return math.ceil(q-1) - math.floor(p+1) + 1

class Race2(Race1):

    def __init__(self, file):
        times = int(file.readline().split(':')[1].replace(' ',''))
        distances = int(file.readline().split(':')[1].replace(' ',''))
        self.races = [self.Race(times,distances)]

def part1(file):
    return reduce(lambda x,y: x*y, Race1(file).count_trials(), 1)

def part2(file):
    return Race2(file).count_trials(0)

def main():
    import sys
    stage = part1
    if len(sys.argv) > 1:
        if sys.argv[1] == '1':
            stage = part1
        elif sys.argv[1] == '2':
            stage = part2
        else:
            return
    print(stage(sys.stdin))

if __name__=='__main__':
    main()
