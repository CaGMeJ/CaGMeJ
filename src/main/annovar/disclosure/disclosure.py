import gzip

csv_path = "disclosure.csv"

dic = {}

with open(csv_path, mode = "r") as lines:
    next(lines)
    for line in lines:
        gene, genotype, group = line.split(",")
        group = group[0]
        if genotype == "":
            genotype = "."
        if not gene in dic:
            dic[gene] = [""]
        else:
            dic[gene][0] += ";"
        dic[gene][0] += genotype + "," + group

csv_path = "GDI_full_10282015.txt"
header = ["disclosure"]

with open(csv_path, mode = "r") as lines:
    for line in lines:
        elem = line.rstrip("\n").split("\t")
        gene = elem[0]
        if gene == "Gene":
            for i in elem[1:]:
                header.append(i.replace(" ", "_"))
            continue
        if not gene in dic:
            dic[gene] = ["."]
       
        dic[gene] += elem[1:]


print("#Gene\t" + ("\t".join(header)))

for gene in dic:
    print(gene + "\t" + ("\t".join(dic[gene])))                 

