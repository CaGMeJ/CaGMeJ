import sys

filepath = sys.argv[1]

with open(filepath) as lines:
    for line in lines:
        if line[0] == "#":
            continue

        columns = line.rstrip("\n").split()
        ALT = columns[4]
        if "," in ALT:
            ALT_list = columns[4].split(",")
            for i in range(len(ALT_list)):
                print("\t".join([columns[0], columns[1], columns[1], columns[3], ALT_list[i], columns[2]]))
        else:
            print("\t".join([columns[0], columns[1], columns[1], columns[3], columns[4], columns[2]]))
