# Advent of Code 2023
# Day 15: Lens Library
#
# If you want to implement a hash map from scratch
# you must first create the universe.

# Constants

BOXES = 256


# Types

String = list[int]
Number = int
Hash = int
Lens = list[String, Number]
Box = list[Lens | int]
Hashmap = list[Box]


# Definitions

def BOX() -> Box:
    return [0] * (BOXES + 1)

def HASH(_string: String) -> Hash:
    _hash = 0
    for _ascii in _string:
        _hash += _ascii
        _hash *= 17
    return _hash % BOXES


def HASHMAP() -> Hashmap:
    _map = [0] * BOXES
    _box = 0
    while _box < BOXES:
        _map[_box] = BOX()
        _box += 1
    return _map


# LABEL = lambda _lens: ''.join(_lens[0])


def LENS(_label: String = String(), _focallength: Number = Number()) -> Lens:
    return [_label, _focallength]


def FIND(_map: Hashmap, _label: String) -> list[Box, int]:
    _box = _map[HASH(_label)]
    _index = 1
    while _index <= _box[0]:
        if _box[_index][0] == _label:
            return [_box, _index]
        _index += 1
    return [_box, _index]


def TAKE(_map: Hashmap, _label: String, *_):
    _box, _index = FIND(_map, _label)
    while _index < _box[0]:
        _box[_index] = _box[_index + 1]
        _index += 1
    _box[_index] = 0
    _box[0] = _index - 1


def PUT(_map: Hashmap, _label: String, _number: Number):
    _box, _index = FIND(_map, _label)
    if _index > _box[0]:
        _box[_index] = LENS(_label, _number)
        _box[0] = _index
    else:
        _box[_index][1] = _number


def GET(_map: Hashmap, _label: String):
    _box, _index = FIND(_map, _label)
    return _box[_index][1] if _index <= _box[0] else -1


def PART1(_tape: String) -> list[String]:
    _sum = 0
    _steps = []
    _step = []
    for _ascii in _tape:
        if _ascii == 44: # ','
            _sum += HASH(_step)
            _steps.append(_step)
            _step = []
        else:
            _step.append(_ascii)
    print(_sum)
    return _steps


def STATES() -> list[Hashmap]:
    _states = [HASHMAP(), HASHMAP(), HASHMAP(), HASHMAP()]

    # [a-z]+
    _ascii = 97
    while _ascii < 123:
        PUT(_states[0], [_ascii], 0)
        _ascii += 1
    _ascii = 48

    PUT(_states[0], [61], 1) # =
    PUT(_states[0], [45], 2) # -

    # [0-9]+
    while _ascii < 58:
        PUT(_states[1], [_ascii], 3)
        PUT(_states[3], [_ascii], 3)
        _ascii += 1

    return _states


def PART2(_steps: list[String]):
    _map = HASHMAP()
    _states = STATES()

    for _step in _steps:
        _label = []
        _focallength = 0
        _operation = 0

        _parse = 0
        for _ascii in _step:
            _parse = GET(_states[_parse], [_ascii])
            if _parse == 0:
                _label.append(_ascii)
            elif _parse == 1 or _parse == 2:
                _operation = _ascii
            elif _parse == 3:
                _focallength *= 10
                _focallength += _ascii - 48
            else:
                print("error")
                return

        if _operation == 61:
            PUT(_map, _label, _focallength)
        elif _operation == 45:
            TAKE(_map, _label)
        else:
            print("error")
            return
    
    _sum = 0
    _box = 0
    while _box < BOXES:
        _index = 1
        while _index <= _map[_box][0]:
            _lens = _map[_box][_index]
            _sum += (_box + 1) * _index * _lens[1]
            _index += 1
        _box += 1
    print(_sum)


if __name__=='__main__':
    import sys
    _tape = [ord(_ch) for _ch in open(sys.argv[1]).read().strip()] + [44]
    _steps = PART1(_tape)
    PART2(_steps)

