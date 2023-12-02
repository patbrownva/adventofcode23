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

    def reduce_lines(self, collector, initial=None):
        lines = map(self.line, self.input)
        if collector is sum and (initial is None or initial == 0):
            return sum(lines)
        return reduce(collector, lines, initial)
