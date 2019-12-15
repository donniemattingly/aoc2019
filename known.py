import itertools
import sys
from collections import defaultdict, deque
import random

class Program(object):
    def __init__(self, pid, program_file, input):
        self.P = defaultdict(int)
        for i,x in enumerate(open(program_file).read().split(',')):
            self.P[i] = int(x)
        self.input = input
        self.ip = 0
        self.pid = pid
        self.rel_base = 0
        self.halted = False
    def idx(self, i, I):
        mode = (0 if i>=len(I) else I[i])
        val = self.P[self.ip+1+i]
        if mode == 0:
            pass # no-op
        elif mode == 2:
            val = val+self.rel_base
        else:
            assert False, mode
        return val
    def val(self, i, I):
        mode = (0 if i>=len(I) else I[i])
        val = self.P[self.ip+1+i]
        if mode == 0:
            val = self.P[val]
        elif mode == 2:
            val = self.P[val+self.rel_base]
        return val
    def run_all(self):
        ans = []
        while True:
            val = self.run()
            if val == None:
                return ans
            ans.append(val)

    def run(self):
        """Return next output"""
        while True:
            cmd = str(self.P[self.ip])
            opcode = int(cmd[-2:])
            I = list(reversed([int(x) for x in cmd[:-2]]))
            if opcode == 1:
                i1,i2 = self.val(0,I),self.val(1,I)
                self.P[self.idx(2, I)] = self.val(0, I) + self.val(1, I)
                self.ip += 4
            elif opcode == 2:
                i1,i2 = self.val(0,I),self.val(1,I)
                self.P[self.idx(2, I)] = self.val(0, I) * self.val(1, I)
                self.ip += 4
            elif opcode == 3:
                inp = self.input()
                self.P[self.idx(0, I)] = inp #self.Q[0]
                #self.Q.pop(0)
                self.ip += 2
            elif opcode == 4:
                ans = self.val(0, I)
                self.ip += 2
                return ans
            elif opcode == 5:
                self.ip = self.val(1, I) if self.val(0, I)!=0 else self.ip+3
            elif opcode == 6:
                self.ip = self.val(1, I) if self.val(0, I)==0 else self.ip+3
            elif opcode == 7:
                self.P[self.idx(2, I)] = (1 if self.val(0,I) < self.val(1,I) else 0)
                self.ip += 4
            elif opcode == 8:
                self.P[self.idx(2, I)] = (1 if self.val(0,I) == self.val(1,I) else 0)
                self.ip += 4
            elif opcode == 9:
                self.rel_base += self.val(0, I)
                self.ip += 2
            else:
                assert opcode == 99, opcode
                self.halted = True
                return None


G = defaultdict(int)
PATH = {} # path from (0,0) to (r,c)
DR = [-1, 1, 0, 0]
DC = [0, 0, -1, 1]
r,c = 0,0
dist = 0
Q = deque()
for d in range(4):
    Q.append(((DR[d], DC[d]), (0,0), d))
SEEN = set()
PATH[(0,0)] = []
def inv(d):
    return {0:1, 1:0, 2:3, 3:2}[d]
def pathInv(path):
    return [inv(d) for d in reversed(path)]
def show():
    R = sorted([r for r,c in G])
    C = sorted([c for r,c in G])
    if R:
        for r in range(R[0], R[-1]+1):
            for c in range(C[0], C[-1]+1):
                ch = ' '
                if (r,c) in G:
                    ch = {0:'.', 1: 'W'}[G[(r,c)]]
                if (r,c) == (0,0):
                    ch = 'X'
                print ch,
            print

path = None
move = None
oxy = None
def get_input():
    global path,move,target,Q
    if not path:
        while True:
            if not Q:
                D = {}
                Q = deque([(oxy,0)])
                while Q:
                    (r,c),d = Q.popleft()
                    if G[(r,c)] == 1:
                        continue
                    if (r,c) in D:
                        continue
                    D[(r,c)] = d
                    for dd in range(4):
                        rr,cc = r+DR[dd],c+DC[dd]
                        Q.append(((rr,cc),d+1))
                print(max([d for rc,d in D.items()]))
                sys.exit(0)
            target,parent,newd = Q.popleft()
            if target in SEEN:
                continue
            SEEN.add(target)
            path = PATH[parent]+[newd]+pathInv(PATH[parent])
            #print((r,c),target,len(path),path)
            #show()
            path = deque(path)
            break
    #print(r,c,target,path)
    move = path.popleft()
    #print(r,c,target,path,move)
    return move+1

P = Program('0', 'inputs/input-15-1.txt', get_input)
t = 0
part1 = False
while not P.halted:
    status = P.run()
    rr,cc = r+DR[move], c+DC[move]
    #if t%1000 == 0:
    #    print(t,len(G),len(Q))
    if status == 0:
        G[(rr,cc)] = 1
    elif status in [1,2]:
        if (rr,cc) not in PATH:
            PATH[(rr,cc)] = PATH[(r,c)]+[move]
        r += DR[move]
        c += DC[move]
        if (r,c) == target:
            path.appendleft(inv(move))
        G[(r,c)] = 0
        for d in range(4):
            y = (r+DR[d], c+DC[d])
            if y not in SEEN:
                Q.append((y, (r,c), d))
        if status == 2:
            if not part1:
                print(len(PATH[(r,c)]))
                part1 = True
            oxy = (r,c)
    t += 1


