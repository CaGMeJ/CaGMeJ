import os
import sys

dbfile = sys.argv[1]
filepath = sys.argv[2]

memo = [0, 0, 0, 0]
Bin = 100
filesize = os.path.getsize(dbfile)
print("#BIN\t{0}\t{1}".format(Bin, filesize))
flag = 0
with open(filepath) as lines:
    for line in lines:
        elem = line.rstrip("\n").split("\t")
        if memo[:2] != elem[:2]:
            if flag:
                print("{0}\t{1}\t{2}\t{3}".format(memo[0], memo[1], memo[2], memo[3]))
            for i in range(4):
                memo[i] = elem[i]
            flag = 1
        else:
            memo[3] = elem[3]

print("{0}\t{1}\t{2}\t{3}".format(memo[0], memo[1], memo[2], memo[3]))
