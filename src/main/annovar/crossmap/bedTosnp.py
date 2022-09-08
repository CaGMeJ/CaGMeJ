import sys
from Bio import SeqIO

record = SeqIO.to_dict(SeqIO.parse(sys.argv[3], 'fasta'))
out = open(sys.argv[1], mode = "w")

with open(sys.argv[2]) as lines:
    for line in lines:
        elem = line.rstrip("\n").split("\t", 6)
        new_elem = elem[6].replace("\t", " ").split(";")
        old_elem = elem[6].replace("\t", " ").split(";")
        new_elem[1] = elem[0]
        new_elem[2] = elem[1] 
        new_elem[3] = elem[2]
        new_ref = str(record[elem[0]].seq[int(elem[1]) - 1: int(elem[2])])
        old_ref = old_elem[7]
        new_alt = []
        if len(old_elem) < 10:
            print(elem)
            continue
        for old_alt in old_elem[9].split("/"):
            left_match_size = 0
            for i in range(min(len(old_ref), len(old_alt))):
                if old_ref[i] == old_alt[i]:
                    left_match_size += 1
                else:
                    break
            new_alt.append(new_ref[:left_match_size] + old_alt[left_match_size:])
        if  len(new_elem) >= 27:
            print(line)
            import sys
            sys.exit()
        new_elem[7] = new_ref if old_ref != "-" else "-"
        new_elem[8] = new_ref if old_ref != "-" else "-"
        new_elem[9] = "/".join(new_alt)
        out.write(("\t".join(new_elem)) + "\n")

