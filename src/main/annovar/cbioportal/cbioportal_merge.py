tmp = []
hg19 = open("hg19_cBioPortal_all_mutation_annovar.txt", mode="w")

with open("hg19_cBioPortal_all_mutation_annovar_sorted.txt") as lines:
    for line in  lines:
        line_split = line.rstrip("\n").split("\t")
        if len(tmp) > 0 and line_split[:5] == tmp[:5]:
            tmp[5] += ";" + line_split[5]
        else:
            if len(tmp) > 0:
                if tmp[0] == "23": tmp[0] = "X"
                if tmp[0] == "24": tmp[0] = "Y"
                hg19.write("\t".join(tmp) + "\n")
            tmp = line_split

hg19.write("\t".join(tmp) + "\n")
