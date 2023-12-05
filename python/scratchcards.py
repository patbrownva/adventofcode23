# Advent of Code 2023
# Day 4 task: Scratchcards

from adventofcode import AdventOfCode
import re
from collections import Counter

CARD = re.compile(r"Card *(\d+):([^|]*)\|(.*)")

class scratchcards1(AdventOfCode):

    def line(self, line):
        card,winning,drawn = self.card(line)
        matches = set(winning).intersection(drawn)
        return 2**(len(matches)-1) if matches else 0

    def card(self, line):
        match = CARD.match(line)
        if not match:
            raise ValueError("invalid input")
        list_of_nums = lambda S: map(int,re.findall("\\d+", S))
        return int(match[1]), list_of_nums(match[2]), list_of_nums(match[3])

class scratchcards2(scratchcards1):

    def __init__(self, file):
        self.cardstack = Counter()
        super().__init__(file)

    def line(self, line):
        card,winning,drawn = self.card(line)
        self.cardstack[card] += 1
        matches = set(winning).intersection(drawn)
        if matches:
            # Don't do this, the update method is very slow
            #self.cardstack.update(list(range(card+1, card+len(matches)+1)) * self.cardstack[card])
            for win in range(card+1, card+len(matches)+1):
                self.cardstack[win] += self.cardstack[card]
        return self.cardstack[card]

def main():
    print(AdventOfCode.reduce_and_sum([scratchcards1,scratchcards2]))

if __name__=='__main__':
    main()
