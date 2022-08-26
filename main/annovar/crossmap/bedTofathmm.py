import sys
from Bio import SeqIO

record = SeqIO.to_dict(SeqIO.parse(sys.argv[3], 'fasta'))
out = open(sys.argv[1], mode = "w")

with open(sys.argv[2]) as lines:
    for line in lines:
        elem = line.rstrip("\n").split("\t")
        new_elem = elem[6].split(";", 5)
        old_elem = elem[6].split(";", 5)
        new_elem[0] = elem[0]
        new_elem[1] = elem[1] 
        new_elem[2] = elem[2]
        new_ref = str(record[("chr" + elem[0]).replace("chrchr", "chr")].seq[int(elem[1]) - 1: int(elem[2])])
        old_ref = old_elem[3]
        new_alt = []
        for old_alt in old_elem[4].split(","):
            left_match_size = 0
            for i in range(min(len(old_ref), len(old_alt))):
                if old_ref[i] == old_alt[i]:
                    left_match_size += 1
                else:
                    break
            new_alt.append(new_ref[:left_match_size] + old_alt[left_match_size:])
        new_elem[3] = new_ref if old_ref != "-" else "-"
        new_elem[4] = ",".join(new_alt)
        out.write(("\t".join(new_elem)) + "\n")
        out.flush()

