# Advent of Code 2023
# Day 11: Cosmic Expansion (another way to do it)

from adventofcode import Grid,Point

pairs = lambda L: sum(([(L[i],L[j]) for j in range(i+1, len(L))] for i in range(len(L))), start=[])


class CosmicExpansion2(Grid):

    def __init__(self, file):
        super().__init__(file)
        self.galaxies = list()
        found = self.find('#')
        while found:
            self.galaxies.append(found)
            found = self.find('#', found.right())
        #print(self.galaxies)

    def expand(self, age):
        def _expand(fixed, size):
            ex = 0
            expansion = {}
            for i in range(size):
                if i not in fixed:
                    ex += age
                expansion[i] = ex
            return expansion
        rows = set(g.row for g in self.galaxies)
        cols = set(g.col for g in self.galaxies)
        eX = _expand(cols, self.width)
        eY = _expand(rows, self.height)
        self.galaxies = list(g+Point(eX[g.x],eY[g.y]) for g in self.galaxies)

    @staticmethod
    def distance(g1, g2):
        return abs(g1.x-g2.x) + abs(g1.y-g2.y)

    def distanceiter(self):
        for f, g in pairs(self.galaxies):
            d = self.distance(f, g)
            yield d

    def expand_and_sum(self, expansion):
        self.expand(expansion-1)
        return sum(self.distanceiter())

def main():
    import sys
    expand = 0
    if len(sys.argv) > 1:
        if sys.argv[1] == '1':
            expand = 2
        elif sys.argv[1] == '2':
            expand = 1000000
        else:
            return
    print(CosmicExpansion2(sys.stdin).expand_and_sum(expand))

if __name__=='__main__':
    main()
