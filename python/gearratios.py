import re

SCHEMATIC = re.compile(r'\d+|[^\s.]')

class EnginePart:

    @staticmethod
    def input(part_or_num):
        try:
            num = int(part_or_num)
            return EnginePartNumber(num)
        except ValueError:
            pass
        return EngineSchematicPart(part_or_num)

    def __str__(self):
        return str(self.part)

class EnginePartNumber(EnginePart):

    def __init__(self, partnum):
        self.part = partnum

class EngineSchematicPart(EnginePart):

    def __init__(self, part):
        self.part = part

class EngineSchematic:

    def __init__(self):
        self.schematic = list()

    def input(self, file):
        for line in file:
            self.add_line(self.split_line(line))

    @staticmethod
    def split_line(line):
        for match in SCHEMATIC.finditer(line):
            yield match.span(),EnginePart.input(match.group())

    def add_line(self, line):
        self.schematic.append(list(line))

    def __getitem__(self, index):
        col,row = index
        for pos,part in self.schematic[row]:
            if col < pos[0]:
                break
            if col < pos[1]:
                return part
        raise IndexError("part not found")

    def __iter__(self):
        for rownum,row in enumerate(self.schematic):
            for pos,part in row:
                yield (pos[0],rownum), part

    def part_numbers(self, pos):
        nums = set()
        for index in ((col,row) for row in range(pos[1]-1,pos[1]+2)
                                for col in range(pos[0]-1,pos[0]+2)
                                if (col,row)!=pos):
            try:
                part = self.__getitem__(index)
                if isinstance(part, EnginePartNumber):
                    nums.add(part)
            except IndexError:
                pass
        return list(nums)

def gearratios1(engine):
    nums = set()
    for pos,part in engine:
        if isinstance(part, EngineSchematicPart):
            nums.update(engine.part_numbers(pos))
    return (part.part for part in nums)

def gearratios2(engine):
    for pos,part in engine:
        if isinstance(part, EngineSchematicPart) and part.part == '*':
            nums = engine.part_numbers(pos)
            if len(nums) == 2:
                yield nums[0].part * nums[1].part

def main():
    import sys
    stage = None
    if len(sys.argv) > 1:
        if sys.argv[1] == '1':
            stage = gearratios1
        elif sys.argv[1] == '2':
            stage = gearratios2
        else:
            return
    engine = EngineSchematic()
    engine.input(sys.stdin)
    if stage:
        print(sum(stage(engine)))
    else:
        for pos,part in engine:
            print(pos,part)

if __name__=='__main__':
    main()
