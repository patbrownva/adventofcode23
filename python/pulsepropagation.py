# Advent of Code 2023
# Day 20: Pulse Propagation

from adventofcode import AdventOfCode
from collections import defaultdict, deque, Counter
from enum import Enum
from typing import Optional, Generator, Sequence, Callable
from dataclasses import dataclass

class Pulse(Enum):
    H = 0
    L = 1

    def __invert__(self):
        return Pulse(self.value ^ 1)
    def __str__(self):
        return "HL"[self.value]

class Module:
    def connect(self, module: str) -> None:
        pass
    def receive(self, pulse: Pulse, sender: str) -> Optional[Pulse]:
        return pulse

class FlipFlop(Module):
    def __init__(self):
        self.state = Pulse.L
    def receive(self, pulse: Pulse, sender: str) -> Optional[Pulse]:
        if pulse is Pulse.L:
            self.state = ~self.state
            return self.state

class Conjunction(Module):
    def __init__(self):
        self.inputs = {}
    def connect(self, module: str) -> None:
        self.inputs[module] = Pulse.L
    def receive(self, pulse: Pulse, sender: str) -> Optional[Pulse]:
        self.inputs[sender] = pulse
        return (Pulse.L if all(inp is Pulse.H for inp in self.inputs.values())
                else Pulse.H)

@dataclass
class Message:
    pulse: Pulse
    receiver: str
    sender: Optional[str] = None

class MessageLoop:
    def __init__(self):
        self.queue = deque()
        self.counter = Counter()
    def send(self, pulse: Pulse, receiver: str, sender: Optional[str] = None) -> None:
        self.counter[pulse] += 1
        self.queue.append(Message(pulse=pulse, receiver=receiver, sender=sender))
    def pump(self) -> Generator[Message,None,None]:
        while self.queue:
            yield self.queue.popleft()
    def count(self) -> tuple[int,int]:
        return tuple(self.counter.values())
    def clear(self) -> None:
        self.queue.clear()
        self.counter.clear()

@dataclass
class Gate:
    module: Module
    outputs: list[str]

class Processor:
    def __init__(self):
        self.messages = MessageLoop()
        self.gates = {}
    def run(self) -> tuple[int,int]:
        self.messages.send(Pulse.L, "broadcaster", "button")
        for msg in self.messages.pump():
            if msg.receiver not in self.gates:
                continue
            gate = self.gates[msg.receiver]
            pulse = gate.module.receive(msg.pulse, msg.sender)
            if pulse:
                for out in gate.outputs:
                    self.messages.send(pulse, out, msg.receiver)
        return self.messages.count()
    def add(self, name: str, module: Module, outputs: Sequence[str]) -> None:
        self.gates[name] = Gate(module, list(outputs))
    def connect(self) -> None:
        for name,gate in self.gates.items():
            for mod in (self.gates[o] for o in gate.outputs if o in self.gates):
                mod.module.connect(name)
    def reset(self) -> None:
        for name in self.gates:
            module = type(self.gates[name].module)
            self.gates[name].module = module()
        self.connect()
        self.messages.clear()
    def inputs(self, name: str) -> set[str]:
        return set(gate for gate in self.gates if name in self.gates[gate].outputs)
    def unbuffer(self, name: str) -> str:
        outputs = self.gates[name].outputs
        inputs = self.inputs(name)
        while len(outputs) == 1 and len(inputs) == 1:
            name = inputs.pop()
            gate = self.gates[name].outputs
            inputs = self.inputs(name)
        return name

class PulsePropagation(AdventOfCode):

    def __init__(self, inputfile):
        super().__init__(inputfile)
        self.processor = Processor()

    def line(self, line: str) -> None:
        name,outputs = line.split('->')
        outputs = (s.strip() for s in outputs.split(','))
        name = name.strip()
        module = Module
        match name[0]:
            case '%':
                module = FlipFlop
                name = name[1:]
            case '&':
                module = Conjunction
                name = name[1:]
        self.processor.add(name, module(), outputs)

    def finish(self) -> None:
        self.processor.connect()

    def run(self) -> 'PulsePropagation':
        for I in range(1000):
            lcount,hcount = self.processor.run()
        print(lcount, hcount, lcount * hcount)
        self.processor.reset()
        return self

    def analyze(self) -> 'PulsePropagation':
        import math
        cycles = {}
        proc = self.processor
        accums = set()
        rxinps = set(proc.inputs("rx"))
        for rxgate in rxinps:
            gate = proc.unbuffer(rxgate)
            if type(proc.gates[gate].module) is Conjunction:
                accums.update(proc.unbuffer(g) for g in proc.inputs(gate))
        units = list((ac,set(proc.inputs(ac))) for ac in accums)
        for name in proc.gates["broadcaster"].outputs:
            accumulator, bitgates = tuple((u for u in units if name in u[1]))[0]
            outputs = tuple(g for g in proc.gates[name].outputs if g != accumulator)
            shift = 1
            counter = 0
            while name != accumulator:
                if name in bitgates:
                    counter |= shift
                shift <<= 1
                outputs = tuple(g for g in proc.gates[name].outputs if g != accumulator)
                if not outputs:
                    break
                name = outputs[0]
            cycles[accumulator] = counter
        print('\n'.join(f"{ac}: {ct}" for ac,ct in cycles.items()))
        print(math.lcm(*cycles.values()))
        return self

if __name__=='__main__':
    import sys
    PulsePropagation(sys.stdin).read().run().analyze()
