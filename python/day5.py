# Advent of Code
# Day 5: If you give a seed a fertilizer

import re
from itertools import chain

SEEDINPUT = re.compile(r"seeds: ([\d ]*)")
MAPINPUT = re.compile(r"([\w-]+) map:")

# Why is calling `min` on a range object so slow?
# I had this mostly solved but it was taking so long
# to run I thought I needed to do something else. 

def range_overlap(left, right):
    return range(max(right.start,left.start), min(right.stop,left.stop))

class AlmanacSeeds:
    def __init__(self):
        self.ranges = set()
    def add(self, range_start, range_len):
        self.ranges.add(range(range_start, range_start+range_len))
    def __iter__(self):
        return chain.from_iterable(self.ranges)
    def has(self, item):
        for r in self.ranges:
            if item in r:
                return True
        return False

class AlmanacRange:

    ranges = {}

    def __new__(cls, dst_start, src_start, range_len):
        try:
            return cls.ranges[ (dst_start, src_start, range_len) ]
        except KeyError:
            pass
        self = super().__new__(cls)
        self.dst = range(dst_start, dst_start+range_len)
        self.src = range(src_start, src_start+range_len)
        cls.ranges[ (dst_start, src_start, range_len) ] = self
        return self

class AlmanacMap:

    def __init__(self, input):
        self.ranges = set()
        while line := input.readline().rstrip():
            self.add(*map(int, line.split()))

    def add(self, *args):
        if isinstance(args[0], AlmanacRange):
            self.ranges.add(args[0])
        else:
            self.ranges.add(AlmanacRange(*args))

    def __getitem__(self, item):
        for r in self.ranges:
            if item in r.src:
                return r.dst.start + r.src.index(item)
        return item

    def overlap(self, items):
        items = [items]
        dst = []
        while items:
            s = items.pop()
            for r in self.ranges:
                o = range_overlap(r.src, s)
                if o:
                    d = r.dst.start+r.src.index(o.start)
                    dst.append( range(d, d+len(o)) )
                    if s.start < o.start:
                        items.append( range(s.start, o.start) )
                    if o.stop < s.stop:
                        items.append( range(o.stop, s.stop) )
                    break
            else:
                dst.append(s)
        return dst

class Almanac1:

    def __init__(self, input):
        self.seeds = self.input_seeds(input)
        #print("Got seeds:",self.seeds)
        self.maps = {}
        while line := input.readline():
            m = MAPINPUT.match(line)
            if m:
                #print("Adding map:", m[1])
                self.maps[m[1]] = AlmanacMap(input)

    def input_seeds(self, input):
        while line := input.readline().rstrip():
            m = SEEDINPUT.match(line)
            if m:
                return [int(s) for s in m[1].split()]
        return []

    def lookup(self, item, table):
        src = table[0]
        for dst in table[1:]:
            #print(src,item,dst)
            m = self.maps[src+'-to-'+dst]
            item = m[item]
            src = dst
        return item

    def lookup_range(self, items, table):
        src = table[0]
        for dst in table[1:]:
            overlap = []
            m = self.maps[src+'-to-'+dst]
            for r in items:
                #print(src,r,dst)
                overlap.extend(m.overlap(r))
            items = overlap
            src = dst
        return items

class Almanac2(Almanac1):
    def input_seeds(self, input):
        seeds = AlmanacSeeds()
        while line := input.readline().rstrip():
            m = SEEDINPUT.match(line)
            if m:
                ranges = [int(s) for s in m[1].split()]
                for pair in zip(ranges[::2],ranges[1::2]):
                    seeds.add(*pair)
        return seeds

def part1(input):
    almanac = Almanac1(input)
    seed_to_location = lambda s: almanac.lookup(s, 'seed soil fertilizer water light temperature humidity location'.split())
    return min(seed_to_location(seed) for seed in almanac.seeds)

def part2(input):
    almanac = Almanac2(input)
    seed_to_location = lambda s: almanac.lookup_range(s, 'seed soil fertilizer water light temperature humidity location'.split())
    return min(r.start for r in seed_to_location(almanac.seeds.ranges))

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
