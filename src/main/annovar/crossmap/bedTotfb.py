import sys


out = open(sys.argv[1], mode = "w")

with open(sys.argv[2]) as lines:
    for line in lines:
        elem = line.rstrip("\n").split("\t")
        new_elem = elem[6].split(";")
        old_elem = elem[6].split(";")
        new_elem[1] = elem[0]
        new_elem[2] = elem[1] 
        new_elem[3] = elem[2]
        if  len(new_elem) > 8:
            print(line)
            import sys
            sys.exit()
        out.write(("\t".join(new_elem)) + "\n")

