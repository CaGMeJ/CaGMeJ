import glob
maf_files = glob.glob("*.maf")
dic = {}
for maf_file in maf_files:
    with open(maf_file, mode = "r") as lines:
        for line in lines:
            if line[:5] == "ttype":
                continue
            elem = line.rstrip("\n").split("\t")
            Chr = int(elem[5])
            Pos = int(elem[6])
            Ref = elem[7]
            Alt = elem[8]
            ttype = elem[0]
            patient = elem[1] 
            context65 = elem[9] 
            key = (Chr, Pos, Ref, Alt)
            value = patient
            if  key in dic:
                if ttype in dic[key]:
                    dic[key][ttype].add(value)
                else:
                    dic[key][ttype] = {value}
            else:
                dic[key] = {}
tmp = []
for key in dic:
    tmp.append((key, dic[key]))

for (Chr, Pos, Ref, Alt),j in sorted(tmp):
    end = str(Pos + len(Ref) - 1)
    if Chr == 23: Chr = "X"
    if Chr == 24: Chr = "Y"
    print(("{0}\t{1}\t" + end + "\t{2}\t{3}\t").format(Chr, Pos, Ref, Alt)  + ",".join(["{0}({1})".format(len(patient), ttype) for ttype, patient in sorted(j.items())]))
             
