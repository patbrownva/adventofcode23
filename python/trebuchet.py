# Advent of Code 2023
# Day one task: Trepuchet?!

from adventofcode import AdventOfCode
import re

NUM = re.compile('\\d')
number_words = {
    'zero':0,
    'one':1,
    'two':2,
    'three':3,
    'four':4,
    'five':5,
    'six':6,
    'seven':7,
    'eight':8,
    'nine':9
}
NUM_WORDS = re.compile('|'.join(number_words)+'|\\d')
def word_to_int(word):
    return int(number_words.get(word,word))

def safe_search(match):
    return match.group(0) if match else ''

def find_all_overlapping(exp,line):
    start = 0
    while match := exp.search(line, start):
        yield match.group(0)
        start = match.start() + 1

class trebuchet1(AdventOfCode):

    def line(self, line):
        line = line.lower()
        return int(safe_search(NUM.search(line)) + safe_search(NUM.search(line[::-1])))

class trebuchet2(AdventOfCode):

    def line(self, line):
        # My first attempt here used `findall` but failed on 'eightwo'
        numbers = list(find_all_overlapping(NUM_WORDS, line.lower()))
        return word_to_int(numbers[0])*10 + word_to_int(numbers[-1]) if numbers else 0
    
def main():
    stage = trebuchet1
    import sys
    if len(sys.argv) > 1:
        if sys.argv[1] == '1':
            stage = trebuchet1
        elif sys.argv[1] == '2':
            stage = trebuchet2
        else:
            return
    print(stage(sys.stdin).reduce_lines(sum))

if __name__=='__main__':
    main()
