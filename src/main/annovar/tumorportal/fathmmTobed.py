import sys

out_bed = open(sys.argv[1], mode = "w")
with open(sys.argv[2]) as lines:
    for line in lines:
        elem = line.rstrip("\n").split("\t")
        out_bed.write(("\t".join([elem[0], elem[1], elem[2], ".", ".", ".", (";".join(elem))])) + "\n")
