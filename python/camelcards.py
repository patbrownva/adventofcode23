# Advent of Code 2023
# Day 7: Camel Cards

from adventofcode import AdventOfCode
from collections import Counter
from bisect import insort

class Camel1:

    def __new__(cls, cards):
        self = super().__new__(cls)
        self.cards = tuple(cls.CARDS.index(c) for c in cards)
        return self

    CARDS = "23456789TJQKA"

    def hand(self):
        hand = 0
        counts = Counter(self.cards)
        most = [c[1] for c in counts.most_common(2)]
        while len(most) < 2:
            most.append(0)
        if most[0] >= 5:
            # Five of a kind
            return 6
        elif most[0] == 4:
            # Four of a kind
            return 5
        elif most[0] == 3 and most[1] == 2:
            # Full house
            return 4
        elif most[0] == 3:
            # Three of a kind
            return 3
        elif most[0] == 2 and most[1] == 2:
            # Two pair
            return 2
        elif most[0] == 2:
            # Pair
            return 1
        else:
            return 0

    def __lt__(self, right):
        lh = (self.hand(),) + self.cards
        rh = (right.hand(),) + right.cards
        return lh < rh
    def __eq__(self, right):
        return self.cards == right.cards

class Camel2(Camel1):

    CARDS = "J23456789TQKA"

    def hand(self):
        hand = 0
        counts = Counter(self.cards)
        most = counts.most_common(3)
        while len(most) < 3:
            most.append((0,0))
        # Hand full of jokers
        if most[0][0] == 0 or most[1][0] == 0:
            most = [most[0][1]+most[1][1], most[2][1]]
        else:
            most = [most[0][1], most[1][1]]
            most[0] += counts[0]
        if most[0] >= 5:
            # Five of a kind
            return 6
        elif most[0] == 4:
            # in a six-card hand you could have pair+2jokers greater than 3-kind
            # Four of a kind
            return 5
        elif most[0] == 3 and most[1] == 2:
            # you would not not use a joker to make the pair because 4-kind is better
            # Full house
            return 4
        elif most[0] == 3:
            # Three of a kind
            return 3
        elif most[0] == 2 and most[1] == 2:
            # joker would never be used to make two pairs when you could have 3-kind
            # Two pair
            return 2
        elif most[0] == 2:
            # Pair
            return 1
        else:
            return 0

class CamelCards1(AdventOfCode):

    def __init__(self, file):
        super().__init__(file)
        self.hands = []

    def line(self, line):
        cards, bid = line.split()[:2]
        insort(self.hands, (Camel1(cards), int(bid)))

    def bids(self):
        return sum((rank+1) * hand[1] for rank,hand in enumerate(self.hands))

class CamelCards2(CamelCards1):

    def line(self, line):
        cards, bid = line.split()[:2]
        insort(self.hands, (Camel2(cards), int(bid)))


def main():
    import sys
    stage = CamelCards1
    if len(sys.argv) > 1:
        if sys.argv[1] == '1':
            stage = CamelCards1
        elif sys.argv[1] == '2':
            stage = CamelCards2
        else:
            return
    print(stage(sys.stdin).read().bids())

if __name__=='__main__':
    main()
