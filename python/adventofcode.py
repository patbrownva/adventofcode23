# Advent of Code general class 

from functools import reduce

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
