# Advent of Code 2023
# Day 12: Hot Springs

from adventofcode import AdventOfCode
from functools import lru_cache

class HotSprings1(AdventOfCode):

    @lru_cache(maxsize=2**12)
    def fill_blanks(self, diagram: str, pattern: tuple[int]) -> int:
        diagram = diagram.strip('.')
        
        # Empty diagram matches empty pattern
        if len(diagram) == 0:
            return len(pattern) == 0
    
        # Empty pattern matches diagram with no marks
        if len(pattern) == 0:
            return diagram.count('#') == 0
        
        # Diagram that starts with a mark
        if diagram[0] == '#':
            # Can this mark be the right size to fit the pattern?
            # True if the diagram is long enough,
            # and there are no spaces in the pattern width
            # and there is not a mark after the pattern width.
            if (pattern[0] <= len(diagram)
            and '.' not in diagram[:pattern[0]]
            and '#' != diagram[pattern[0]:pattern[0]+1]):
                # Good. Try to match the remainder against following patterns
                return self.fill_blanks(diagram[pattern[0]+1:], pattern[1:])
            else:
                # Can't fit this mark
                return 0
        
        assert(diagram[0] == '?')
        # Could be a mark or space
        # Try to match both branches against the pattern
        # and add them together
        return (self.fill_blanks('#'+diagram[1:], pattern)
              + self.fill_blanks(diagram[1:], pattern))

    @staticmethod
    def parse(line):
        diagram, pattern = line.split()
        pattern = tuple(int(i) for i in pattern.split(','))
        return diagram, pattern

    def line(self, line):
        diagram, pattern = self.parse(line)
        return self.fill_blanks(diagram, pattern)


class HotSprings2(HotSprings1):

    def line(self, line):
        diagram, pattern = self.parse(line)
        diagram = '?'.join([diagram] * 5)
        pattern = pattern * 5
        return self.fill_blanks(diagram, pattern)


if __name__=='__main__':
    print(AdventOfCode.reduce_and_sum((HotSprings1, HotSprings2)))
    #print(HotSprings1.fill_blanks.cache_info())
