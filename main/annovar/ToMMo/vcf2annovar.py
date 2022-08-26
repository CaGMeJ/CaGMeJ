import sys

filepath = sys.argv[1]

with open(filepath) as lines:
    for line in lines:
        if line[0] == "#":
            continue

        columns = line.rstrip("\n").split()
        AF = columns[7].split(";")[2].split("=")[1]
        if "," in AF:
            AF_list = AF.split(",")
            ALT_list = columns[4].split(",")
            for i in range(len(AF_list)):
                print("\t".join([columns[0], columns[1], columns[1], columns[3], ALT_list[i], AF_list[i]]))
        else:
            print("\t".join([columns[0], columns[1], columns[1], columns[3], columns[4], AF]))
